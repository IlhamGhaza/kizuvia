import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kizuvia/features/scan/domain/label_classifier.dart';
import 'package:kizuvia/features/scan/domain/label_parser.dart';
import 'package:kizuvia/features/scan/domain/parsed_label.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'label_scanner.g.dart';

/// One recognised line with its position (for reading order).
class OcrLine {
  const OcrLine(this.text, this.top, this.left, this.height);

  final String text;
  final double top;
  final double left;
  final double height;
}

/// Reading order (docs/06 §4): top to bottom, then left to right; lines whose
/// tops differ by less than half a line height share a row.
String orderedText(Iterable<OcrLine> lines) {
  final sorted = [...lines]..sort((a, b) => a.top.compareTo(b.top));
  final rows = <List<OcrLine>>[];
  for (final l in sorted) {
    if (rows.isNotEmpty) {
      final ref = rows.last.first;
      if ((l.top - ref.top).abs() < ref.height * 0.5) {
        rows.last.add(l);
        continue;
      }
    }
    rows.add([l]);
  }
  return rows
      .map(
        (r) => (r..sort((a, b) => a.left.compareTo(b.left)))
            .map((l) => l.text)
            .join(' '),
      )
      .join('\n');
}

/// Camera / gallery -> ML Kit (on device, Latin script) -> [LabelParser].
/// The picture is deleted right after reading (health data). The result is a
/// DRAFT: the form marks every field "Periksa kembali" (safety rule 3).
class LabelScanner {
  LabelScanner(
    this._parser, [
    ImagePicker? picker,
    this._classifier = const NoModelClassifier(),
  ]) : _picker = picker ?? ImagePicker();

  final LabelParser _parser;
  final LabelClassifier _classifier;
  final ImagePicker _picker;

  /// Null if the user cancelled.
  Future<ParsedLabel?> scan(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 90,
    );
    if (picked == null) return null;
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      if (shouldReject(await _classifier.classify(picked.path))) {
        throw const NotALabelException();
      }
      final result = await recognizer.processImage(
        InputImage.fromFilePath(picked.path),
      );
      final lines = [
        for (final block in result.blocks)
          for (final line in block.lines)
            OcrLine(
              line.text,
              line.boundingBox.top,
              line.boundingBox.left,
              line.boundingBox.height,
            ),
      ];
      return _parser.parse(orderedText(lines));
    } finally {
      await recognizer.close();
      final f = File(picked.path);
      if (f.existsSync()) await f.delete();
    }
  }
}

@Riverpod(keepAlive: true)
Future<LabelParser> labelParser(Ref ref) async {
  final raw = await rootBundle.loadString('assets/drug_names.txt');
  return LabelParser(drugNames: raw.split('\n'));
}

@Riverpod(keepAlive: true)
Future<LabelScanner> labelScanner(Ref ref) async =>
    LabelScanner(await ref.watch(labelParserProvider.future));

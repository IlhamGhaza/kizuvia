import 'dart:ui';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/features/scan/data/label_scanner.dart';
import 'package:kizuvia/features/scan/domain/label_parser.dart';
import 'package:kizuvia/features/scan/domain/parsed_label.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:material_ui/material_ui.dart' show Icons, Size, TextFormField;

import '../app/app_test.dart' show appScope, settle, unmount;

class FakeScanner extends LabelScanner {
  FakeScanner(this.result) : super(LabelParser());

  final ParsedLabel? result;

  @override
  Future<ParsedLabel?> scan(ImageSource source) async => result;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('orderedText reads top-to-bottom, left-to-right, grouping rows', () {
    final text = orderedText(const [
      OcrLine('10 MG', 10, 200, 20),
      OcrLine('1 x 1 tablet', 60, 0, 20),
      OcrLine('AMLODIPINE', 12, 0, 20),
      OcrLine('sesudah makan', 100, 0, 20),
    ]);
    expect(text, 'AMLODIPINE 10 MG\n1 x 1 tablet\nsesudah makan');
  });

  testWidgets('scan fills a DRAFT: marked for review until touched', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('id')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final scanner = FakeScanner(
      const ParsedLabel(
        rawText: 'x',
        confidence: {},
        name: 'Amlodipine',
        strength: '10 mg',
        timesPerDay: 2,
        doseQty: 1,
        form: MedForm.tablet,
        mealRelation: MealRelation.sesudahMakan,
      ),
    );
    await tester.pumpWidget(
      await appScope(
        prefs: {SettingsKeys.onboardingDone: true},
        extraOverrides: [
          labelScannerProvider.overrideWith((ref) async => scanner),
        ],
      ),
    );
    await settle(tester);

    // Patient -> medication form.
    await tester.tap(find.text('Pasien'));
    await settle(tester);
    await tester.tap(find.text('Tambah pasien'));
    await settle(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Budi');
    await tester.tap(find.text('Simpan'));
    await settle(tester);
    await tester.tap(find.text('Budi'));
    await settle(tester);
    await tester.tap(find.text('Tambah obat').first);
    await settle(tester);

    expect(
      find.text('Hasil scan hanya draf. Periksa sebelum menyimpan.'),
      findsOneWidget,
    );
    expect(find.text('Periksa kembali'), findsNothing);

    await tester.tap(find.text('Scan etiket'));
    await settle(tester);
    await tester.tap(find.text('Pilih dari galeri'));
    await settle(tester);

    // Every filled field carries the review marker (icon + text).
    expect(find.text('Periksa kembali'), findsNWidgets(6));
    expect(find.byIcon(Icons.auto_awesome), findsNWidgets(6));
    expect(find.text('Amlodipine'), findsOneWidget);
    expect(find.text('10 mg'), findsOneWidget);

    // Touching a field clears its marker.
    await tester.tap(find.byType(TextFormField).at(1));
    await settle(tester);
    expect(find.text('Periksa kembali'), findsNWidgets(5));
    await unmount(tester);
  });
}

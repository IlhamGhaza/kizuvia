import 'dart:math' as math;

import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/features/scan/domain/parsed_label.dart';

/// Rule-based parser for pharmacy labels / strips (docs/06 §4-5). Pure Dart.
/// It only reads what is printed; it never suggests a drug or a dose
/// (safety rule 1): the dictionary is used solely to fix OCR spelling.
class LabelParser {
  LabelParser({Iterable<String> drugNames = const []})
    : _drugs = [
        for (final n in drugNames)
          if (n.trim().isNotEmpty) n.trim().toLowerCase(),
      ];

  /// Below this a field is dropped instead of guessed.
  static const minConfidence = 0.6;

  final List<String> _drugs;

  // ---------------------------------------------------------------- normalise

  /// Fixes common OCR slips inside numbers/units and lower-cases for matching.
  static String normalize(String text) {
    var t = text.replaceAll('\r', '\n');
    t = t.replaceAllMapped(
      RegExp(r'(\d)\s*rng\b', caseSensitive: false),
      (m) => '${m[1]} mg',
    );
    t = t.replaceAllMapped(
      RegExp(r'(\d)\s*m\s+g\b', caseSensitive: false),
      (m) => '${m[1]} mg',
    );
    t = t.replaceAllMapped(RegExp(r'(\d)[oO](?=\d)'), (m) => '${m[1]}0');
    t = t.replaceAllMapped(
      RegExp(r'(?<=\d)[oO](?=\D|$)(?=\s?(?:mg|mcg|ml|g)\b)'),
      (_) => '0',
    );
    t = t.replaceAllMapped(RegExp(r'(\d)[lI](?=\d)'), (m) => '${m[1]}1');
    t = t.replaceAll('×', 'x').replaceAll('½', '1/2');
    return t;
  }

  // -------------------------------------------------------------------- parse

  ParsedLabel parse(String rawText) {
    final text = normalize(rawText);
    final lower = text.toLowerCase();
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final conf = <String, double>{};

    // Strength: "10 mg", "500mg", "2,5 mg", "5 ml".
    String? strength;
    final strengthMatch = RegExp(r'(\d+(?:[.,]\d+)?)\s?(mg|mcg|g|ml|iu)\b')
        .firstMatch(lower);
    if (strengthMatch != null) {
      strength =
          '${strengthMatch[1]!.replaceAll('.', ',')} ${strengthMatch[2]}';
      conf['strength'] = 0.9;
    }

    // Frequency: "3 x 1", "3x sehari", "2dd1", "2 dd 1".
    int? times;
    double? dosePerTime;
    final dd = RegExp(r'\b(\d)\s*dd\s*(\d(?:[.,]\d)?|1/2)?').firstMatch(lower);
    final xSehari = RegExp(r'\b(\d)\s*x\s*(?:sehari|/\s*hari|per\s*hari)')
        .firstMatch(lower);
    final xN = RegExp(r'\b(\d)\s*x\s*(\d(?:[.,]\d)?|1/2)\b').firstMatch(lower);
    final m = dd ?? xSehari ?? xN;
    if (m != null) {
      final n = int.parse(m[1]!);
      if (n >= 1 && n <= 6) {
        times = n;
        conf['timesPerDay'] = m == xSehari ? 0.9 : 0.8;
        if (m != xSehari && m.groupCount >= 2 && m[2] != null) {
          dosePerTime = _qty(m[2]!);
        }
      }
    }

    // Dose per time + form: "1/2 tablet", "1 kapsul", "5 ml", "2 sdt".
    double? doseQty;
    MedForm? form;
    final doseMatch = RegExp(
      r'(\d+(?:[.,]\d+)?|1/2)\s?(tablet|tab|kaplet|kapsul|kaps|sdt|sdm|tetes)\b',
    ).firstMatch(lower);
    if (doseMatch != null) {
      doseQty = _qty(doseMatch[1]!);
      form = _form(doseMatch[2]!);
      conf['doseQty'] = 0.75;
      conf['form'] = 0.75;
    } else if (dosePerTime != null) {
      doseQty = dosePerTime;
      conf['doseQty'] = 0.6;
    }
    if (form == null) {
      final f = RegExp(
        r'\b(tablet|tab|kaplet|kapsul|kaps|sirup|syrup|tetes|salep|injeksi|inhaler)\b',
      ).firstMatch(lower);
      if (f != null) {
        form = _form(f[1]!);
        conf['form'] = 0.7;
      }
    }

    // Meal relation.
    MealRelation? meal;
    final mealText = RegExp(r'\b(sebelum|sesudah|setelah|bersama)\s+makan\b')
        .firstMatch(lower);
    if (mealText != null) {
      meal = switch (mealText[1]) {
        'sebelum' => MealRelation.sebelumMakan,
        'bersama' => MealRelation.bersamaMakan,
        _ => MealRelation.sesudahMakan,
      };
      conf['mealRelation'] = 0.9;
    } else if (RegExp(r'(?<![a-z])a\.c\.?(?![a-z])').hasMatch(lower)) {
      meal = MealRelation.sebelumMakan;
      conf['mealRelation'] = 0.7;
    } else if (RegExp(r'(?<![a-z])p\.c\.?(?![a-z])').hasMatch(lower)) {
      meal = MealRelation.sesudahMakan;
      conf['mealRelation'] = 0.7;
    }

    // As needed (PRN).
    bool? prn;
    if (RegExp(r'\b(bila|jika|apabila)\s+perlu\b|(?<![a-z])p\.?r\.?n(?![a-z])')
        .hasMatch(lower)) {
      prn = true;
      conf['isPrn'] = 0.9;
    }

    // Name.
    String? name;
    final nameResult = _findName(lines, strengthMatch?.group(0));
    if (nameResult != null) {
      name = nameResult.$1;
      conf['name'] = nameResult.$2;
    }

    bool keep(String field) => (conf[field] ?? 0) >= minConfidence;
    return ParsedLabel(
      rawText: rawText,
      confidence: conf,
      name: keep('name') ? name : null,
      strength: keep('strength') ? strength : null,
      timesPerDay: keep('timesPerDay') ? times : null,
      doseQty: keep('doseQty') ? doseQty : null,
      form: keep('form') ? form : null,
      mealRelation: keep('mealRelation') ? meal : null,
      isPrn: keep('isPrn') ? prn : null,
    );
  }

  // ------------------------------------------------------------------ helpers

  static double? _qty(String s) {
    if (s == '1/2') return 0.5;
    return double.tryParse(s.replaceAll(',', '.'));
  }

  static MedForm? _form(String unit) => switch (unit) {
    'tablet' || 'tab' || 'kaplet' => MedForm.tablet,
    'kapsul' || 'kaps' => MedForm.kapsul,
    'sdt' || 'sdm' || 'sirup' || 'syrup' => MedForm.sirup,
    'tetes' => MedForm.tetes,
    'salep' => MedForm.salep,
    'injeksi' => MedForm.injeksi,
    'inhaler' => MedForm.inhaler,
    _ => null,
  };

  static const _noise = {
    'tablet',
    'tab',
    'kaplet',
    'kapsul',
    'kaps',
    'sirup',
    'syrup',
    'tetes',
    'obat',
    'dosis',
    'aturan',
    'pakai',
    'sehari',
    'sesudah',
    'sebelum',
    'setelah',
    'makan',
    'bersama',
    'minum',
    'tgl',
    'exp',
    'bpom',
    'apotek',
    'racikan',
    'jumlah',
    'nama',
    'pasien',
    'bila',
    'perlu',
    'jika',
    'untuk',
    'hari',
    'kali',
    'per',
  };

  /// (name, confidence) or null.
  (String, double)? _findName(List<String> lines, String? strengthText) {
    // 1. Spell-correct against the generic-name dictionary.
    if (_drugs.isNotEmpty) {
      String? best;
      var bestDist = 99;
      for (final line in lines) {
        for (final token in line.toLowerCase().split(RegExp(r'[^a-z]+'))) {
          if (token.length < 5) continue;
          for (final d in _drugs) {
            final first = d.split(' ').first;
            final dist = _levenshtein(token, first);
            if (dist < bestDist && dist <= 2) {
              bestDist = dist;
              best = d;
            }
          }
        }
      }
      if (best != null) {
        return (_titleCase(best), bestDist <= 1 ? 0.9 : 0.7);
      }
    }
    // 2. Unknown drug: the line that carries the strength, minus noise.
    if (strengthText != null) {
      for (final line in lines) {
        if (!line.toLowerCase().contains(strengthText)) continue;
        final words = line
            .toLowerCase()
            .replaceAll(strengthText, ' ')
            .split(RegExp(r'[^a-z]+'))
            .where((w) => w.length >= 3 && !_noise.contains(w))
            .take(3)
            .toList();
        if (words.isNotEmpty) return (_titleCase(words.join(' ')), 0.65);
      }
    }
    return null;
  }

  static String _titleCase(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        cur[j] = math.min(
          math.min(cur[j - 1] + 1, prev[j] + 1),
          prev[j - 1] + cost,
        );
      }
      prev = cur;
    }
    return prev[b.length];
  }
}

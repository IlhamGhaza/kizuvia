import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/features/scan/domain/label_parser.dart';
import 'package:kizuvia/features/scan/domain/parsed_label.dart';

/// 30+ label texts (patient and pharmacy names removed). docs/06 §8.
void main() {
  final drugs = File('assets/drug_names.txt').readAsLinesSync();
  final parser = LabelParser(drugNames: drugs);

  test('dictionary file is non-empty and has no dose/indication data', () {
    expect(drugs.length, greaterThan(50));
    expect(drugs.every((d) => !RegExp(r'\d').hasMatch(d)), isTrue);
  });

  group('docs examples', () {
    test('AMLODIPINE 10 MG / 1 x 1 tablet / sesudah makan', () {
      final p = parser.parse('AMLODIPINE 10 MG\n1 x 1 tablet\nsesudah makan');
      expect(p.name, 'Amlodipine');
      expect(p.strength, '10 mg');
      expect(p.timesPerDay, 1);
      expect(p.doseQty, 1);
      expect(p.form, MedForm.tablet);
      expect(p.mealRelation, MealRelation.sesudahMakan);
    });

    test('Paracetamol 500mg 3dd1 bila perlu -> PRN', () {
      final p = parser.parse('Paracetamol 500mg 3dd1 bila perlu');
      expect(p.name, 'Paracetamol');
      expect(p.strength, '500 mg');
      expect(p.timesPerDay, 3);
      expect(p.isPrn, isTrue);
    });

    test('1/2 tab -> 0.5', () {
      final p = parser.parse('Bisoprolol 5 mg\n1/2 tab 1 x sehari');
      expect(p.doseQty, 0.5);
      expect(p.form, MedForm.tablet);
      expect(p.timesPerDay, 1);
    });

    test('garbage text -> all null, no crash', () {
      final p = parser.parse('@@ ## ~~ lorem ipsum 12345 !!');
      expect(p.hasAnyField, isFalse);
      expect(p.name, isNull);
      expect(parser.parse('').hasAnyField, isFalse);
    });
  });

  group('strength', () {
    final cases = {
      'Metformin 500 mg': '500 mg',
      'METFORMIN 850MG': '850 mg',
      'Digoxin 0,25 mg': '0,25 mg',
      'Digoxin 0.25 mg': '0,25 mg',
      'Amoxicillin 125 mg/5 ml': '125 mg',
      'Vitamin D 1000 iu': '1000 iu',
      'Levothyroxine 100 mcg': '100 mcg',
      'Atorvastatin 20rng': '20 mg',
      'Simvastatin 2O mg': '20 mg',
      'Captopril 12.5 mg': '12,5 mg',
      'Candesartan 16 m g': '16 mg',
    };
    cases.forEach((input, expected) {
      test(input, () => expect(parser.parse(input).strength, expected));
    });
  });

  group('frequency', () {
    final cases = {
      '3 x 1 tablet': 3,
      '3x sehari 1 tablet': 3,
      '2dd1': 2,
      '2 dd 1 kapsul': 2,
      '1 x 1': 1,
      '4 x sehari': 4,
      '2 × 1 tab': 2,
    };
    cases.forEach((input, expected) {
      test(input, () => expect(parser.parse(input).timesPerDay, expected));
    });

    test('implausible count is dropped', () {
      expect(parser.parse('9 x 1').timesPerDay, isNull);
    });
  });

  group('dose per time and form', () {
    test('1 kapsul', () {
      final p = parser.parse('Omeprazole 20 mg\n1 x 1 kapsul');
      expect(p.doseQty, 1);
      expect(p.form, MedForm.kapsul);
    });
    test('2 sdt -> sirup', () {
      final p = parser.parse('Ambroxol sirup 3 x 2 sdt');
      expect(p.doseQty, 2);
      expect(p.form, MedForm.sirup);
    });
    test('1 1/2 style half tablet', () {
      expect(parser.parse('Warfarin 2 mg 1/2 tablet').doseQty, 0.5);
    });
    test('dose from "2dd1" when no unit', () {
      final p = parser.parse('2dd1');
      expect(p.doseQty, 1);
      expect(p.confidence['doseQty'], 0.6);
    });
    test('decimal dose with comma', () {
      expect(parser.parse('Clopidogrel 75 mg 1,5 tablet').doseQty, 1.5);
    });
  });

  group('meal relation', () {
    final cases = {
      'sesudah makan': MealRelation.sesudahMakan,
      'Sebelum Makan': MealRelation.sebelumMakan,
      'setelah makan': MealRelation.sesudahMakan,
      'bersama makan': MealRelation.bersamaMakan,
      'a.c.': MealRelation.sebelumMakan,
      'p.c.': MealRelation.sesudahMakan,
    };
    cases.forEach((input, expected) {
      test(input, () => expect(parser.parse(input).mealRelation, expected));
    });

    test('"ac" inside a word is not a meal marker', () {
      expect(parser.parse('Paracetamol').mealRelation, isNull);
    });
  });

  group('as needed', () {
    for (final s in [
      'bila perlu',
      'jika perlu',
      'prn',
      'p.r.n',
      'Bila Perlu nyeri',
    ]) {
      test(s, () => expect(parser.parse(s).isPrn, isTrue));
    }
    test('not PRN when absent (null, not false)', () {
      expect(parser.parse('Amlodipine 5 mg 1 x 1').isPrn, isNull);
    });
  });

  group('name', () {
    test('OCR typo within distance 2 is corrected', () {
      final p = parser.parse('AMLODlPINE 10 MG');
      expect(p.name, 'Amlodipine');
    });
    test('unknown drug falls back to the strength line (confidence 0.65)', () {
      final p = parser.parse('Nama: Budi\nZorvexin 250 mg\n3 x 1');
      expect(p.name, 'Zorvexin');
      expect(p.confidence['name'], 0.65);
    });
    test('patient name line is not mistaken for the drug', () {
      final p = parser.parse('Budi Santoso\nMetformin 500 mg');
      expect(p.name, 'Metformin');
    });
    test('multi-word dictionary entry', () {
      expect(parser.parse('Asam mefenamat 500 mg').name, 'Asam Mefenamat');
    });
    test('without a dictionary, unknown names still use the heuristic', () {
      final p = LabelParser().parse('Zorvexin 250 mg');
      expect(p.name, 'Zorvexin');
    });
    test('no strength and no dictionary hit -> name left empty', () {
      expect(parser.parse('Jl. Merdeka no 5\nApotek Sehat').name, isNull);
    });
  });

  group('full labels', () {
    test('typical pharmacy label', () {
      final p = parser.parse(
        'APOTEK SEHAT\nNama: Bp. B\nCLOPIDOGREL 75 MG\n1 x 1 tablet\nsesudah makan\nED: 12/2027',
      );
      expect(p.name, 'Clopidogrel');
      expect(p.strength, '75 mg');
      expect(p.timesPerDay, 1);
      expect(p.mealRelation, MealRelation.sesudahMakan);
      expect(p.rawText, contains('APOTEK SEHAT'));
    });

    test('strip pack text', () {
      final p = parser.parse('Cetirizine 10 mg\nKaplet\n1 x sehari malam hari');
      expect(p.name, 'Cetirizine');
      expect(p.form, MedForm.tablet);
      expect(p.timesPerDay, 1);
    });

    test('syrup label', () {
      final p = parser.parse('Salbutamol sirup 2 mg/5 ml\n3 x sehari 1 sdt');
      expect(p.form, MedForm.sirup);
      expect(p.timesPerDay, 3);
      expect(p.doseQty, 1);
    });
  });

  test('every returned field has confidence >= 0.6', () {
    final p = parser.parse('Amlodipine 10 mg 1 x 1 tablet sesudah makan');
    for (final e in {
      'name': p.name,
      'strength': p.strength,
      'timesPerDay': p.timesPerDay,
      'doseQty': p.doseQty,
      'form': p.form,
      'mealRelation': p.mealRelation,
    }.entries) {
      if (e.value != null) {
        expect(p.confidence[e.key], greaterThanOrEqualTo(0.6), reason: e.key);
      }
    }
  });
}

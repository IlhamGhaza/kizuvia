import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/notifications/occurrence_calculator.dart';
import 'package:kizuvia/features/dose_log/domain/dose_log.dart';
import 'package:kizuvia/features/dose_log/domain/resolved_dose.dart';
import 'package:kizuvia/features/medications/domain/med_schedule.dart';
import 'package:kizuvia/features/medications/domain/medication.dart';
import 'package:kizuvia/features/reports/data/report_pdf.dart';
import 'package:kizuvia/features/reports/domain/report_builder.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

ScheduleContext ctx(String id, String name, List<String> times) =>
    ScheduleContext(
      patientName: 'Budi',
      medication: Medication(
        id: 'm$id',
        patientId: 'p1',
        name: name,
        strength: '10 mg',
        startDate: DateTime.utc(2026),
      ),
      schedule: MedSchedule(id: id, medicationId: 'm$id', times: times),
    );

DateTime wib(int d, int h) => DateTime.utc(2026, 3, d, h - 7);

DoseLog log(String sid, DateTime at, DoseStatus s) => DoseLog(
  id: '$sid${at.millisecondsSinceEpoch}${s.name}',
  scheduleId: sid,
  patientId: 'p1',
  scheduledAt: at,
  status: s,
  createdAt: at,
);

void main() {
  setUpAll(tzdata.initializeTimeZones);

  final contexts = [
    ctx('a', 'Amlodipine', ['07:00']),
    ctx('b', 'Clopidogrel', ['07:00', '19:00']),
  ];

  ReportData report(List<DoseLog> logs) => buildReport(
    patientName: 'Budi',
    from: DateTime(2026, 3, 2),
    to: DateTime(2026, 3, 3),
    doses: resolveDoses(
      contexts: contexts,
      logs: logs,
      from: wib(2, 0),
      to: wib(3, 23),
      now: wib(4, 0), // everything is in the past
    ),
  );

  test('counts taken / skipped / missed per medication, sorted by name', () {
    final r = report([
      log('a', wib(2, 7), DoseStatus.taken),
      log('a', wib(3, 7), DoseStatus.skipped),
      log('b', wib(2, 7), DoseStatus.taken),
      log('b', wib(2, 19), DoseStatus.taken),
      log('b', wib(3, 7), DoseStatus.taken),
      // b 3 Mar 19:00 has no log -> missed
    ]);
    expect(r.rows.map((x) => x.name), [
      'Amlodipine 10 mg',
      'Clopidogrel 10 mg',
    ]);
    final a = r.rows[0];
    expect((a.taken, a.skipped, a.missed), (1, 1, 0));
    final b = r.rows[1];
    expect((b.taken, b.skipped, b.missed), (3, 0, 1));
    expect(b.adherence, 0.75);
    expect(b.schedule, '07:00, 19:00');
    expect(r.taken, 4);
    expect(r.missed, 1);
    expect(r.adherenceOverall, closeTo(4 / 6, 1e-9));
  });

  test('entries are chronological', () {
    final r = report(const []);
    final times = r.entries.map((e) => e.at).toList();
    expect([...times]..sort(), times);
    expect(r.entries.every((e) => e.status == DoseStatus.missed), isTrue);
  });

  test('upcoming doses are not counted', () {
    final r = buildReport(
      patientName: 'Budi',
      from: DateTime(2026, 3, 2),
      to: DateTime(2026, 3, 2),
      doses: resolveDoses(
        contexts: contexts,
        logs: const [],
        from: wib(2, 0),
        to: wib(2, 23),
        now: wib(2, 6), // before 07:00
      ),
    );
    expect(r.entries, isEmpty);
    expect(r.adherenceOverall, isNull);
  });

  test('PDF is generated (valid header, non-trivial size)', () async {
    final l10n = lookupAppLocalizations(const Locale('id'));
    final bytes = await buildReportPdf(
      report([log('a', wib(2, 7), DoseStatus.taken)]),
      l10n,
      generatedAt: DateTime(2026, 3, 4),
    );
    expect(utf8.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(bytes.length, greaterThan(1500));
  });

  test('PDF with no data still builds', () async {
    final l10n = lookupAppLocalizations(const Locale('id'));
    final bytes = await buildReportPdf(
      buildReport(
        patientName: 'Budi',
        from: DateTime(2026, 3, 2),
        to: DateTime(2026, 3, 3),
        doses: const [],
      ),
      l10n,
      generatedAt: DateTime(2026, 3, 4),
    );
    expect(utf8.decode(bytes.sublist(0, 5)), '%PDF-');
  });
}

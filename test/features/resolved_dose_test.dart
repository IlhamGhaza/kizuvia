import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/notifications/occurrence_calculator.dart';
import 'package:kizuvia/features/dose_log/domain/dose_log.dart';
import 'package:kizuvia/features/dose_log/domain/resolved_dose.dart';
import 'package:kizuvia/features/medications/domain/med_schedule.dart';
import 'package:kizuvia/features/medications/domain/medication.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

DateTime wib(int h, [int m = 0]) => DateTime.utc(2026, 3, 2, h - 7, m);

final ctx = ScheduleContext(
  patientName: 'Budi',
  medication: Medication(
    id: 'm1',
    patientId: 'p1',
    name: 'X',
    startDate: DateTime.utc(2026),
  ),
  schedule: const MedSchedule(
    id: 's1',
    medicationId: 'm1',
    times: ['07:00', '13:00', '19:00'],
  ),
);

DoseLog log(DateTime at, DoseStatus s) => DoseLog(
  id: '${at.hour}${s.name}',
  scheduleId: 's1',
  patientId: 'p1',
  scheduledAt: at,
  status: s,
  createdAt: at,
);

List<DoseView> views(DateTime now, [List<DoseLog> logs = const []]) =>
    resolveDoses(
      contexts: [ctx],
      logs: logs,
      from: wib(0),
      to: wib(23, 59),
      now: now,
    ).map((d) => d.view).toList();

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('before the first dose: all upcoming', () {
    expect(views(wib(6)), everyElement(DoseView.upcoming));
  });

  test('within grace is "now"; after grace without log is missed', () {
    expect(views(wib(7, 10)), [
      DoseView.now,
      DoseView.upcoming,
      DoseView.upcoming,
    ]);
    expect(views(wib(7, 31)), [
      DoseView.missed,
      DoseView.upcoming,
      DoseView.upcoming,
    ]);
  });

  test('taken beats skipped beats missed', () {
    final at = wib(7);
    expect(
      views(wib(8), [
        log(at, DoseStatus.missed),
        log(at, DoseStatus.taken),
      ]).first,
      DoseView.taken,
    );
    expect(
      views(wib(8), [
        log(at, DoseStatus.missed),
        log(at, DoseStatus.skipped),
      ]).first,
      DoseView.skipped,
    );
    expect(views(wib(8), [log(at, DoseStatus.missed)]).first, DoseView.missed);
  });

  test('final status is null while upcoming/now', () {
    final d = resolveDoses(
      contexts: [ctx],
      logs: const [],
      from: wib(0),
      to: wib(23, 59),
      now: wib(7, 5),
    );
    expect(d.first.finalStatus, isNull);
    expect(d.first.view, DoseView.now);
  });
}

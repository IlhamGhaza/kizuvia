import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/notifications/occurrence_calculator.dart';
import 'package:kizuvia/features/medications/domain/med_schedule.dart';
import 'package:kizuvia/features/medications/domain/medication.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

ScheduleContext ctx({
  String id = 's1',
  List<String> times = const ['07:00', '13:00', '19:00'],
  List<int> days = const [1, 2, 3, 4, 5, 6, 7],
  String zone = 'Asia/Jakarta',
  DateTime? start,
  DateTime? end,
  String patientId = 'p1',
}) => ScheduleContext(
  patientName: 'Budi',
  medication: Medication(
    id: 'm-$id',
    patientId: patientId,
    name: 'X',
    startDate: start ?? DateTime.utc(2020),
    endDate: end,
  ),
  schedule: MedSchedule(
    id: id,
    medicationId: 'm-$id',
    times: times,
    daysOfWeek: days,
    timezone: zone,
  ),
);

DateTime wib(int d, int h, [int m = 0]) =>
    DateTime.utc(2026, 3, d, h - 7, m); // March 2026, Asia/Jakarta = UTC+7

void main() {
  setUpAll(tzdata.initializeTimeZones);

  // 2026-03-02 is a Monday.
  final from = wib(2, 0);

  test('3x daily over 48h -> 6 occurrences', () {
    final r = expandOccurrences(
      schedules: [ctx()],
      from: from,
      to: from
          .add(const Duration(hours: 48))
          .subtract(const Duration(minutes: 1)),
    );
    expect(r, hasLength(6));
    expect(r.first.scheduledAt, wib(2, 7));
    expect(r.last.scheduledAt, wib(3, 19));
  });

  test('days_of_week {1,3,5} -> only Mon/Wed/Fri', () {
    final r = expandOccurrences(
      schedules: [
        ctx(times: ['08:00'], days: [1, 3, 5]),
      ],
      from: from,
      to: from.add(const Duration(days: 7)),
    );
    final wd = r.map(
      (o) => tz.TZDateTime.from(
        o.scheduledAt,
        tz.getLocation('Asia/Jakarta'),
      ).weekday,
    );
    expect(wd, [1, 3, 5]);
  });

  test('end_date today 13:00 -> 19:00 not created', () {
    final r = expandOccurrences(
      schedules: [ctx(end: wib(2, 13))],
      from: from,
      to: wib(2, 23, 59),
    );
    expect(r.map((o) => o.scheduledAt), [wib(2, 7), wib(2, 13)]);
  });

  test('start_date in the future is respected', () {
    final r = expandOccurrences(
      schedules: [
        ctx(times: ['08:00'], start: wib(3, 0)),
      ],
      from: from,
      to: wib(3, 23, 59),
    );
    expect(r.map((o) => o.scheduledAt), [wib(3, 8)]);
  });

  test('crosses midnight: 23:30 and 00:30', () {
    final r = expandOccurrences(
      schedules: [
        ctx(times: ['23:30', '00:30']),
      ],
      from: wib(2, 22),
      to: wib(3, 2),
    );
    expect(r.map((o) => o.scheduledAt), [wib(2, 23, 30), wib(3, 0, 30)]);
  });

  test('Asia/Makassar keeps its own wall-clock (UTC+8) on a WIB device', () {
    final r = expandOccurrences(
      schedules: [
        ctx(times: ['08:00'], zone: 'Asia/Makassar'),
      ],
      from: from,
      to: wib(2, 23, 59),
    );
    expect(r.single.scheduledAt, DateTime.utc(2026, 3, 2, 0)); // 08:00 WITA
  });

  test('occurrences with a dose_log are skipped', () {
    final logged = {occurrenceKey('s1', wib(2, 7))};
    final r = expandOccurrences(
      schedules: [ctx()],
      from: from,
      to: wib(2, 23, 59),
      loggedKeys: logged,
    );
    expect(r.map((o) => o.scheduledAt), [wib(2, 13), wib(2, 19)]);
  });

  test('limit keeps the nearest N (iOS cap)', () {
    final r = expandOccurrences(
      schedules: [
        ctx(times: ['07:00', '08:00', '09:00']),
      ],
      from: from,
      to: from.add(const Duration(days: 30)),
      limit: 60,
    );
    expect(r, hasLength(60));
    expect(
      r.last.scheduledAt.isBefore(wib(2, 0).add(const Duration(days: 30))),
      isTrue,
    );
  });

  test('same patient + same minute -> one notification group', () {
    final r = expandOccurrences(
      schedules: [
        ctx(id: 'a', times: ['07:00']),
        ctx(id: 'b', times: ['07:00']),
        ctx(id: 'c', times: ['07:00'], patientId: 'p2'),
      ],
      from: from,
      to: wib(2, 23, 59),
    );
    final g = groupOccurrences(r);
    expect(g, hasLength(2));
    expect(g.firstWhere((x) => x.patientId == 'p1').scheduleIds, ['a', 'b']);
  });

  test('notification id is deterministic, positive 31-bit', () {
    final a = notificationIdFor('s1', wib(2, 7));
    expect(a, notificationIdFor('s1', wib(2, 7)));
    expect(a, isNot(notificationIdFor('s1', wib(2, 8))));
    expect(a, inInclusiveRange(0, 0x7fffffff));
  });
}

import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/notifications/alarm_scheduler.dart';
import 'package:kizuvia/core/notifications/dose_actions.dart';
import 'package:kizuvia/core/notifications/notification_gateway.dart';
import 'package:kizuvia/core/notifications/notification_payload.dart';
import 'package:kizuvia/core/notifications/occurrence_calculator.dart';
import 'package:kizuvia/features/dose_log/data/dose_log_repository.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/features/medications/domain/med_schedule.dart';
import 'package:kizuvia/features/medications/domain/medication.dart';
import 'package:kizuvia/features/patients/data/patient_repository.dart';
import 'package:kizuvia/features/patients/domain/patient.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

class FakeGateway implements NotificationGateway {
  final Map<int, PlannedNotification> pending = {};
  final List<int> cancelled = [];

  @override
  Future<void> schedule(PlannedNotification n) async => pending[n.id] = n;

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    pending.remove(id);
  }
}

/// 2026-03-02 00:00 WIB.
final base = DateTime.utc(2026, 3, 1, 17);

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late FakeGateway gateway;
  late AppLocalizations l10n;
  late MedicationRepository meds;
  late String patientId;

  setUpAll(() {
    tzdata.initializeTimeZones();
    l10n = lookupAppLocalizations(const Locale('id'));
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(base);
    gateway = FakeGateway();
    meds = MedicationRepository(db, clock);
    patientId = (await PatientRepository(
      db,
      clock,
    ).save(const Patient(id: '', name: 'Budi'))).valueOrNull!.id;
  });
  tearDown(() => db.close());

  AlarmScheduler scheduler({int max = 200, bool followups = true}) =>
      AlarmScheduler(
        db: db,
        clock: clock,
        gateway: gateway,
        l10n: l10n,
        maxOccurrences: max,
        includeFollowups: followups,
      );

  Future<MedicationWithSchedule> addMed({
    String name = 'Amlodipine',
    List<String> times = const ['07:00', '19:00'],
  }) async => (await meds.save(
    Medication(
      id: '',
      patientId: patientId,
      name: name,
      strength: '10 mg',
      form: MedForm.tablet,
      startDate: DateTime.utc(2026, 1, 1),
    ),
    MedSchedule(id: '', medicationId: '', times: times),
  )).valueOrNull!;

  test(
    '2 times/day over 48h -> 4 alarms + 4 follow-ups, rows recorded',
    () async {
      await addMed();
      await scheduler().rescheduleAll();
      final alarms = gateway.pending.values.where(
        (n) => n.kind == NotificationKind.doseAlarm,
      );
      final follow = gateway.pending.values.where(
        (n) => n.kind == NotificationKind.doseFollowup,
      );
      expect(alarms, hasLength(4));
      expect(follow, hasLength(4));
      expect(await db.select(db.scheduledNotifications).get(), hasLength(8));
      final first = alarms.reduce((a, b) => a.at.isBefore(b.at) ? a : b);
      expect(first.at, DateTime.utc(2026, 3, 2, 0)); // 07:00 WIB
      expect(first.title, contains('Budi'));
      expect(first.body, contains('Amlodipine 10 mg'));
    },
  );

  test('reschedule is idempotent: no duplicate rows or cancels', () async {
    await addMed();
    await scheduler().rescheduleAll();
    final ids = gateway.pending.keys.toSet();
    await scheduler().rescheduleAll();
    expect(gateway.pending.keys.toSet(), ids);
    expect(gateway.cancelled, isEmpty);
    expect(await db.select(db.scheduledNotifications).get(), hasLength(8));
  });

  test('deleting the medication cancels its future alarms', () async {
    final m = await addMed();
    await scheduler().rescheduleAll();
    await meds.delete(m.medication.id);
    await scheduler().rescheduleAll();
    expect(gateway.pending, isEmpty);
    expect(gateway.cancelled, hasLength(8));
    expect(await db.select(db.scheduledNotifications).get(), isEmpty);
  });

  test('already-logged occurrence is not scheduled', () async {
    final m = await addMed(times: const ['07:00']);
    await DoseLogRepository(db, clock).record(
      scheduleId: m.schedule!.id,
      scheduledAt: DateTime.utc(2026, 3, 2, 0),
      status: DoseStatus.taken,
    );
    await scheduler(followups: false).rescheduleAll();
    expect(gateway.pending, hasLength(1)); // only 3 Mar 07:00
    expect(gateway.pending.values.single.at, DateTime.utc(2026, 3, 3, 0));
  });

  test('past rows are forgotten but never cancelled (tray stays)', () async {
    await addMed(times: const ['07:00']);
    await scheduler(followups: false).rescheduleAll();
    clock.current = DateTime.utc(2026, 3, 2, 0, 30); // alarm has fired
    await scheduler(followups: false).rescheduleAll();
    expect(gateway.cancelled, isEmpty);
    final rows = await db.select(db.scheduledNotifications).get();
    expect(rows.every((r) => r.scheduledAt.isAfter(clock.now())), isTrue);
  });

  test('iOS style: cap on occurrences and no follow-ups', () async {
    await addMed(times: const ['07:00', '08:00', '09:00']);
    await scheduler(max: 4, followups: false).rescheduleAll();
    expect(gateway.pending, hasLength(4));
  });

  test('same minute, two medications -> one grouped notification', () async {
    await addMed(name: 'Amlodipine', times: const ['07:00']);
    await addMed(name: 'Clopidogrel', times: const ['07:00']);
    await scheduler(followups: false).rescheduleAll();
    expect(gateway.pending, hasLength(2)); // 2 days, grouped each
    final n = gateway.pending.values.first;
    expect(n.body, contains('2 obat'));
    expect(n.body, contains('Amlodipine'));
    expect(n.body, contains('Clopidogrel'));
  });

  test('privacy mode hides patient and medication names', () async {
    await addMed(times: const ['07:00']);
    await scheduler(followups: false).rescheduleAll(privacyLockScreen: true);
    for (final n in gateway.pending.values) {
      expect('${n.title} ${n.body}', isNot(contains('Budi')));
      expect('${n.title} ${n.body}', isNot(contains('Amlodipine')));
    }
  });

  test('payload carries ids only', () async {
    final m = await addMed(times: const ['07:00']);
    await scheduler(followups: false).rescheduleAll();
    final p = DosePayload.decode(gateway.pending.values.first.payload);
    expect(p.scheduleIds, [m.schedule!.id]);
    expect(gateway.pending.values.first.payload, isNot(contains('Budi')));
    expect(gateway.pending.values.first.payload, isNot(contains('Amlodipine')));
  });

  group('DoseActions', () {
    late DoseActions actions;
    late MedicationWithSchedule med;

    setUp(() async {
      med = await addMed(times: const ['07:00']);
      await scheduler().rescheduleAll();
      actions = DoseActions(db: db, clock: clock, gateway: gateway, l10n: l10n);
    });

    DosePayload payload() => DosePayload(
      scheduleIds: [med.schedule!.id],
      at: DateTime.utc(2026, 3, 2, 0),
      patientId: patientId,
    );

    test('taken logs, and cancels alarm + follow-up of that dose', () async {
      final before = gateway.pending.length;
      await actions.confirm(payload(), DoseStatus.taken);
      expect(gateway.pending.length, before - 2);
      final logs = await db.select(db.doseLogs).get();
      expect(logs.single.status, DoseStatus.taken);
    });

    test('rescheduling after confirm does not bring the alarm back', () async {
      await actions.confirm(payload(), DoseStatus.skipped);
      await scheduler().rescheduleAll();
      expect(
        gateway.pending.values.where(
          (n) => n.at == DateTime.utc(2026, 3, 2, 0),
        ),
        isEmpty,
      );
    });

    test('taken with low stock posts one stock reminder', () async {
      final low = (await meds.save(
        med.medication.copyWith(stockQty: 3, refillThresholdDays: 3),
        med.schedule,
      )).valueOrNull!;
      await actions.confirm(
        DosePayload(
          scheduleIds: [low.schedule!.id],
          at: DateTime.utc(2026, 3, 2, 0),
          patientId: patientId,
        ),
        DoseStatus.taken,
      );
      final stock = gateway.pending.values.where(
        (n) => n.kind == NotificationKind.stock,
      );
      expect(stock, hasLength(1));
      expect(stock.single.body, contains('tinggal 2 hari'));
    });

    test('taken with plenty of stock posts no reminder', () async {
      await meds.save(med.medication.copyWith(stockQty: 100), med.schedule);
      await actions.confirm(payload(), DoseStatus.taken);
      expect(
        gateway.pending.values.where((n) => n.kind == NotificationKind.stock),
        isEmpty,
      );
    });

    test('snooze schedules +10 min and stops after 3', () async {
      clock.current = DateTime.utc(2026, 3, 2, 0, 1);
      var p = payload();
      for (var i = 0; i < 3; i++) {
        expect(await actions.snooze(p), isTrue);
        p = p.snoozed();
      }
      expect(await actions.snooze(p), isFalse);
      final snoozed = gateway.pending.values.where(
        (n) => n.at == DateTime.utc(2026, 3, 2, 0, 11),
      );
      expect(snoozed, isNotEmpty);
    });
  });

  test('describeDose formats quantity and instructions', () {
    final ctx = ScheduleContext(
      patientName: 'x',
      medication: Medication(
        id: 'm',
        patientId: 'p',
        name: 'Paracetamol',
        strength: '500 mg',
        form: MedForm.tablet,
        doseQty: 0.5,
        instructions: 'sesudah makan',
        startDate: DateTime.utc(2026),
      ),
      schedule: const MedSchedule(id: 's', medicationId: 'm', times: ['07:00']),
    );
    expect(describeDose(ctx), 'Paracetamol 500 mg — 0,5 tablet, sesudah makan');
  });
}

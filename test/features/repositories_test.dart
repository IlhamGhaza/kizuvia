import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/features/dose_log/data/dose_log_repository.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/features/medications/domain/med_schedule.dart';
import 'package:kizuvia/features/medications/domain/medication.dart';
import 'package:kizuvia/features/patients/data/patient_repository.dart';
import 'package:kizuvia/features/patients/domain/patient.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late PatientRepository patients;
  late MedicationRepository meds;
  late DoseLogRepository logs;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime.utc(2026, 3, 2, 1));
    patients = PatientRepository(db, clock);
    meds = MedicationRepository(db, clock);
    logs = DoseLogRepository(db, clock);
  });
  tearDown(() => db.close());

  Future<String> addPatient() async =>
      (await patients.save(const Patient(id: '', name: 'Budi')))
          .valueOrNull!
          .id;

  Medication med(String patientId, {double? stock, bool prn = false}) =>
      Medication(
        id: '',
        patientId: patientId,
        name: 'Amlodipine',
        startDate: DateTime.utc(2026, 3, 1),
        stockQty: stock,
        isPrn: prn,
      );

  const schedule = MedSchedule(id: '', medicationId: '', times: ['07:00']);

  test('patient save enqueues, rejects blank name, soft-deletes', () async {
    final bad = await patients.save(const Patient(id: '', name: '  '));
    expect(bad.isErr, isTrue);

    final id = await addPatient();
    expect((await patients.get(id))!.name, 'Budi');
    expect(await db.select(db.syncQueue).get(), hasLength(1));

    await patients.delete(id);
    expect(await patients.get(id), isNull);
    final q = await db.select(db.syncQueue).get();
    expect(q.map((e) => e.op), [SyncOp.upsert, SyncOp.delete]);
  });

  test('medication save validates and stores schedule', () async {
    final pid = await addPatient();
    final noTimes = await meds.save(
      med(pid),
      const MedSchedule(id: '', medicationId: '', times: []),
    );
    expect(noTimes.isErr, isTrue);

    final ok = await meds.save(med(pid, stock: 10), schedule);
    final saved = ok.valueOrNull!;
    expect(saved.schedule!.times, ['07:00']);
    expect(saved.medication.id, isNotEmpty);

    final prn = await meds.save(med(pid, prn: true), null);
    expect(prn.valueOrNull!.schedule, isNull);

    final list = await meds.watchByPatient(pid).first;
    expect(list, hasLength(2));
  });

  test('editing a schedule keeps one live schedule', () async {
    final pid = await addPatient();
    final saved = (await meds.save(med(pid), schedule)).valueOrNull!;
    await meds.save(
      saved.medication,
      saved.schedule!.copyWith(times: ['08:00', '20:00']),
    );
    final live = await (db.select(
      db.schedules,
    )..where((t) => t.deletedAt.isNull())).get();
    expect(live, hasLength(1));
    expect(live.single.times, ['08:00', '20:00']);

    // Switching to PRN removes the schedule.
    await meds.save(saved.medication.copyWith(isPrn: true), null);
    final after = await (db.select(
      db.schedules,
    )..where((t) => t.deletedAt.isNull())).get();
    expect(after, isEmpty);
  });

  test('deleting a medication hides it and its schedule contexts', () async {
    final pid = await addPatient();
    final saved = (await meds.save(med(pid), schedule)).valueOrNull!;
    expect(await meds.watchScheduleContexts().first, hasLength(1));
    await meds.delete(saved.medication.id);
    expect(await meds.get(saved.medication.id), isNull);
    expect(await meds.watchScheduleContexts().first, isEmpty);
  });

  test('taken reduces stock once; duplicate confirm is ignored', () async {
    final pid = await addPatient();
    final saved = (await meds.save(med(pid, stock: 10), schedule)).valueOrNull!;
    final sid = saved.schedule!.id;
    final at = DateTime.utc(2026, 3, 2);

    final first = await logs.record(
      scheduleId: sid,
      scheduledAt: at,
      status: DoseStatus.taken,
    );
    final second = await logs.record(
      scheduleId: sid,
      scheduledAt: at,
      status: DoseStatus.taken,
    );
    expect(first.valueOrNull, isTrue);
    expect(second.valueOrNull, isFalse);
    expect((await meds.get(saved.medication.id))!.medication.stockQty, 9);
  });

  test('skipped does not change stock', () async {
    final pid = await addPatient();
    final saved = (await meds.save(med(pid, stock: 10), schedule)).valueOrNull!;
    await logs.record(
      scheduleId: saved.schedule!.id,
      scheduledAt: DateTime.utc(2026, 3, 2),
      status: DoseStatus.skipped,
    );
    expect((await meds.get(saved.medication.id))!.medication.stockQty, 10);
  });

  test('loggedKeys covers logged occurrences', () async {
    final pid = await addPatient();
    final saved = (await meds.save(med(pid), schedule)).valueOrNull!;
    final at = DateTime.utc(2026, 3, 2);
    await logs.record(
      scheduleId: saved.schedule!.id,
      scheduledAt: at,
      status: DoseStatus.taken,
    );
    final keys = await logs.loggedKeys(
      at.subtract(const Duration(hours: 1)),
      at.add(const Duration(hours: 1)),
    );
    expect(keys, hasLength(1));
  });

  test('unknown schedule -> Err, nothing written', () async {
    final r = await logs.record(
      scheduleId: 'nope',
      scheduledAt: DateTime.utc(2026),
      status: DoseStatus.taken,
    );
    expect(r.isErr, isTrue);
    expect(await db.select(db.doseLogs).get(), isEmpty);
  });
}

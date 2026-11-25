import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/db/tables/common.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 1, 1);

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seed() async {
    await db
        .into(db.patients)
        .insert(
          PatientsCompanion.insert(
            id: 'p1',
            name: 'Budi',
            updatedAt: now,
            localUpdatedAt: now,
          ),
        );
    await db
        .into(db.medications)
        .insert(
          MedicationsCompanion.insert(
            id: 'm1',
            patientId: 'p1',
            name: 'Amlodipine',
            startDate: now,
            updatedAt: now,
            localUpdatedAt: now,
          ),
        );
    await db
        .into(db.schedules)
        .insert(
          SchedulesCompanion.insert(
            id: 's1',
            medicationId: 'm1',
            times: const ['07:00', '19:00'],
            updatedAt: now,
            localUpdatedAt: now,
          ),
        );
  }

  test('defaults and list converters round-trip', () async {
    await seed();
    final p = await db.select(db.patients).getSingle();
    expect(p.conditions, isEmpty);
    expect(p.syncStatus, SyncStatus.pending);
    final s = await db.select(db.schedules).getSingle();
    expect(s.times, ['07:00', '19:00']);
    expect(s.daysOfWeek, [1, 2, 3, 4, 5, 6, 7]);
    expect(s.timezone, 'Asia/Jakarta');
    expect(s.graceMinutes, 30);
    final m = await db.select(db.medications).getSingle();
    expect(m.doseQty, 1);
    expect(m.isPrn, isFalse);
  });

  test('dose_logs unique (schedule, scheduled_at, status)', () async {
    await seed();
    DoseLogsCompanion log(String id, DoseStatus st) => DoseLogsCompanion.insert(
      id: id,
      scheduleId: 's1',
      patientId: 'p1',
      scheduledAt: now,
      status: st,
      createdAt: now,
    );
    await db.into(db.doseLogs).insert(log('l1', DoseStatus.taken));
    await db.into(db.doseLogs).insert(log('l2', DoseStatus.missed));
    await expectLater(
      db.into(db.doseLogs).insert(log('l3', DoseStatus.taken)),
      throwsA(isA<Exception>()),
    );
  });

  test('deleting a medication cascades to schedules', () async {
    await seed();
    await (db.delete(db.medications)..where((t) => t.id.equals('m1'))).go();
    expect(await db.select(db.schedules).get(), isEmpty);
  });

  test('local tables work', () async {
    await db
        .into(db.syncQueue)
        .insert(
          SyncQueueCompanion.insert(
            targetTable: 'patients',
            rowId: 'p1',
            op: SyncOp.upsert,
            payloadJson: '{}',
            createdAt: now,
          ),
        );
    await db
        .into(db.scheduledNotifications)
        .insert(
          ScheduledNotificationsCompanion.insert(
            notificationId: const Value(1),
            scheduleId: 's1',
            scheduledAt: now,
          ),
        );
    expect((await db.select(db.syncQueue).getSingle()).attempts, 0);
    expect(await db.select(db.scheduledNotifications).get(), hasLength(1));
  });
}

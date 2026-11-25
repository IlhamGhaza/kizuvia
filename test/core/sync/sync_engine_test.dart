import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/sync/account_migrator.dart';
import 'package:kizuvia/core/sync/sync_engine.dart';
import 'package:kizuvia/core/sync/sync_remote.dart';
import 'package:kizuvia/features/dose_log/data/dose_log_repository.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/features/medications/domain/med_schedule.dart';
import 'package:kizuvia/features/medications/domain/medication.dart';
import 'package:kizuvia/features/patients/data/patient_repository.dart';
import 'package:kizuvia/features/patients/domain/patient.dart';

/// In-memory stand-in for Supabase (docs/05 §6).
class FakeSyncRemote implements SyncRemote {
  FakeSyncRemote(this.clock);

  final FixedClock clock;
  final Map<String, Map<String, Map<String, dynamic>>> tables = {};
  final List<String> pushOrder = [];
  bool offline = false;
  final Set<String> rejectTables = {};
  int upsertCalls = 0;

  Map<String, Map<String, dynamic>> table(String t) => tables[t] ??= {};

  @override
  Future<void> upsert(String t, Map<String, Object?> row) async {
    if (offline) throw const SyncNetworkException();
    if (rejectTables.contains(t)) throw const SyncRejectedException('42501');
    upsertCalls++;
    pushOrder.add('$t:${row['id']}');
    // Server stamps updated_at; date columns come back as dates.
    table(t)[row['id']! as String] = {
      ...row,
      'updated_at': clock.now().toUtc().toIso8601String(),
    };
  }

  @override
  Future<void> insertDoseLog(Map<String, Object?> row) async {
    if (offline) throw const SyncNetworkException();
    pushOrder.add('dose_logs:${row['id']}');
    final dup = table('dose_logs').values.any(
      (r) =>
          r['schedule_id'] == row['schedule_id'] &&
          r['scheduled_at'] == row['scheduled_at'] &&
          r['status'] == row['status'],
    );
    if (dup) return;
    table('dose_logs')[row['id']! as String] = {
      ...row,
      'created_at': clock.now().toUtc().toIso8601String(),
    };
  }

  @override
  Future<List<Map<String, dynamic>>> pull(
    String t, {
    required String cursorColumn,
    required DateTime? since,
    required int limit,
  }) async {
    if (offline) throw const SyncNetworkException();
    final rows =
        table(t).values.where((r) {
          if (since == null) return true;
          return !DateTime.parse(r[cursorColumn] as String).isBefore(since);
        }).toList()..sort(
          (a, b) =>
              (a[cursorColumn] as String).compareTo(b[cursorColumn] as String),
        );
    return rows.take(limit).toList();
  }
}

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late FakeSyncRemote remote;
  late SyncEngine engine;
  late PatientRepository patients;
  late MedicationRepository meds;
  late DoseLogRepository logs;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime.utc(2026, 3, 2, 1));
    remote = FakeSyncRemote(clock);
    engine = SyncEngine(db: db, remote: remote, clock: clock);
    patients = PatientRepository(db, clock, currentFamilyId: () => 'fam-1');
    meds = MedicationRepository(db, clock);
    logs = DoseLogRepository(db, clock);
  });
  tearDown(() => db.close());

  Future<(String, MedicationWithSchedule)> seed() async {
    final p = (await patients.save(const Patient(id: '', name: 'Budi')))
        .valueOrNull!;
    final m = (await meds.save(
      Medication(
        id: '',
        patientId: p.id,
        name: 'Amlodipine',
        startDate: DateTime.utc(2026, 3, 1),
        stockQty: 10,
      ),
      const MedSchedule(id: '', medicationId: '', times: ['07:00']),
    )).valueOrNull!;
    return (p.id, m);
  }

  group('push', () {
    test('uploads parents before children and marks rows synced', () async {
      final (pid, m) = await seed();
      final r = await engine.syncOnce();
      expect(r.pushed, 3);
      expect(remote.pushOrder, [
        'patients:$pid',
        'medications:${m.medication.id}',
        'schedules:${m.schedule!.id}',
      ]);
      expect(await db.select(db.syncQueue).get(), isEmpty);
      final row = await db.select(db.patients).getSingle();
      expect(row.syncStatus, SyncStatus.synced);
      expect(row.familyId, 'fam-1');
    });

    test('several edits of one row upload only the latest', () async {
      final (pid, _) = await seed();
      final p = (await patients.get(pid))!;
      await patients.save(p.copyWith(name: 'Budi 2'));
      await patients.save(p.copyWith(name: 'Budi 3'));
      await engine.syncOnce();
      expect(remote.table('patients')[pid]!['name'], 'Budi 3');
      expect(
        remote.pushOrder.where((e) => e.startsWith('patients:')),
        hasLength(1),
      );
    });

    test('network error stops, keeps the queue and reports it', () async {
      await seed();
      remote.offline = true;
      final r = await engine.syncOnce();
      expect(r.networkError, isTrue);
      expect(await db.select(db.syncQueue).get(), hasLength(3));
      remote.offline = false;
      expect((await engine.syncOnce()).pushed, 3);
    });

    test('rejected row is marked failed, others continue', () async {
      final (pid, _) = await seed();
      remote.rejectTables.add('medications');
      final r = await engine.syncOnce();
      expect(r.rejected, 1);
      expect(
        (await (db.select(
          db.patients,
        )..where((t) => t.id.equals(pid))).getSingle()).syncStatus,
        SyncStatus.synced,
      );
      final med = await db.select(db.medications).getSingle();
      expect(med.syncStatus, SyncStatus.failed);
      final queued = await db.select(db.syncQueue).get();
      expect(queued.single.lastError, 'rejected:42501');
      expect(queued.single.attempts, 1);
    });

    test('items rejected maxAttempts times are skipped', () async {
      await seed();
      remote.rejectTables.add('medications');
      final e = SyncEngine(
        db: db,
        remote: remote,
        clock: clock,
        maxAttempts: 2,
      );
      await e.syncOnce();
      await e.syncOnce();
      remote.rejectTables.clear();
      final before = remote.upsertCalls;
      await e.syncOnce();
      expect(remote.upsertCalls, before); // dead-lettered
    });

    test('a dose log uploads once, even if the device retries', () async {
      final (_, m) = await seed();
      await logs.record(
        scheduleId: m.schedule!.id,
        scheduledAt: DateTime.utc(2026, 3, 2),
        status: DoseStatus.taken,
      );
      await engine.syncOnce();
      expect(remote.table('dose_logs'), hasLength(1));
    });

    test('concurrent syncs: the second is skipped', () async {
      await seed();
      final results = await Future.wait([engine.syncOnce(), engine.syncOnce()]);
      expect(results.where((r) => r.skipped), hasLength(1));
    });
  });

  group('pull', () {
    Map<String, dynamic> patientRow(
      String id, {
      String name = 'Dari server',
      String updated = '2026-03-02T05:00:00Z',
      String? deleted,
    }) => {
      'id': id,
      'family_id': 'fam-1',
      'user_id': null,
      'name': name,
      'birth_year': null,
      'conditions': <String>['hipertensi'],
      'notes': null,
      'photo_path': null,
      'updated_at': updated,
      'deleted_at': deleted,
    };

    test('creates local rows from the server', () async {
      remote.table('patients')['p-9'] = patientRow('p-9');
      final r = await engine.syncOnce();
      expect(r.pulled, 1);
      final p = await db.select(db.patients).getSingle();
      expect(p.name, 'Dari server');
      expect(p.conditions, ['hipertensi']);
      expect(p.syncStatus, SyncStatus.synced);
    });

    test('never overwrites a row with unsynced local edits', () async {
      final (pid, _) = await seed();
      remote.offline = true;
      await engine.syncOnce(); // cannot push
      remote.offline = false;
      remote.table('patients')[pid] = patientRow(
        pid,
        name: 'Server menang?',
        updated: '2026-03-02T09:00:00Z',
      );
      // Pull only (push would succeed and overwrite the server copy).
      remote.rejectTables.add('patients');
      await engine.syncOnce();
      expect((await patients.get(pid))!.name, 'Budi');
    });

    test('last write wins: newer remote applies, older is ignored', () async {
      final (pid, _) = await seed();
      await engine.syncOnce(); // all synced; local updatedAt = 01:00
      remote.table('patients')[pid] = patientRow(
        pid,
        name: 'Lebih baru',
        updated: '2026-03-02T09:00:00Z',
      );
      await engine.syncOnce();
      expect((await patients.get(pid))!.name, 'Lebih baru');

      remote.table('patients')[pid] = patientRow(
        pid,
        name: 'Lebih lama',
        updated: '2026-03-02T02:00:00Z',
      );
      await db.delete(db.syncCursor).go(); // force re-read
      await engine.syncOnce();
      expect((await patients.get(pid))!.name, 'Lebih baru');
    });

    test(
      'delete wins over a concurrent edit (device A deletes, B edits)',
      () async {
        final (pid, _) = await seed();
        await engine.syncOnce();
        await patients.delete(pid);
        await engine.syncOnce(); // delete pushed, row synced + deleted
        // Another device edited the (undeleted) patient with an older stamp.
        remote.table('patients')[pid] = patientRow(
          pid,
          name: 'Edit B',
          updated: '2026-03-02T09:00:00Z',
        );
        await db.delete(db.syncCursor).go();
        await engine.syncOnce();
        expect(await patients.get(pid), isNull);
      },
    );

    test('remote soft delete hides the local row', () async {
      final (pid, _) = await seed();
      await engine.syncOnce();
      remote.table('patients')[pid] = patientRow(
        pid,
        updated: '2026-03-02T09:00:00Z',
        deleted: '2026-03-02T09:00:00Z',
      );
      await engine.syncOnce();
      expect(await patients.get(pid), isNull);
    });

    test(
      'server "missed" and local "taken" both kept; no duplicates',
      () async {
        final (_, m) = await seed();
        await engine.syncOnce();
        final at = DateTime.utc(2026, 3, 2);
        remote.table('dose_logs')['srv-1'] = {
          'id': 'srv-1',
          'schedule_id': m.schedule!.id,
          'patient_id': m.medication.patientId,
          'scheduled_at': at.toIso8601String(),
          'status': 'missed',
          'confirmed_by': null,
          'confirmed_at': null,
          'source': 'server',
          'note': null,
          'created_at': '2026-03-02T01:30:00Z',
        };
        await logs.record(
          scheduleId: m.schedule!.id,
          scheduledAt: at,
          status: DoseStatus.taken,
        );
        await engine.syncOnce();
        await engine.syncOnce();
        final all = await db.select(db.doseLogs).get();
        expect(all.map((l) => l.status).toSet(), {
          DoseStatus.taken,
          DoseStatus.missed,
        });
        expect(all, hasLength(2));
      },
    );

    test('echo of our own medication keeps the local start instant', () async {
      final p = (await patients.save(const Patient(id: '', name: 'Budi')))
          .valueOrNull!;
      // Created at 14:00 local; the server only stores the date.
      final created = DateTime(2026, 3, 2, 14);
      final m = (await meds.save(
        Medication(id: '', patientId: p.id, name: 'X', startDate: created),
        const MedSchedule(id: '', medicationId: '', times: ['08:00']),
      )).valueOrNull!;
      expect(remote.table('medications'), isEmpty);
      await engine.syncOnce();
      clock.current = DateTime.utc(2026, 3, 2, 12); // server stamps newer
      remote.table('medications')[m.medication.id]!['updated_at'] =
          '2026-03-03T00:00:00Z';
      await db.delete(db.syncCursor).go();
      await engine.syncOnce();
      final row = await db.select(db.medications).getSingle();
      expect(row.startDate.toLocal(), created);
      expect(
        remote.table('medications')[m.medication.id]!['start_date'],
        '2026-03-02',
      );
    });

    test('pages through large result sets', () async {
      for (var i = 0; i < 5; i++) {
        remote.table('patients')['p-$i'] = patientRow(
          'p-$i',
          name: 'P$i',
          updated:
              '2026-03-02T05:00:0$i'
              'Z',
        );
      }
      final small = SyncEngine(
        db: db,
        remote: remote,
        clock: clock,
        pageSize: 2,
      );
      final r = await small.syncOnce();
      expect(await db.select(db.patients).get(), hasLength(5));
      expect(r.pulled, greaterThanOrEqualTo(5));
    });
  });

  group('AccountMigrator (T2.3)', () {
    test(
      'attaches local data to the family and queues it in FK order',
      () async {
        final noFamily = PatientRepository(db, clock);
        final p = (await noFamily.save(const Patient(id: '', name: 'Lokal')))
            .valueOrNull!;
        final gone = (await noFamily.save(
          const Patient(id: '', name: 'Dihapus'),
        )).valueOrNull!;
        await noFamily.delete(gone.id);
        final m = (await meds.save(
          Medication(
            id: '',
            patientId: p.id,
            name: 'Obat',
            startDate: DateTime.utc(2026, 3, 1),
          ),
          const MedSchedule(id: '', medicationId: '', times: ['07:00']),
        )).valueOrNull!;
        await logs.record(
          scheduleId: m.schedule!.id,
          scheduledAt: DateTime.utc(2026, 3, 2),
          status: DoseStatus.taken,
        );

        final migrator = AccountMigrator(db, clock);
        expect(await migrator.localPatientCount(), 1);
        await migrator.attachToFamily('fam-9');
        await migrator.attachToFamily('fam-9'); // idempotent

        final queue = await db.select(db.syncQueue).get();
        expect(queue.map((q) => q.targetTable), [
          'patients',
          'medications',
          'schedules',
          'dose_logs',
        ]);
        expect(queue.any((q) => q.rowId == gone.id), isFalse);
        expect((await patients.get(p.id))!.familyId, 'fam-9');

        await engine.syncOnce();
        expect(remote.table('patients')[p.id]!['family_id'], 'fam-9');
        expect(remote.table('dose_logs'), hasLength(1));
        expect(await db.select(db.syncQueue).get(), isEmpty);
      },
    );
  });
}

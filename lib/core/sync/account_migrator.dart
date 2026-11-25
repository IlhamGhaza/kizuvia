import 'package:drift/drift.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/db/sync_enqueue.dart';
import 'package:kizuvia/core/domain/enums.dart';

/// First login: attach the data created offline to the account's family and
/// queue everything for upload (docs/05-SYNC.md §5, T2.3).
class AccountMigrator {
  AccountMigrator(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  /// Local rows that exist only on this device (no family yet).
  Future<int> localPatientCount() async => (await (_db.select(
    _db.patients,
  )..where((t) => t.familyId.isNull() & t.deletedAt.isNull())).get()).length;

  /// Sets `family_id` on every local patient and re-queues the full current
  /// state in FK order (patients, medications, schedules, dose logs). Old
  /// queue entries are dropped first: their payloads lack `family_id`.
  /// Soft-deleted rows are not uploaded. Idempotent.
  Future<void> attachToFamily(String familyId) => _db.transaction(() async {
    final now = _clock.now().toUtc();
    await _db.delete(_db.syncQueue).go();

    await (_db.update(_db.patients)..where((t) => t.familyId.isNull())).write(
      PatientsCompanion(
        familyId: Value(familyId),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
      ),
    );

    final patients = await (_db.select(
      _db.patients,
    )..where((t) => t.deletedAt.isNull() & t.familyId.equals(familyId))).get();
    final patientIds = {for (final p in patients) p.id};
    for (final p in patients) {
      await _requeue('patients', p.id, patientPayload(p), now);
    }

    final meds = await (_db.select(
      _db.medications,
    )..where((t) => t.deletedAt.isNull())).get();
    final liveMeds = meds.where((m) => patientIds.contains(m.patientId));
    final medIds = {for (final m in liveMeds) m.id};
    for (final m in liveMeds) {
      await _requeue('medications', m.id, medicationPayload(m), now);
    }

    final schedules = await (_db.select(
      _db.schedules,
    )..where((t) => t.deletedAt.isNull())).get();
    final liveSchedules = schedules.where(
      (s) => medIds.contains(s.medicationId),
    );
    final scheduleIds = {for (final s in liveSchedules) s.id};
    for (final s in liveSchedules) {
      await _requeue('schedules', s.id, schedulePayload(s), now);
    }

    final logs = await _db.select(_db.doseLogs).get();
    for (final l in logs.where((l) => scheduleIds.contains(l.scheduleId))) {
      await _requeue('dose_logs', l.id, doseLogPayload(l), now);
    }
  });

  Future<void> _requeue(
    String table,
    String id,
    Map<String, Object?> payload,
    DateTime now,
  ) async {
    await enqueueSync(
      _db,
      table: table,
      rowId: id,
      op: SyncOp.upsert,
      payload: payload,
      now: now,
    );
    switch (table) {
      case 'patients':
        await (_db.update(_db.patients)..where((t) => t.id.equals(id))).write(
          const PatientsCompanion(syncStatus: Value(SyncStatus.pending)),
        );
      case 'medications':
        await (_db.update(
          _db.medications,
        )..where((t) => t.id.equals(id))).write(
          const MedicationsCompanion(syncStatus: Value(SyncStatus.pending)),
        );
      case 'schedules':
        await (_db.update(_db.schedules)..where((t) => t.id.equals(id))).write(
          const SchedulesCompanion(syncStatus: Value(SyncStatus.pending)),
        );
      case 'dose_logs':
        await (_db.update(_db.doseLogs)..where((t) => t.id.equals(id))).write(
          const DoseLogsCompanion(syncStatus: Value(SyncStatus.pending)),
        );
    }
  }
}

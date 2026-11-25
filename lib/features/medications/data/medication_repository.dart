import 'package:drift/drift.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/db/sync_enqueue.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/errors/app_failure.dart';
import 'package:kizuvia/core/errors/result.dart';
import 'package:kizuvia/core/notifications/occurrence_calculator.dart';
import 'package:kizuvia/features/medications/domain/med_schedule.dart';
import 'package:kizuvia/features/medications/domain/medication.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'medication_repository.g.dart';

class MedicationWithSchedule {
  const MedicationWithSchedule(this.medication, this.schedule);

  final Medication medication;

  /// Null for "bila perlu" (PRN) medications.
  final MedSchedule? schedule;
}

Medication medicationFromRow(MedicationRow r) => Medication(
  id: r.id,
  patientId: r.patientId,
  name: r.name,
  strength: r.strength,
  form: MedForm.tryParse(r.form),
  instructions: r.instructions,
  mealRelation: MealRelation.tryParse(r.mealRelation),
  prescribedBy: r.prescribedBy,
  stockQty: r.stockQty,
  doseQty: r.doseQty,
  refillThresholdDays: r.refillThresholdDays,
  photoPath: r.photoPath,
  photoRemotePath: r.photoRemotePath,
  startDate: r.startDate,
  endDate: r.endDate,
  isPrn: r.isPrn,
  isActive: r.isActive,
  source: r.source,
);

MedSchedule scheduleFromRow(ScheduleRow r) => MedSchedule(
  id: r.id,
  medicationId: r.medicationId,
  times: r.times,
  daysOfWeek: r.daysOfWeek,
  timezone: r.timezone,
  graceMinutes: r.graceMinutes,
);

class MedicationRepository {
  MedicationRepository(this._db, this._clock, [Uuid? uuid])
    : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Clock _clock;
  final Uuid _uuid;

  /// Medications (with their schedule) of a patient, hidden if deleted.
  Stream<List<MedicationWithSchedule>> watchByPatient(String patientId) {
    final q =
        _db.select(_db.medications).join([
            leftOuterJoin(
              _db.schedules,
              _db.schedules.medicationId.equalsExp(_db.medications.id) &
                  _db.schedules.deletedAt.isNull(),
            ),
          ])
          ..where(
            _db.medications.patientId.equals(patientId) &
                _db.medications.deletedAt.isNull(),
          )
          ..orderBy([OrderingTerm.asc(_db.medications.name)]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          MedicationWithSchedule(
            medicationFromRow(r.readTable(_db.medications)),
            r.readTableOrNull(_db.schedules) == null
                ? null
                : scheduleFromRow(r.readTable(_db.schedules)),
          ),
      ],
    );
  }

  Future<MedicationWithSchedule?> get(String medicationId) async {
    final med =
        await (_db.select(_db.medications)
              ..where((t) => t.id.equals(medicationId) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (med == null) return null;
    final sch =
        await (_db.select(_db.schedules)..where(
              (t) => t.medicationId.equals(medicationId) & t.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return MedicationWithSchedule(
      medicationFromRow(med),
      sch == null ? null : scheduleFromRow(sch),
    );
  }

  /// Emits whenever the medication row changes; null once deleted.
  Stream<MedicationWithSchedule?> watch(String medicationId) =>
      (_db.select(_db.medications)..where((t) => t.id.equals(medicationId)))
          .watchSingleOrNull()
          .asyncMap((_) => get(medicationId));

  /// All live, active, non-PRN schedules (drives alarms and "Hari ini").
  Stream<List<ScheduleContext>> watchScheduleContexts() {
    final q =
        _db.select(_db.schedules).join([
          innerJoin(
            _db.medications,
            _db.medications.id.equalsExp(_db.schedules.medicationId),
          ),
          innerJoin(
            _db.patients,
            _db.patients.id.equalsExp(_db.medications.patientId),
          ),
        ])..where(
          _db.schedules.deletedAt.isNull() &
              _db.medications.deletedAt.isNull() &
              _db.medications.isActive.equals(true) &
              _db.medications.isPrn.equals(false) &
              _db.patients.deletedAt.isNull(),
        );
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          ScheduleContext(
            schedule: scheduleFromRow(r.readTable(_db.schedules)),
            medication: medicationFromRow(r.readTable(_db.medications)),
            patientName: r.readTable(_db.patients).name,
          ),
      ],
    );
  }

  /// Creates (empty ids) or updates a medication and its schedule in one
  /// transaction. PRN medications keep no schedule.
  Future<Result<MedicationWithSchedule, AppFailure>> save(
    Medication med,
    MedSchedule? schedule,
  ) async {
    if (med.name.trim().isEmpty) {
      return const Result.err(ValidationFailure('name required'));
    }
    if (med.doseQty <= 0) {
      return const Result.err(ValidationFailure('dose_qty must be > 0'));
    }
    if (!med.isPrn && (schedule == null || schedule.times.isEmpty)) {
      return const Result.err(ValidationFailure('at least one time'));
    }
    return guard(() async {
      final now = _clock.now().toUtc();
      final medId = med.id.isEmpty ? _uuid.v4() : med.id;
      // A different local photo (or none) invalidates the uploaded copy; sync
      // uploads the new one.
      final previous = med.id.isEmpty
          ? null
          : await (_db.select(
              _db.medications,
            )..where((t) => t.id.equals(medId))).getSingleOrNull();
      final remotePhoto = previous?.photoPath == med.photoPath
          ? med.photoRemotePath
          : null;
      await _db.transaction(() async {
        await _db
            .into(_db.medications)
            .insertOnConflictUpdate(
              MedicationsCompanion(
                id: Value(medId),
                patientId: Value(med.patientId),
                name: Value(med.name.trim()),
                strength: Value(med.strength),
                form: Value(med.form?.name),
                instructions: Value(med.instructions),
                mealRelation: Value(med.mealRelation?.dbValue),
                prescribedBy: Value(med.prescribedBy),
                stockQty: Value(med.stockQty),
                doseQty: Value(med.doseQty),
                refillThresholdDays: Value(med.refillThresholdDays),
                photoPath: Value(med.photoPath),
                // A new/changed local photo must be uploaded again.
                photoRemotePath: Value(remotePhoto),
                startDate: Value(med.startDate.toUtc()),
                endDate: Value(med.endDate?.toUtc()),
                isPrn: Value(med.isPrn),
                isActive: Value(med.isActive),
                source: Value(med.source),
                updatedAt: Value(now),
                localUpdatedAt: Value(now),
                syncStatus: const Value(SyncStatus.pending),
              ),
            );
        final medRow = await (_db.select(
          _db.medications,
        )..where((t) => t.id.equals(medId))).getSingle();
        await enqueueSync(
          _db,
          table: 'medications',
          rowId: medId,
          op: SyncOp.upsert,
          payload: medicationPayload(medRow),
          now: now,
        );

        // Phase 1: one schedule per medication; others are soft-deleted.
        final keepId = med.isPrn
            ? null
            : (schedule!.id.isEmpty ? _uuid.v4() : schedule.id);
        final existing =
            await (_db.select(_db.schedules)..where(
                  (t) => t.medicationId.equals(medId) & t.deletedAt.isNull(),
                ))
                .get();
        for (final old in existing.where((s) => s.id != keepId)) {
          await _softDeleteSchedule(old.id, now);
        }
        if (keepId != null) {
          await _db
              .into(_db.schedules)
              .insertOnConflictUpdate(
                SchedulesCompanion(
                  id: Value(keepId),
                  medicationId: Value(medId),
                  times: Value(schedule!.times),
                  daysOfWeek: Value(schedule.daysOfWeek),
                  timezone: Value(schedule.timezone),
                  graceMinutes: Value(schedule.graceMinutes),
                  updatedAt: Value(now),
                  localUpdatedAt: Value(now),
                  syncStatus: const Value(SyncStatus.pending),
                  deletedAt: const Value(null),
                ),
              );
          final sRow = await (_db.select(
            _db.schedules,
          )..where((t) => t.id.equals(keepId))).getSingle();
          await enqueueSync(
            _db,
            table: 'schedules',
            rowId: keepId,
            op: SyncOp.upsert,
            payload: schedulePayload(sRow),
            now: now,
          );
        }
      });
      return (await get(medId))!;
    }, onError: (_) => const DatabaseFailure());
  }

  Future<void> _softDeleteSchedule(String id, DateTime now) async {
    await (_db.update(_db.schedules)..where((t) => t.id.equals(id))).write(
      SchedulesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncStatus: const Value(SyncStatus.pending),
      ),
    );
    final row = await (_db.select(
      _db.schedules,
    )..where((t) => t.id.equals(id))).getSingle();
    await enqueueSync(
      _db,
      table: 'schedules',
      rowId: id,
      op: SyncOp.delete,
      payload: schedulePayload(row),
      now: now,
    );
  }

  /// Soft delete: deleted_at wins over any later edit (docs/05 §4).
  Future<Result<void, AppFailure>> delete(String medicationId) =>
      guard(() async {
        final now = _clock.now().toUtc();
        await _db.transaction(() async {
          final schedules = await (_db.select(
            _db.schedules,
          )..where((t) => t.medicationId.equals(medicationId))).get();
          for (final s in schedules.where((s) => s.deletedAt == null)) {
            await _softDeleteSchedule(s.id, now);
          }
          await (_db.update(
            _db.medications,
          )..where((t) => t.id.equals(medicationId))).write(
            MedicationsCompanion(
              deletedAt: Value(now),
              updatedAt: Value(now),
              localUpdatedAt: Value(now),
              syncStatus: const Value(SyncStatus.pending),
            ),
          );
          final row = await (_db.select(
            _db.medications,
          )..where((t) => t.id.equals(medicationId))).getSingle();
          await enqueueSync(
            _db,
            table: 'medications',
            rowId: medicationId,
            op: SyncOp.delete,
            payload: medicationPayload(row),
            now: now,
          );
        });
      }, onError: (_) => const DatabaseFailure());
}

@Riverpod(keepAlive: true)
MedicationRepository medicationRepository(Ref ref) => MedicationRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
);

@riverpod
Stream<List<MedicationWithSchedule>> patientMedications(
  Ref ref,
  String patientId,
) => ref.watch(medicationRepositoryProvider).watchByPatient(patientId);

@riverpod
Stream<MedicationWithSchedule?> medication(Ref ref, String id) =>
    ref.watch(medicationRepositoryProvider).watch(id);

@Riverpod(keepAlive: true)
Stream<List<ScheduleContext>> scheduleContexts(Ref ref) =>
    ref.watch(medicationRepositoryProvider).watchScheduleContexts();

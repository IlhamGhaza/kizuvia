import 'package:drift/drift.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/db/sync_enqueue.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/errors/app_failure.dart';
import 'package:kizuvia/core/errors/result.dart';
import 'package:kizuvia/features/patients/domain/patient.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'patient_repository.g.dart';

class PatientRepository {
  PatientRepository(this._db, this._clock, {Uuid? uuid, this._currentFamilyId})
    : _uuid = uuid ?? const Uuid();

  /// Family to attach new patients to (null = local-only mode).
  final String? Function()? _currentFamilyId;

  final AppDatabase _db;
  final Clock _clock;
  final Uuid _uuid;

  static Patient _toEntity(PatientRow r) => Patient(
    id: r.id,
    familyId: r.familyId,
    name: r.name,
    birthYear: r.birthYear,
    conditions: r.conditions,
    notes: r.notes,
    photoPath: r.photoPath,
  );

  Stream<List<Patient>> watchAll() {
    final q = _db.select(_db.patients)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return q.watch().map((rows) => rows.map(_toEntity).toList());
  }

  Future<Patient?> get(String id) async {
    final row = await (_db.select(
      _db.patients,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  /// Creates (empty `id`) or updates. Returns the saved patient.
  Future<Result<Patient, AppFailure>> save(Patient p) async {
    if (p.name.trim().isEmpty) {
      return const Result.err(ValidationFailure('name required'));
    }
    return guard(() async {
      final now = _clock.now().toUtc();
      final id = p.id.isEmpty ? _uuid.v4() : p.id;
      final companion = PatientsCompanion(
        id: Value(id),
        familyId: Value(p.familyId ?? _currentFamilyId?.call()),
        name: Value(p.name.trim()),
        birthYear: Value(p.birthYear),
        conditions: Value(p.conditions),
        notes: Value(p.notes),
        photoPath: Value(p.photoPath),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncStatus: const Value(SyncStatus.pending),
      );
      await _db.transaction(() async {
        await _db.into(_db.patients).insertOnConflictUpdate(companion);
        final row = await (_db.select(
          _db.patients,
        )..where((t) => t.id.equals(id))).getSingle();
        await enqueueSync(
          _db,
          table: 'patients',
          rowId: id,
          op: SyncOp.upsert,
          payload: patientPayload(row),
          now: now,
        );
      });
      return p.copyWith(id: id, name: p.name.trim());
    }, onError: (_) => const DatabaseFailure());
  }

  /// Soft delete; medications are hidden through [MedicationRepository].
  Future<Result<void, AppFailure>> delete(String id) => guard(() async {
    final now = _clock.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.patients)..where((t) => t.id.equals(id))).write(
        PatientsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          localUpdatedAt: Value(now),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      final row = await (_db.select(
        _db.patients,
      )..where((t) => t.id.equals(id))).getSingle();
      await enqueueSync(
        _db,
        table: 'patients',
        rowId: id,
        op: SyncOp.delete,
        payload: patientPayload(row),
        now: now,
      );
    });
  }, onError: (_) => const DatabaseFailure());
}

@Riverpod(keepAlive: true)
PatientRepository patientRepository(Ref ref) => PatientRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
  // Read lazily: a patient created after joining a family gets its id.
  currentFamilyId: () => ref.read(settingsControllerProvider).familyId,
);

@riverpod
Stream<List<Patient>> patients(Ref ref) =>
    ref.watch(patientRepositoryProvider).watchAll();

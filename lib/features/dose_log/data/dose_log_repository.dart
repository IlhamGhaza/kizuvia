import 'package:drift/drift.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/db/sync_enqueue.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/errors/app_failure.dart';
import 'package:kizuvia/core/errors/result.dart';
import 'package:kizuvia/core/notifications/occurrence_calculator.dart';
import 'package:kizuvia/features/dose_log/domain/dose_log.dart';
import 'package:kizuvia/features/stock/domain/stock_calculator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'dose_log_repository.g.dart';

class DoseLogRepository {
  DoseLogRepository(this._db, this._clock, [Uuid? uuid])
    : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Clock _clock;
  final Uuid _uuid;

  static DoseLog _toEntity(DoseLogRow r) => DoseLog(
    id: r.id,
    scheduleId: r.scheduleId,
    patientId: r.patientId,
    scheduledAt: r.scheduledAt,
    status: r.status,
    confirmedAt: r.confirmedAt,
    note: r.note,
    source: r.source,
    createdAt: r.createdAt,
  );

  Stream<List<DoseLog>> watchRange(DateTime from, DateTime to) {
    final q = _db.select(_db.doseLogs)
      ..where(
        (t) =>
            t.scheduledAt.isBiggerOrEqualValue(from.toUtc()) &
            t.scheduledAt.isSmallerOrEqualValue(to.toUtc()),
      );
    return q.watch().map((rows) => rows.map(_toEntity).toList());
  }

  /// Keys of occurrences that already have a log (see [occurrenceKey]).
  Future<Set<String>> loggedKeys(DateTime from, DateTime to) async {
    final rows =
        await (_db.select(_db.doseLogs)..where(
              (t) =>
                  t.scheduledAt.isBiggerOrEqualValue(from.toUtc()) &
                  t.scheduledAt.isSmallerOrEqualValue(to.toUtc()),
            ))
            .get();
    return {for (final r in rows) occurrenceKey(r.scheduleId, r.scheduledAt)};
  }

  /// Records a confirmation. Idempotent per `(schedule, scheduledAt, status)`.
  /// A `taken` log also reduces stock (US-09). Returns true if a row was added.
  Future<Result<bool, AppFailure>> record({
    required String scheduleId,
    required DateTime scheduledAt,
    required DoseStatus status,
    String? note,
  }) => guard(() async {
    final now = _clock.now().toUtc();
    return _db.transaction(() async {
      final join = await (_db.select(_db.schedules).join([
        innerJoin(
          _db.medications,
          _db.medications.id.equalsExp(_db.schedules.medicationId),
        ),
      ])..where(_db.schedules.id.equals(scheduleId))).getSingleOrNull();
      if (join == null) throw StateError('schedule not found');
      final med = join.readTable(_db.medications);

      final dup =
          await (_db.select(_db.doseLogs)..where(
                (t) =>
                    t.scheduleId.equals(scheduleId) &
                    t.scheduledAt.equals(scheduledAt.toUtc()) &
                    t.status.equals(status.name),
              ))
              .getSingleOrNull();
      if (dup != null) return false;

      final id = _uuid.v4();
      await _db
          .into(_db.doseLogs)
          .insert(
            DoseLogsCompanion.insert(
              id: id,
              scheduleId: scheduleId,
              patientId: med.patientId,
              scheduledAt: scheduledAt.toUtc(),
              status: status,
              createdAt: now,
              confirmedAt: Value(now),
              note: Value(note),
            ),
          );
      final log = await (_db.select(
        _db.doseLogs,
      )..where((t) => t.id.equals(id))).getSingle();
      await enqueueSync(
        _db,
        table: 'dose_logs',
        rowId: log.id,
        op: SyncOp.upsert,
        payload: doseLogPayload(log),
        now: now,
      );

      if (status == DoseStatus.taken && med.stockQty != null) {
        await (_db.update(
          _db.medications,
        )..where((t) => t.id.equals(med.id))).write(
          MedicationsCompanion(
            stockQty: Value(stockAfterTaken(med.stockQty!, med.doseQty)),
            updatedAt: Value(now),
            localUpdatedAt: Value(now),
            syncStatus: const Value(SyncStatus.pending),
          ),
        );
        final row = await (_db.select(
          _db.medications,
        )..where((t) => t.id.equals(med.id))).getSingle();
        await enqueueSync(
          _db,
          table: 'medications',
          rowId: med.id,
          op: SyncOp.upsert,
          payload: medicationPayload(row),
          now: now,
        );
      }
      return true;
    });
  }, onError: (_) => const DatabaseFailure());
}

@Riverpod(keepAlive: true)
DoseLogRepository doseLogRepository(Ref ref) =>
    DoseLogRepository(ref.watch(appDatabaseProvider), ref.watch(clockProvider));

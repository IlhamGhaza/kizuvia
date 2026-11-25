import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/sync/photo_sync.dart';
import 'package:kizuvia/core/sync/sync_remote.dart';

class SyncReport {
  const SyncReport({
    this.pushed = 0,
    this.rejected = 0,
    this.pulled = 0,
    this.networkError = false,
    this.skipped = false,
  });

  final int pushed;
  final int rejected;
  final int pulled;

  /// Stopped because the server was unreachable: retry with backoff.
  final bool networkError;

  /// Another sync was already running.
  final bool skipped;
}

/// Push (queue -> server) then pull (server -> local) (docs/05-SYNC.md).
/// Last-write-wins for patients/medications/schedules, append-only dose logs,
/// soft delete wins. A row that is still `pending` locally is never
/// overwritten by a pull.
class SyncEngine {
  SyncEngine({
    required this._db,
    required this._remote,
    required this._clock,
    this.pageSize = 500,
    this.maxAttempts = 5,
    this.photos,
  });

  final AppDatabase _db;
  final SyncRemote _remote;
  final Clock _clock;
  final int pageSize;

  /// Items rejected this many times are left in the queue but skipped.
  final int maxAttempts;

  /// Medication photo upload/download (T2.11); optional.
  final PhotoSync? photos;

  bool _running = false;

  static const _pullOrder = [
    ('patients', 'updated_at'),
    ('medications', 'updated_at'),
    ('schedules', 'updated_at'),
    ('dose_logs', 'created_at'),
  ];

  Future<SyncReport> syncOnce() async {
    if (_running) return const SyncReport(skipped: true);
    _running = true;
    try {
      try {
        await photos?.uploadPending();
      } on SyncNetworkException {
        return const SyncReport(networkError: true);
      }
      final push = await _push();
      if (push.networkError) return push;
      final pulled = await _pull();
      var offline = pulled.networkError;
      if (!offline) {
        try {
          await photos?.downloadMissing();
        } on SyncNetworkException {
          offline = true;
        }
      }
      return SyncReport(
        pushed: push.pushed,
        rejected: push.rejected,
        pulled: pulled.pulled,
        networkError: offline,
      );
    } finally {
      _running = false;
    }
  }

  // ------------------------------------------------------------------ push

  Future<SyncReport> _push() async {
    final items =
        await (_db.select(_db.syncQueue)..orderBy([
              (t) => OrderingTerm.asc(t.createdAt),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();

    // Coalesce edits of the same row; groups keep first-seen order so parents
    // (patients) are pushed before children (medications, schedules).
    final groups = <String, List<SyncQueueData>>{};
    for (final i in items) {
      final key = i.targetTable == 'dose_logs'
          ? 'dose_logs|${i.id}'
          : '${i.targetTable}|${i.rowId}';
      groups.putIfAbsent(key, () => []).add(i);
    }

    var pushed = 0;
    var rejected = 0;
    for (final group in groups.values) {
      final last = group.last;
      if (group.every((i) => i.attempts >= maxAttempts)) continue;
      final payload = (jsonDecode(last.payloadJson) as Map<String, dynamic>)
          .cast<String, Object?>();
      try {
        if (last.targetTable == 'dose_logs') {
          await _remote.insertDoseLog(payload);
        } else {
          await _remote.upsert(last.targetTable, payload);
        }
      } on SyncNetworkException {
        return SyncReport(
          pushed: pushed,
          rejected: rejected,
          networkError: true,
        );
      } on SyncRejectedException catch (e) {
        rejected++;
        for (final i in group) {
          await (_db.update(
            _db.syncQueue,
          )..where((t) => t.id.equals(i.id))).write(
            SyncQueueCompanion(
              attempts: Value(i.attempts + 1),
              lastError: Value('rejected:${e.code}'),
            ),
          );
        }
        await _markRow(last.targetTable, last.rowId, SyncStatus.failed);
        continue;
      }
      pushed++;
      await (_db.delete(
        _db.syncQueue,
      )..where((t) => t.id.isIn(group.map((i) => i.id)))).go();
      // Edited again while we were pushing? Then it is still pending.
      final stillQueued =
          await (_db.select(_db.syncQueue)..where(
                (t) =>
                    t.targetTable.equals(last.targetTable) &
                    t.rowId.equals(last.rowId),
              ))
              .get();
      if (stillQueued.isEmpty) {
        await _markRow(last.targetTable, last.rowId, SyncStatus.synced);
      }
    }
    return SyncReport(pushed: pushed, rejected: rejected);
  }

  Future<void> _markRow(String table, String id, SyncStatus s) async {
    switch (table) {
      case 'patients':
        await (_db.update(_db.patients)..where((t) => t.id.equals(id))).write(
          PatientsCompanion(syncStatus: Value(s)),
        );
      case 'medications':
        await (_db.update(_db.medications)..where((t) => t.id.equals(id)))
            .write(MedicationsCompanion(syncStatus: Value(s)));
      case 'schedules':
        await (_db.update(_db.schedules)..where((t) => t.id.equals(id))).write(
          SchedulesCompanion(syncStatus: Value(s)),
        );
      case 'dose_logs':
        await (_db.update(_db.doseLogs)..where((t) => t.id.equals(id))).write(
          DoseLogsCompanion(syncStatus: Value(s)),
        );
    }
  }

  // ------------------------------------------------------------------ pull

  Future<SyncReport> _pull() async {
    var total = 0;
    try {
      for (final (table, column) in _pullOrder) {
        var cursor = await _cursor(table);
        while (true) {
          final rows = await _remote.pull(
            table,
            cursorColumn: column,
            since: cursor,
            limit: pageSize,
          );
          if (rows.isEmpty) break;
          for (final r in rows) {
            await _apply(table, r);
          }
          total += rows.length;
          final newest = DateTime.parse(rows.last[column] as String).toUtc();
          // `>=` paging re-reads rows sharing the newest timestamp (apply is
          // idempotent). If a whole page shares one timestamp, stop here.
          final stuck = cursor != null && !newest.isAfter(cursor);
          cursor = newest;
          await _saveCursor(table, newest);
          if (rows.length < pageSize || stuck) break;
        }
      }
    } on SyncNetworkException {
      return SyncReport(pulled: total, networkError: true);
    } on SyncRejectedException {
      // Pull rejected (e.g. signed out): nothing to apply; try next cycle.
      return SyncReport(pulled: total);
    }
    return SyncReport(pulled: total);
  }

  Future<DateTime?> _cursor(String table) async {
    final row = await (_db.select(
      _db.syncCursor,
    )..where((t) => t.targetTable.equals(table))).getSingleOrNull();
    return row?.lastPulledAt;
  }

  Future<void> _saveCursor(String table, DateTime at) => _db
      .into(_db.syncCursor)
      .insertOnConflictUpdate(
        SyncCursorCompanion.insert(targetTable: table, lastPulledAt: at),
      );

  Future<void> _apply(String table, Map<String, dynamic> r) async {
    switch (table) {
      case 'patients':
        await _applyPatient(r);
      case 'medications':
        await _applyMedication(r);
      case 'schedules':
        await _applySchedule(r);
      case 'dose_logs':
        await _applyDoseLog(r);
    }
  }

  static DateTime _ts(Object? v) => DateTime.parse(v! as String).toUtc();
  static DateTime? _tsOrNull(Object? v) => v == null ? null : _ts(v);

  /// Local row wins when it has unsynced edits or is newer, and a local
  /// soft delete is never undone.
  bool _keepLocal({
    required SyncStatus? status,
    required DateTime? updatedAt,
    required DateTime? localDeletedAt,
    required DateTime remoteUpdatedAt,
    required DateTime? remoteDeletedAt,
  }) {
    if (status == null) return false; // no local row
    if (status != SyncStatus.synced) return true;
    if (localDeletedAt != null && remoteDeletedAt == null) return true;
    return updatedAt != null && remoteUpdatedAt.isBefore(updatedAt);
  }

  Future<void> _applyPatient(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final local = await (_db.select(
      _db.patients,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    final deleted = _tsOrNull(r['deleted_at']);
    if (_keepLocal(
      status: local?.syncStatus,
      updatedAt: local?.updatedAt,
      localDeletedAt: local?.deletedAt,
      remoteUpdatedAt: updated,
      remoteDeletedAt: deleted,
    )) {
      return;
    }
    await _db
        .into(_db.patients)
        .insertOnConflictUpdate(
          PatientsCompanion(
            id: Value(id),
            familyId: Value(r['family_id'] as String?),
            userId: Value(r['user_id'] as String?),
            name: Value(r['name'] as String),
            birthYear: Value(r['birth_year'] as int?),
            conditions: Value(
              ((r['conditions'] as List<dynamic>?) ?? const []).cast<String>(),
            ),
            notes: Value(r['notes'] as String?),
            photoPath: Value(r['photo_path'] as String?),
            updatedAt: Value(updated),
            deletedAt: Value(deleted),
            syncStatus: const Value(SyncStatus.synced),
            localUpdatedAt: Value(updated),
          ),
        );
  }

  /// Server dates have no time: keep the local instant when the day matches
  /// (start = creation time, end = end of day) so doses before creation are
  /// not turned into "missed" by a sync echo.
  static DateTime _startFromRemote(String ymd, DateTime? local) {
    final d = DateTime.parse(ymd); // local midnight
    if (local != null) {
      final l = local.toLocal();
      if (l.year == d.year && l.month == d.month && l.day == d.day) {
        return local;
      }
    }
    return d.toUtc();
  }

  static DateTime? _endFromRemote(String? ymd, DateTime? local) {
    if (ymd == null) return null;
    final d = DateTime.parse(ymd);
    if (local != null) {
      final l = local.toLocal();
      if (l.year == d.year && l.month == d.month && l.day == d.day) {
        return local;
      }
    }
    return DateTime(d.year, d.month, d.day, 23, 59, 59).toUtc();
  }

  Future<void> _applyMedication(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final local = await (_db.select(
      _db.medications,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    final deleted = _tsOrNull(r['deleted_at']);
    if (_keepLocal(
      status: local?.syncStatus,
      updatedAt: local?.updatedAt,
      localDeletedAt: local?.deletedAt,
      remoteUpdatedAt: updated,
      remoteDeletedAt: deleted,
    )) {
      return;
    }
    await _db
        .into(_db.medications)
        .insertOnConflictUpdate(
          MedicationsCompanion(
            id: Value(id),
            patientId: Value(r['patient_id'] as String),
            name: Value(r['name'] as String),
            strength: Value(r['strength'] as String?),
            form: Value(r['form'] as String?),
            instructions: Value(r['instructions'] as String?),
            mealRelation: Value(r['meal_relation'] as String?),
            prescribedBy: Value(r['prescribed_by'] as String?),
            stockQty: Value((r['stock_qty'] as num?)?.toDouble()),
            doseQty: Value((r['dose_qty'] as num).toDouble()),
            refillThresholdDays: Value(r['refill_threshold_days'] as int),
            // The uploaded copy; the local file is kept only if it is the
            // same one (otherwise it is downloaded again).
            photoRemotePath: Value(r['photo_path'] as String?),
            photoPath: Value(
              local != null && local.photoRemotePath == r['photo_path']
                  ? local.photoPath
                  : null,
            ),
            startDate: Value(
              _startFromRemote(r['start_date'] as String, local?.startDate),
            ),
            endDate: Value(
              _endFromRemote(r['end_date'] as String?, local?.endDate),
            ),
            isPrn: Value(r['is_prn'] as bool),
            isActive: Value(r['is_active'] as bool),
            source: Value(r['source'] as String),
            updatedAt: Value(updated),
            deletedAt: Value(deleted),
            syncStatus: const Value(SyncStatus.synced),
            localUpdatedAt: Value(updated),
          ),
        );
  }

  Future<void> _applySchedule(Map<String, dynamic> r) async {
    final id = r['id'] as String;
    final local = await (_db.select(
      _db.schedules,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    final updated = _ts(r['updated_at']);
    final deleted = _tsOrNull(r['deleted_at']);
    if (_keepLocal(
      status: local?.syncStatus,
      updatedAt: local?.updatedAt,
      localDeletedAt: local?.deletedAt,
      remoteUpdatedAt: updated,
      remoteDeletedAt: deleted,
    )) {
      return;
    }
    await _db
        .into(_db.schedules)
        .insertOnConflictUpdate(
          SchedulesCompanion(
            id: Value(id),
            medicationId: Value(r['medication_id'] as String),
            // Postgres `time` arrives as HH:mm:ss.
            times: Value([
              for (final t in (r['times'] as List<dynamic>).cast<String>())
                t.substring(0, 5),
            ]),
            daysOfWeek: Value((r['days_of_week'] as List<dynamic>).cast<int>()),
            timezone: Value(r['timezone'] as String),
            graceMinutes: Value(r['grace_minutes'] as int),
            updatedAt: Value(updated),
            deletedAt: Value(deleted),
            syncStatus: const Value(SyncStatus.synced),
            localUpdatedAt: Value(updated),
          ),
        );
  }

  Future<void> _applyDoseLog(Map<String, dynamic> r) async {
    final status = DoseStatus.values.byName(r['status'] as String);
    final scheduledAt = _ts(r['scheduled_at']);
    final scheduleId = r['schedule_id'] as String;
    final exists =
        await (_db.select(_db.doseLogs)..where(
              (t) =>
                  (t.id.equals(r['id'] as String)) |
                  (t.scheduleId.equals(scheduleId) &
                      t.scheduledAt.equals(scheduledAt) &
                      t.status.equals(status.name)),
            ))
            .getSingleOrNull();
    if (exists != null) return;
    await _db
        .into(_db.doseLogs)
        .insert(
          DoseLogsCompanion.insert(
            id: r['id'] as String,
            scheduleId: scheduleId,
            patientId: r['patient_id'] as String,
            scheduledAt: scheduledAt,
            status: status,
            createdAt: _ts(r['created_at']),
            confirmedBy: Value(r['confirmed_by'] as String?),
            confirmedAt: Value(_tsOrNull(r['confirmed_at'])),
            source: Value(DoseSource.values.byName(r['source'] as String)),
            note: Value(r['note'] as String?),
            syncStatus: const Value(SyncStatus.synced),
          ),
        );
  }

  /// For tests / diagnostics.
  DateTime get now => _clock.now();
}

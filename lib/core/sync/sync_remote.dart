import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Offline / transient problem: stop and retry later with backoff.
class SyncNetworkException implements Exception {
  const SyncNetworkException();
}

/// The server refused this row (RLS, constraint): mark failed, keep going.
/// [code] is a Postgres / HTTP code, never row data.
class SyncRejectedException implements Exception {
  const SyncRejectedException(this.code);

  final String code;
}

/// Server API used by the sync engine, so tests can fake it (docs/05 §6).
abstract interface class SyncRemote {
  /// Insert or update one row (also used for soft deletes).
  Future<void> upsert(String table, Map<String, Object?> row);

  /// Insert a dose log; a duplicate counts as success (append-only).
  Future<void> insertDoseLog(Map<String, Object?> row);

  /// Rows with `cursorColumn >= since`, oldest first, at most [limit].
  Future<List<Map<String, dynamic>>> pull(
    String table, {
    required String cursorColumn,
    required DateTime? since,
    required int limit,
  });
}

class SupabaseSyncRemote implements SyncRemote {
  SupabaseSyncRemote(this._client);

  final sb.SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on sb.PostgrestException catch (e) {
      final code = e.code ?? '';
      // 5xx and unknown gateway errors are transient.
      if (code.startsWith('5') || code.isEmpty) {
        throw const SyncNetworkException();
      }
      throw SyncRejectedException(code);
    } on sb.AuthException {
      throw const SyncNetworkException();
    } on Object {
      throw const SyncNetworkException();
    }
  }

  @override
  Future<void> upsert(String table, Map<String, Object?> row) =>
      _guard(() => _client.from(table).upsert(row));

  @override
  Future<void> insertDoseLog(Map<String, Object?> row) => _guard(() async {
    try {
      // DO NOTHING on retry: dose_logs has no UPDATE privilege (append-only).
      await _client
          .from('dose_logs')
          .upsert(row, onConflict: 'id', ignoreDuplicates: true);
    } on sb.PostgrestException catch (e) {
      if (e.code == '23505') return; // same dose already logged elsewhere
      rethrow;
    }
  });

  @override
  Future<List<Map<String, dynamic>>> pull(
    String table, {
    required String cursorColumn,
    required DateTime? since,
    required int limit,
  }) => _guard(() async {
    var q = _client.from(table).select();
    if (since != null) {
      q = q.gte(cursorColumn, since.toUtc().toIso8601String());
    }
    final rows = await q.order(cursorColumn, ascending: true).limit(limit);
    return rows.cast<Map<String, dynamic>>();
  });
}

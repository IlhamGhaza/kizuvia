import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/supabase/supabase_config.dart';
import 'package:kizuvia/core/sync/photo_sync.dart';
import 'package:kizuvia/core/sync/sync_engine.dart';
import 'package:kizuvia/core/sync/sync_remote.dart';
import 'package:kizuvia/features/auth/data/auth_repository.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

part 'sync_controller.g.dart';

class SyncUiState {
  const SyncUiState({
    this.enabled = false,
    this.syncing = false,
    this.pending = 0,
    this.offline = false,
    this.lastSyncedAt,
  });

  /// Signed in and attached to a family.
  final bool enabled;
  final bool syncing;
  final int pending;

  /// The last attempt could not reach the server.
  final bool offline;
  final DateTime? lastSyncedAt;

  SyncUiState copyWith({
    bool? syncing,
    int? pending,
    bool? offline,
    DateTime? lastSyncedAt,
  }) => SyncUiState(
    enabled: enabled,
    syncing: syncing ?? this.syncing,
    pending: pending ?? this.pending,
    offline: offline ?? this.offline,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
}

/// Runs the [SyncEngine] when signed in and attached to a family: at start,
/// on resume, 2 s after a local change, on realtime events, every 5 minutes,
/// and with exponential backoff (2^n s, max 10 min) while offline
/// (docs/05-SYNC.md §1). Alarms never wait for any of this.
@Riverpod(keepAlive: true)
class SyncController extends _$SyncController {
  Timer? _debounce;
  Timer? _periodic;
  Timer? _retry;
  StreamSubscription<List<SyncQueueData>>? _queueSub;
  sb.RealtimeChannel? _channel;
  SyncEngine? _engine;
  int _failures = 0;

  static const _tables = [
    'patients',
    'medications',
    'schedules',
    'dose_logs',
    'family_members',
  ];

  @override
  SyncUiState build() {
    ref.onDispose(_stop);
    final user = ref.watch(authUserProvider).value;
    final familyId = ref.watch(
      settingsControllerProvider.select((s) => s.familyId),
    );
    if (!SupabaseConfig.isReady || user == null || familyId == null) {
      return const SyncUiState();
    }
    Future.microtask(_start);
    return const SyncUiState(enabled: true);
  }

  void _start() {
    final db = ref.read(appDatabaseProvider);
    _engine = SyncEngine(
      db: db,
      remote: SupabaseSyncRemote(sb.Supabase.instance.client),
      clock: ref.read(clockProvider),
      photos: PhotoSync(
        db: db,
        storage: SupabasePhotoStorage(sb.Supabase.instance.client),
        files: LocalPhotoFiles(),
        clock: ref.read(clockProvider),
      ),
    );
    _queueSub = db.select(db.syncQueue).watch().listen((items) {
      state = state.copyWith(pending: items.length);
      if (items.isNotEmpty) _schedule(const Duration(seconds: 2));
    });
    _periodic = Timer.periodic(const Duration(minutes: 5), (_) => syncNow());
    final client = sb.Supabase.instance.client;
    var channel = client.channel('kizuvia-sync');
    for (final t in _tables) {
      channel = channel.onPostgresChanges(
        event: sb.PostgresChangeEvent.all,
        schema: 'public',
        table: t,
        callback: (_) => _schedule(const Duration(seconds: 1)),
      );
    }
    _channel = channel..subscribe();
    unawaited(syncNow());
  }

  void _stop() {
    _debounce?.cancel();
    _periodic?.cancel();
    _retry?.cancel();
    unawaited(_queueSub?.cancel());
    final channel = _channel;
    if (channel != null) {
      unawaited(sb.Supabase.instance.client.removeChannel(channel));
    }
    _queueSub = null;
    _channel = null;
    _engine = null;
  }

  void _schedule(Duration delay) {
    _debounce?.cancel();
    _debounce = Timer(delay, () => unawaited(syncNow()));
  }

  /// Safe to call at any time; does nothing when sync is not active.
  Future<void> syncNow() async {
    final engine = _engine;
    if (engine == null || !state.enabled) return;
    state = state.copyWith(syncing: true);
    final report = await engine.syncOnce();
    if (report.skipped) return;
    if (report.networkError) {
      _failures++;
      final secs = math.min(math.pow(2, _failures).toInt(), 600);
      _retry?.cancel();
      _retry = Timer(Duration(seconds: secs), () => unawaited(syncNow()));
      state = state.copyWith(syncing: false, offline: true);
    } else {
      _failures = 0;
      state = state.copyWith(
        syncing: false,
        offline: false,
        lastSyncedAt: ref.read(clockProvider).now(),
      );
    }
  }
}

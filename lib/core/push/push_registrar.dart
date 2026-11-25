import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kizuvia/core/notifications/notification_providers.dart';
import 'package:kizuvia/core/supabase/supabase_config.dart';
import 'package:kizuvia/core/sync/sync_controller.dart';
import 'package:kizuvia/core/utils/app_logger.dart';
import 'package:kizuvia/features/auth/data/auth_repository.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

part 'push_registrar.g.dart';

/// Completes when `Firebase.initializeApp` has finished (true) or failed
/// (false). FCM is only for caregiver alerts, never for alarms.
abstract final class FirebaseGate {
  static final Completer<bool> ready = Completer<bool>();
}

/// Keeps this device's FCM token in `device_tokens` while signed in and
/// attached to a family (T2.6, docs/04 §7), and shows caregiver alerts that
/// arrive while the app is open (FCM only displays them in the background).
@Riverpod(keepAlive: true)
class PushRegistrar extends _$PushRegistrar {
  StreamSubscription<String>? _refreshSub;
  StreamSubscription<RemoteMessage>? _messageSub;

  @override
  void build() {
    ref.onDispose(() {
      unawaited(_refreshSub?.cancel());
      unawaited(_messageSub?.cancel());
    });
    final user = ref.watch(authUserProvider).value;
    final familyId = ref.watch(
      settingsControllerProvider.select((s) => s.familyId),
    );
    if (!SupabaseConfig.isReady || user == null || familyId == null) return;
    unawaited(_register(user.id));
  }

  Future<void> _register(String userId) async {
    if (!await FirebaseGate.ready.future) return;
    try {
      final fcm = FirebaseMessaging.instance;
      await fcm.requestPermission();
      if (Platform.isIOS) {
        // The Firebase Installation ID (FID) is not yet reliable as a send
        // target on Apple platforms: keep using the registration token there.
        // ignore: deprecated_member_use
        final token = await fcm.getToken();
        if (token != null) await _save(userId, token);
        // ignore: deprecated_member_use
        _refreshSub = fcm.onTokenRefresh.listen(
          (t) => unawaited(_save(userId, t)),
        );
      } else {
        // Android: FID registration (enabled by the manifest meta-data).
        _refreshSub = fcm.onRegistered.listen(
          (fid) => unawaited(_save(userId, fid)),
        );
        await fcm.register();
      }
      _messageSub = FirebaseMessaging.onMessage.listen(_onMessage);
    } on Object catch (e) {
      // Only the type: tokens and payloads are never logged.
      AppLogger().warning('FCM registration skipped (${e.runtimeType})');
    }
  }

  Future<void> _save(String userId, String token) async {
    try {
      await sb.Supabase.instance.client.from('device_tokens').upsert({
        'token': token,
        'user_id': userId,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
      await (await SharedPreferences.getInstance()).setString(
        _savedIdKey,
        token,
      );
    } on Object catch (e) {
      AppLogger().warning('Saving FCM token failed (${e.runtimeType})');
    }
  }

  void _onMessage(RemoteMessage m) {
    final type = m.data['type'];
    if (type == 'data_changed') {
      unawaited(ref.read(syncControllerProvider.notifier).syncNow());
      return;
    }
    final n = m.notification;
    if (n == null) return;
    unawaited(
      ref
          .read(notificationServiceProvider)
          .showCaregiverAlert(title: n.title ?? '', body: n.body ?? ''),
    );
    // A missed dose also means data changed on the server.
    unawaited(ref.read(syncControllerProvider.notifier).syncNow());
  }

  /// Removes this device's token (sign-out), so it stops receiving alerts.
  static const _savedIdKey = 'fcm_registered_id';

  static Future<void> unregister() async {
    if (!SupabaseConfig.isReady || !await FirebaseGate.ready.future) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_savedIdKey);
      if (id != null && id.isNotEmpty) {
        await sb.Supabase.instance.client
            .from('device_tokens')
            .delete()
            .eq('token', id);
        await prefs.remove(_savedIdKey);
      }
    } on Object catch (e) {
      AppLogger().warning('FCM unregister skipped (${e.runtimeType})');
    }
  }
}

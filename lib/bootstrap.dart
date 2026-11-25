import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kizuvia/app/app.dart';
import 'package:kizuvia/app/router.dart';
import 'package:kizuvia/core/notifications/notification_actions.dart';
import 'package:kizuvia/core/notifications/notification_payload.dart';
import 'package:kizuvia/core/notifications/notification_providers.dart';
import 'package:kizuvia/core/notifications/notification_service.dart';
import 'package:kizuvia/core/push/push_registrar.dart';
import 'package:kizuvia/core/supabase/supabase_config.dart';
import 'package:kizuvia/core/utils/app_logger.dart';
import 'package:kizuvia/core/utils/device_l10n.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:kizuvia/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

/// App start-up (docs/02-ARCHITECTURE.md §3). Supabase and Firebase are added
/// in Phase 2. Nothing here waits for the network: alarms must work offline.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();

  final prefs = await SharedPreferences.getInstance();
  final plugin = FlutterLocalNotificationsPlugin();
  final service = NotificationService(plugin, deviceL10n());

  late final ProviderContainer container;

  Future<void> onResponse(NotificationResponse r) async {
    final privacy = container
        .read(settingsControllerProvider)
        .privacyLockScreen;
    final handled = await handleNotificationResponse(
      r,
      container.read(doseActionsProvider),
      privacyLockScreen: privacy,
    );
    if (!handled && r.payload != null && r.payload != testPayload) {
      final p = DosePayload.decode(r.payload!);
      final location =
          '/dose/${p.scheduleIds.first}?at=${p.at.toIso8601String()}';
      unawaited(container.read(routerProvider).push<void>(location));
    }
  }

  await service.init(
    onResponse: (r) => unawaited(onResponse(r)),
    onBackgroundResponse: onBackgroundNotificationResponse,
  );

  await _initSupabase();

  container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      notificationServiceProvider.overrideWithValue(service),
    ],
  );

  runApp(
    UncontrolledProviderScope(container: container, child: const KizuviaApp()),
  );

  unawaited(_initFirebase());

  // App opened by tapping a notification while it was killed.
  final launch = await plugin.getNotificationAppLaunchDetails();
  final response = launch?.notificationResponse;
  if ((launch?.didNotificationLaunchApp ?? false) && response != null) {
    unawaited(onResponse(response));
  }
}

/// Firebase is only for caregiver push (FCM, Phase 2). It must never delay or
/// break start-up: alarms are local and work without it (safety rule 4).
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseGate.ready.complete(true);
  } on Object catch (e) {
    // Only the type is logged (no data, docs/08 §3).
    AppLogger().warning('Firebase init skipped (${e.runtimeType})');
    if (!FirebaseGate.ready.isCompleted) FirebaseGate.ready.complete(false);
  }
}

/// Local session restore only; no network round trip blocks start-up.
/// If it fails the app stays in local-only mode (safety rule 4).
Future<void> _initSupabase() async {
  if (!SupabaseConfig.isConfigured) return;
  // Not cancelled on timeout: a slow first start still finishes and flips
  // `initialized` (a bare `.timeout` left cloud features off for the whole run).
  final init = Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  ).then((_) => SupabaseConfig.initialized = true);
  unawaited(
    init.then<void>(
      (_) {},
      onError: (Object e) {
        SupabaseConfig.initError = e.runtimeType.toString();
        AppLogger().warning('Supabase init skipped (${e.runtimeType})');
      },
    ),
  );
  try {
    await init.timeout(const Duration(seconds: 5));
  } on Object {
    // Handled above; start-up must not wait for the network.
  }
}

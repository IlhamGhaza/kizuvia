import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/notifications/dose_actions.dart';
import 'package:kizuvia/core/notifications/notification_payload.dart';
import 'package:kizuvia/core/notifications/notification_service.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Payload of the diagnostic notifications from the alarm test screen (T1.10).
const testPayload = 'TEST';

/// SharedPreferences key: last action pressed on a test notification.
const testLastActionKey = 'alarm_test_last_action';

/// Applies a notification action. Returns true if it was an action button
/// (handled here); a plain tap returns false so the UI can navigate.
Future<bool> handleNotificationResponse(
  NotificationResponse response,
  DoseActions actions, {
  bool privacyLockScreen = false,
}) async {
  final raw = response.payload;
  final actionId = response.actionId;
  if (raw == testPayload) {
    // Proves the action reached the (background) isolate.
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    await prefs.setString(
      testLastActionKey,
      '${actionId ?? 'TAP'} @ ${DateTime.now().toIso8601String()}',
    );
    return true;
  }
  if (raw == null || actionId == null || actionId.isEmpty) return false;
  final payload = DosePayload.decode(raw);
  switch (actionId) {
    case NotificationIds.actionTaken:
      await actions.confirm(payload, DoseStatus.taken);
    case NotificationIds.actionSkip:
      await actions.confirm(payload, DoseStatus.skipped);
    case NotificationIds.actionSnooze:
      await actions.snooze(payload, privacyLockScreen: privacyLockScreen);
    default:
      return false;
  }
  return true;
}

/// Entry point for action buttons pressed while the app is not in the
/// foreground (docs/04 §5). Runs in its own isolate with its own Drift
/// connection, shared with the main isolate.
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  tzdata.initializeTimeZones();

  final db = AppDatabase();
  try {
    final l10n = await AppLocalizations.delegate.load(const Locale('id'));
    final service = NotificationService(
      FlutterLocalNotificationsPlugin(),
      l10n,
    );
    await service.init();
    final prefs = await SharedPreferences.getInstance();
    await handleNotificationResponse(
      response,
      DoseActions(
        db: db,
        clock: const SystemClock(),
        gateway: service,
        l10n: l10n,
      ),
      privacyLockScreen: readSettings(prefs).privacyLockScreen,
    );
  } finally {
    await db.close();
  }
}

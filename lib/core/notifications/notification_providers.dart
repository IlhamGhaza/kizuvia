import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/notifications/alarm_scheduler.dart';
import 'package:kizuvia/core/notifications/dose_actions.dart';
import 'package:kizuvia/core/notifications/notification_service.dart';
import 'package:kizuvia/core/notifications/system_settings.dart';
import 'package:kizuvia/core/utils/device_l10n.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
AppLocalizations notificationL10n(Ref ref) => deviceL10n();

/// Overridden in `main()` with the instance that was `init()`-ed in bootstrap.
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationService(
  FlutterLocalNotificationsPlugin(),
  ref.watch(notificationL10nProvider),
);

@Riverpod(keepAlive: true)
AlarmScheduler alarmScheduler(Ref ref) {
  final isIos = defaultTargetPlatform == TargetPlatform.iOS;
  return AlarmScheduler(
    db: ref.watch(appDatabaseProvider),
    clock: ref.watch(clockProvider),
    gateway: ref.watch(notificationServiceProvider),
    l10n: ref.watch(notificationL10nProvider),
    maxOccurrences: isIos ? 60 : 200,
    includeFollowups: !isIos,
    // Android has no 64-notification limit, so look further ahead: alarms
    // keep firing even if the app is not opened for a few days.
    window: isIos ? const Duration(hours: 48) : const Duration(days: 7),
  );
}

@Riverpod(keepAlive: true)
DoseActions doseActions(Ref ref) => DoseActions(
  db: ref.watch(appDatabaseProvider),
  clock: ref.watch(clockProvider),
  gateway: ref.watch(notificationServiceProvider),
  l10n: ref.watch(notificationL10nProvider),
);

/// Keeps the OS alarms in sync with the database: runs whenever schedules,
/// medications or the privacy setting change (docs/04 §4). Watch it once at
/// the app root.
@Riverpod(keepAlive: true)
class AlarmAutoReschedule extends _$AlarmAutoReschedule {
  @override
  void build() {
    ref
      ..listen(scheduleContextsProvider, (_, _) => unawaited(run()))
      ..listen(
        settingsControllerProvider.select((s) => s.privacyLockScreen),
        (_, _) => unawaited(run()),
      );
  }

  Future<void> run() => ref
      .read(alarmSchedulerProvider)
      .rescheduleAll(
        privacyLockScreen: ref
            .read(settingsControllerProvider)
            .privacyLockScreen,
      );
}

/// What the OS currently allows. Invalidate on app resume.
class AlarmPermissions {
  const AlarmPermissions({
    required this.notifications,
    required this.exactAlarms,
    this.dndAccess = true,
    this.fullScreen = true,
  });

  final bool notifications;
  final bool exactAlarms;

  /// Optional: lets alarms ring in Do Not Disturb.
  final bool dndAccess;

  /// Optional: lets the alarm open over the lock screen.
  final bool fullScreen;

  bool get allGranted => notifications && exactAlarms;
}

@riverpod
Future<AlarmPermissions> alarmPermissions(Ref ref) async {
  final service = ref.watch(notificationServiceProvider);
  final system = ref.watch(systemSettingsProvider);
  return AlarmPermissions(
    notifications: await service.notificationsEnabled(),
    exactAlarms: await service.canScheduleExact(),
    dndAccess: await system.dndAccessGranted(),
    fullScreen: await system.fullScreenIntentAllowed(),
  );
}

import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kizuvia/core/notifications/notification_gateway.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;

abstract final class NotificationIds {
  /// Channel settings are frozen once created, so changes to sound / DND
  /// bypass need a new id. `dose_alarm` (v1, plain notification sound) is
  /// deleted on init.
  static const doseAlarmChannel = 'dose_alarm_v2';
  static const legacyDoseAlarmChannel = 'dose_alarm';
  static const alarmSoundUri = 'content://settings/system/alarm_alert';
  static const doseFollowupChannel = 'dose_followup';
  static const stockChannel = 'stock';
  static const caregiverChannel = 'caregiver_alert';
  static const actionTaken = 'TAKEN';
  static const actionSnooze = 'SNOOZE';
  static const actionSkip = 'SKIP';
  static const smallIcon = 'ic_stat_kizuvia';
}

/// `flutter_local_notifications` implementation of [NotificationGateway].
class NotificationService implements NotificationGateway {
  NotificationService(this._plugin, this._l10n);

  final FlutterLocalNotificationsPlugin _plugin;
  final AppLocalizations _l10n;

  /// Must be called in every isolate that shows/cancels notifications.
  /// [onResponse] runs in the UI isolate, [onBackgroundResponse] (top-level,
  /// `@pragma('vm:entry-point')`) for actions that do not open the app.
  Future<void> init({
    DidReceiveNotificationResponseCallback? onResponse,
    DidReceiveBackgroundNotificationResponseCallback? onBackgroundResponse,
  }) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(NotificationIds.smallIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.deleteNotificationChannel(
      channelId: NotificationIds.legacyDoseAlarmChannel,
    );
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationIds.doseAlarmChannel,
        _l10n.notifChannelAlarm,
        importance: Importance.max,
        // Only effective once the user grants "Do Not Disturb access".
        bypassDnd: true,
        sound: const UriAndroidNotificationSound(NotificationIds.alarmSoundUri),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        vibrationPattern: _vibration,
      ),
    );
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationIds.doseFollowupChannel,
        _l10n.notifChannelFollowup,
        importance: Importance.high,
      ),
    );
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationIds.caregiverChannel,
        _l10n.notifChannelCaregiver,
        importance: Importance.high,
      ),
    );
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationIds.stockChannel,
        _l10n.notifChannelStock,
      ),
    );
  }

  /// Asks for POST_NOTIFICATIONS (Android 13+) / alert+sound+badge (iOS).
  Future<bool> requestNotificationPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  Future<bool> notificationsEnabled() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.areNotificationsEnabled() ?? true;
  }

  /// True when exact alarms are allowed (always true off Android).
  Future<bool> canScheduleExact() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.canScheduleExactNotifications() ?? true;
  }

  /// Opens the system "Alarms & reminders" screen (Android 12+).
  Future<void> requestExactAlarmPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  @override
  Future<void> schedule(PlannedNotification n) async {
    final exact = await canScheduleExact();
    await _plugin.zonedSchedule(
      id: n.id,
      title: n.title,
      body: n.body,
      scheduledDate: tz.TZDateTime.from(n.at, tz.UTC),
      notificationDetails: _details(n),
      payload: n.payload,
      // Without the exact-alarm permission fall back to inexact (docs/04 §3);
      // the UI shows a warning banner.
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Shows a caregiver alert that arrived through FCM while the app is open.
  Future<void> showCaregiverAlert({
    required String title,
    required String body,
  }) => _plugin.show(
    id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) & 0x7fffffff,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationIds.caregiverChannel,
        _l10n.notifChannelCaregiver,
        icon: NotificationIds.smallIcon,
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
  );

  /// Number of notifications the OS still holds as pending (diagnostics).
  Future<int> pendingCount() async =>
      (await _plugin.pendingNotificationRequests()).length;

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  static final Int64List _vibration = Int64List.fromList([
    0,
    800,
    400,
    800,
    400,
    800,
  ]);

  /// `FLAG_INSISTENT`: the alarm sound repeats until the notification is
  /// dismissed or acted on.
  static final Int32List _insistent = Int32List.fromList([4]);

  NotificationDetails _details(PlannedNotification n) {
    final isAlarm = n.kind == NotificationKind.doseAlarm;
    final channelId = switch (n.kind) {
      NotificationKind.doseAlarm => NotificationIds.doseAlarmChannel,
      NotificationKind.doseFollowup => NotificationIds.doseFollowupChannel,
      NotificationKind.stock => NotificationIds.stockChannel,
    };
    final channelName = switch (n.kind) {
      NotificationKind.doseAlarm => _l10n.notifChannelAlarm,
      NotificationKind.doseFollowup => _l10n.notifChannelFollowup,
      NotificationKind.stock => _l10n.notifChannelStock,
    };
    final actions = n.withActions
        ? <AndroidNotificationAction>[
            AndroidNotificationAction(
              NotificationIds.actionTaken,
              _l10n.actionTaken,
            ),
            AndroidNotificationAction(
              NotificationIds.actionSnooze,
              _l10n.actionSnooze,
            ),
            AndroidNotificationAction(
              NotificationIds.actionSkip,
              _l10n.actionSkip,
            ),
          ]
        : null;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        icon: NotificationIds.smallIcon,
        importance: isAlarm ? Importance.max : Importance.high,
        priority: isAlarm ? Priority.max : Priority.high,
        category: isAlarm ? AndroidNotificationCategory.alarm : null,
        channelBypassDnd: isAlarm,
        sound: isAlarm
            ? const UriAndroidNotificationSound(NotificationIds.alarmSoundUri)
            : null,
        vibrationPattern: isAlarm ? _vibration : null,
        additionalFlags: isAlarm ? _insistent : null,
        fullScreenIntent: isAlarm,
        autoCancel: !isAlarm,
        // Do not ring forever in an empty room; the +10 min follow-up remains.
        timeoutAfter: isAlarm ? 5 * 60 * 1000 : null,
        audioAttributesUsage: isAlarm
            ? AudioAttributesUsage.alarm
            : AudioAttributesUsage.notification,
        actions: actions,
        styleInformation: BigTextStyleInformation(n.body),
      ),
      iOS: DarwinNotificationDetails(
        interruptionLevel: isAlarm
            ? InterruptionLevel.timeSensitive
            : InterruptionLevel.active,
      ),
    );
  }
}

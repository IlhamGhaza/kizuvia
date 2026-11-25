import 'package:drift/drift.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/notifications/notification_gateway.dart';
import 'package:kizuvia/core/notifications/notification_payload.dart';
import 'package:kizuvia/core/notifications/occurrence_calculator.dart';
import 'package:kizuvia/features/dose_log/data/dose_log_repository.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;

/// Plans the next window of dose notifications and diffs it against what is
/// already scheduled (docs/04-NOTIFICATIONS.md §4). Never touches the network.
class AlarmScheduler {
  AlarmScheduler({
    required AppDatabase db,
    required Clock clock,
    required this._gateway,
    required this._l10n,
    this.maxOccurrences = 200,
    this.includeFollowups = true,
    this.window = const Duration(hours: 48),
    this.followupDelay = const Duration(minutes: 10),
  }) : _db = db,
       _clock = clock,
       _meds = MedicationRepository(db, clock),
       _logs = DoseLogRepository(db, clock);

  final AppDatabase _db;
  final Clock _clock;
  final NotificationGateway _gateway;
  final AppLocalizations _l10n;
  final MedicationRepository _meds;
  final DoseLogRepository _logs;

  /// Android 200, iOS 60 (iOS keeps only 64 pending notifications).
  final int maxOccurrences;

  /// Disabled on iOS where every extra notification eats the 64 budget.
  final bool includeFollowups;
  final Duration window;
  final Duration followupDelay;

  /// Recomputes the window and applies the difference. Idempotent.
  /// [privacyLockScreen] hides patient and medication names (docs/04 §6).
  Future<void> rescheduleAll({bool privacyLockScreen = false}) async {
    final now = _clock.now().toUtc();
    final to = now.add(window);

    final contexts = await _meds.watchScheduleContexts().first;
    final logged = await _logs.loggedKeys(now, to);
    final occurrences = expandOccurrences(
      schedules: contexts,
      from: now,
      to: to,
      loggedKeys: logged,
      limit: maxOccurrences,
    );
    final byScheduleId = {for (final c in contexts) c.schedule.id: c};

    final desired = <int, PlannedNotification>{};
    for (final g in groupOccurrences(occurrences)) {
      final ctxs = [for (final id in g.scheduleIds) byScheduleId[id]!];
      final payload = DosePayload(
        scheduleIds: g.scheduleIds,
        at: g.scheduledAt,
        patientId: g.patientId,
      ).encode();
      final main = PlannedNotification(
        id: g.notificationId,
        kind: NotificationKind.doseAlarm,
        at: g.scheduledAt,
        title: doseTitle(_l10n, ctxs, privacyLockScreen, followup: false),
        body: doseBody(_l10n, ctxs, g.scheduledAt, privacyLockScreen),
        payload: payload,
      );
      desired[main.id] = main;
      if (includeFollowups) {
        final followAt = g.scheduledAt.add(followupDelay);
        final follow = PlannedNotification(
          id: notificationIdFor('f:${g.scheduleIds.join(',')}', g.scheduledAt),
          kind: NotificationKind.doseFollowup,
          at: followAt,
          title: doseTitle(_l10n, ctxs, privacyLockScreen, followup: true),
          body: main.body,
          payload: payload,
        );
        desired[follow.id] = follow;
      }
    }

    final existing = await _db.select(_db.scheduledNotifications).get();

    for (final e in existing) {
      if (desired.containsKey(e.notificationId)) continue;
      // Past rows already fired: forgetting them must not dismiss the
      // notification that may still be in the tray.
      if (e.scheduledAt.isAfter(now)) await _gateway.cancel(e.notificationId);
      await (_db.delete(
        _db.scheduledNotifications,
      )..where((t) => t.notificationId.equals(e.notificationId))).go();
    }

    for (final n in desired.values) {
      // Same id replaces the pending one, so edits (renamed medication,
      // privacy toggle) take effect without a separate cancel.
      await _gateway.schedule(n);
      await _db
          .into(_db.scheduledNotifications)
          .insertOnConflictUpdate(
            ScheduledNotificationsCompanion.insert(
              notificationId: Value(n.id),
              scheduleId: (DosePayload.decode(n.payload)).scheduleIds.first,
              scheduledAt: n.at,
            ),
          );
    }
  }
}

/// `"{name} {strength} — {qty} {form}, {instructions}"` (docs/04 §6).
String describeDose(ScheduleContext c) {
  final m = c.medication;
  final head = [m.name, if (m.strength != null) m.strength!].join(' ');
  final qty = formatQty(m.doseQty);
  final dose = [qty, if (m.form != null) m.form!.name].join(' ');
  final tail = [dose, if ((m.instructions ?? '').isNotEmpty) m.instructions!];
  return '$head — ${tail.join(', ')}';
}

/// 1.0 -> "1", 0.5 -> "0,5" (Indonesian decimal comma).
String formatQty(double q) =>
    (q == q.roundToDouble() ? q.toInt().toString() : q.toString()).replaceAll(
      '.',
      ',',
    );

String doseTitle(
  AppLocalizations l10n,
  List<ScheduleContext> ctxs,
  bool privacy, {
  required bool followup,
}) {
  if (privacy) return l10n.notifTitlePrivate;
  final patient = ctxs.first.patientName;
  return followup ? l10n.notifFollowupTitle(patient) : l10n.notifTitle(patient);
}

String doseBody(
  AppLocalizations l10n,
  List<ScheduleContext> ctxs,
  DateTime at,
  bool privacy,
) {
  final loc = tz.getLocation(ctxs.first.schedule.timezone);
  final local = tz.TZDateTime.from(at, loc);
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  if (privacy) return l10n.notifBodyPrivate(ctxs.length, time);
  if (ctxs.length == 1) return describeDose(ctxs.first);
  return l10n.notifBodyGroup(
    ctxs.length,
    time,
    ctxs.map((c) => c.medication.name).join(', '),
  );
}

import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/notifications/alarm_scheduler.dart';
import 'package:kizuvia/core/notifications/notification_gateway.dart';
import 'package:kizuvia/core/notifications/notification_payload.dart';
import 'package:kizuvia/core/notifications/occurrence_calculator.dart';
import 'package:kizuvia/features/dose_log/data/dose_log_repository.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/features/stock/domain/stock_calculator.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';

/// Handles TAKEN / SKIP / SNOOZE. Shared by the notification action handler
/// (background isolate) and the in-app "Hari ini" screen (docs/04 §5).
class DoseActions {
  DoseActions({
    required AppDatabase db,
    required Clock clock,
    required this.gateway,
    required this.l10n,
    this.maxSnoozes = 3,
    this.snoozeDelay = const Duration(minutes: 10),
  }) : _clock = clock,
       _logs = DoseLogRepository(db, clock),
       _meds = MedicationRepository(db, clock);

  final Clock _clock;
  final NotificationGateway gateway;
  final AppLocalizations l10n;
  final int maxSnoozes;
  final Duration snoozeDelay;
  final DoseLogRepository _logs;
  final MedicationRepository _meds;

  /// Logs [status] for every schedule in [p] and cancels pending reminders.
  /// Stock is reduced by the repository for `taken`.
  Future<void> confirm(DosePayload p, DoseStatus status, {String? note}) async {
    for (final id in p.scheduleIds) {
      await _logs.record(
        scheduleId: id,
        scheduledAt: p.at,
        status: status,
        note: note,
      );
    }
    await cancelPending(p);
    if (status == DoseStatus.taken) {
      for (final id in p.scheduleIds) {
        await _notifyIfLowStock(id);
      }
    }
  }

  /// Local low-stock reminder (US-10, docs/04 §2 channel `stock`). One per
  /// medication per day: the id is derived from both, so repeats replace.
  Future<void> _notifyIfLowStock(String scheduleId) async {
    final ctx = (await _meds.watchScheduleContexts().first)
        .where((c) => c.schedule.id == scheduleId)
        .firstOrNull;
    if (ctx == null) return;
    final fresh = await _meds.get(ctx.medication.id);
    final m = fresh?.medication;
    final s = fresh?.schedule;
    if (m == null || s == null) return;
    final perDay = s.times.length;
    if (!isLowStock(
      stock: m.stockQty,
      doseQty: m.doseQty,
      dosesPerDay: perDay,
      thresholdDays: m.refillThresholdDays,
    )) {
      return;
    }
    final days = daysRemaining(
      stock: m.stockQty,
      doseQty: m.doseQty,
      dosesPerDay: perDay,
    )!.floor();
    final now = _clock.now().toUtc();
    final day = '${now.year}-${now.month}-${now.day}';
    await gateway.schedule(
      PlannedNotification(
        id: notificationIdFor('stock:${m.id}:$day', now),
        kind: NotificationKind.stock,
        at: now.add(const Duration(seconds: 2)),
        title: l10n.lowStockBadge,
        body: l10n.stockLow(m.name, days),
        payload: '',
        withActions: false,
      ),
    );
  }

  /// Removes the alarm, follow-up and snoozed copies of one dose.
  Future<void> cancelPending(DosePayload p) async {
    final key = p.scheduleIds.join(',');
    await gateway.cancel(notificationIdFor(key, p.at));
    await gateway.cancel(notificationIdFor('f:$key', p.at));
    for (var n = 1; n <= maxSnoozes; n++) {
      await gateway.cancel(notificationIdFor('z$n:$key', p.at));
    }
  }

  /// One-shot reminder after [snoozeDelay]. Returns false past [maxSnoozes].
  Future<bool> snooze(DosePayload p, {bool privacyLockScreen = false}) async {
    if (p.snoozeCount >= maxSnoozes) return false;
    final next = p.snoozed();
    final contexts = (await _meds.watchScheduleContexts().first)
        .where((c) => p.scheduleIds.contains(c.schedule.id))
        .toList();
    if (contexts.isEmpty) return false;

    final fireAt = _clock.now().toUtc().add(snoozeDelay);
    final key = p.scheduleIds.join(',');
    await gateway.schedule(
      PlannedNotification(
        id: notificationIdFor('z${next.snoozeCount}:$key', p.at),
        kind: NotificationKind.doseAlarm,
        at: fireAt,
        title: doseTitle(l10n, contexts, privacyLockScreen, followup: false),
        body: doseBody(l10n, contexts, p.at, privacyLockScreen),
        payload: next.encode(),
      ),
    );
    // The original alarm is handled; its follow-up is replaced by the snooze.
    await gateway.cancel(notificationIdFor('f:$key', p.at));
    return true;
  }
}

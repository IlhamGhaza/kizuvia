/// Which Android channel / importance a notification uses (docs/04 §2).
enum NotificationKind { doseAlarm, doseFollowup, stock }

/// One notification to show at [at]. [payload] carries ids only, never names.
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.kind,
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
    this.withActions = true,
  });

  final int id;
  final NotificationKind kind;

  /// UTC instant.
  final DateTime at;
  final String title;
  final String body;
  final String payload;
  final bool withActions;
}

/// Thin seam over the OS notification API so the scheduler is unit-testable.
abstract interface class NotificationGateway {
  Future<void> schedule(PlannedNotification n);
  Future<void> cancel(int id);
}

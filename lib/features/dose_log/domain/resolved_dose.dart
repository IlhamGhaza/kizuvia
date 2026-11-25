import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/notifications/occurrence_calculator.dart';
import 'package:kizuvia/features/dose_log/domain/dose_log.dart';
import 'package:kizuvia/features/history/domain/adherence_calculator.dart';

/// What the user sees for one planned dose.
enum DoseView { upcoming, now, taken, skipped, missed }

class ResolvedDose {
  const ResolvedDose({
    required this.context,
    required this.at,
    required this.view,
  });

  final ScheduleContext context;

  /// UTC instant.
  final DateTime at;
  final DoseView view;

  String get scheduleId => context.schedule.id;
  String get patientId => context.patientId;
  String get medicationId => context.medication.id;

  /// Counted in adherence (past, final) doses only.
  DoseStatus? get finalStatus => switch (view) {
    DoseView.taken => DoseStatus.taken,
    DoseView.skipped => DoseStatus.skipped,
    DoseView.missed => DoseStatus.missed,
    DoseView.upcoming || DoseView.now => null,
  };
}

/// Combines planned occurrences with dose logs.
///
/// - any `taken`/`skipped` log wins (taken > skipped);
/// - a server-written `missed` log counts as missed;
/// - no log and `at + grace < now` -> missed (derived on device);
/// - no log and within grace -> now; later -> upcoming.
///
/// shortcut: uses the *current* schedules, so editing a schedule rewrites the
/// derived history of unlogged days; revisit with schedule versioning (Phase 2).
List<ResolvedDose> resolveDoses({
  required Iterable<ScheduleContext> contexts,
  required Iterable<DoseLog> logs,
  required DateTime from,
  required DateTime to,
  required DateTime now,
}) {
  final byKey = <String, List<DoseStatus>>{};
  for (final l in logs) {
    byKey
        .putIfAbsent(occurrenceKey(l.scheduleId, l.scheduledAt), () => [])
        .add(l.status);
  }
  final nowUtc = now.toUtc();
  final occurrences = expandOccurrences(
    schedules: contexts,
    from: from,
    to: to,
  );
  final byId = {for (final c in contexts) c.schedule.id: c};
  return [
    for (final o in occurrences)
      () {
        final ctx = byId[o.scheduleId]!;
        final statuses = byKey[o.key];
        final grace = Duration(minutes: ctx.schedule.graceMinutes);
        final view = statuses != null
            ? switch (effectiveStatus(statuses)) {
                DoseStatus.taken => DoseView.taken,
                DoseStatus.skipped => DoseView.skipped,
                DoseStatus.missed => DoseView.missed,
              }
            : o.scheduledAt.add(grace).isBefore(nowUtc)
            ? DoseView.missed
            : !o.scheduledAt.isAfter(nowUtc)
            ? DoseView.now
            : DoseView.upcoming;
        return ResolvedDose(context: ctx, at: o.scheduledAt, view: view);
      }(),
  ];
}

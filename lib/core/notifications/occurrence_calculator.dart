import 'package:kizuvia/features/medications/domain/med_schedule.dart';
import 'package:kizuvia/features/medications/domain/medication.dart';
import 'package:timezone/timezone.dart' as tz;

/// A schedule together with its medication and patient.
class ScheduleContext {
  const ScheduleContext({
    required this.schedule,
    required this.medication,
    required this.patientName,
  });

  final MedSchedule schedule;
  final Medication medication;

  /// Only used to build notification text; never logged.
  final String patientName;

  String get patientId => medication.patientId;
}

/// One planned dose.
class Occurrence {
  const Occurrence({
    required this.scheduleId,
    required this.medicationId,
    required this.patientId,
    required this.scheduledAt,
  });

  final String scheduleId;
  final String medicationId;
  final String patientId;

  /// UTC instant.
  final DateTime scheduledAt;

  String get key => occurrenceKey(scheduleId, scheduledAt);
}

String occurrenceKey(String scheduleId, DateTime at) =>
    '$scheduleId|${at.toUtc().millisecondsSinceEpoch}';

/// Expands schedules into occurrences inside `[from, to]` (docs/04 §4).
///
/// Pure function: the caller filters out deleted schedules, inactive and PRN
/// medications, and passes [loggedKeys] (see [occurrenceKey]) for doses that
/// already have a dose_log. Requires the timezone database to be initialised.
List<Occurrence> expandOccurrences({
  required Iterable<ScheduleContext> schedules,
  required DateTime from,
  required DateTime to,
  Set<String> loggedKeys = const {},
  int? limit,
}) {
  final out = <Occurrence>[];
  final fromUtc = from.toUtc();
  final toUtc = to.toUtc();

  for (final ctx in schedules) {
    final s = ctx.schedule;
    final med = ctx.medication;
    final loc = tz.getLocation(s.timezone);
    final startOfRange = tz.TZDateTime.from(fromUtc, loc);
    final endOfRange = tz.TZDateTime.from(toUtc, loc);
    final startDay = tz.TZDateTime(
      loc,
      startOfRange.year,
      startOfRange.month,
      startOfRange.day,
    );
    final lastDay = tz.TZDateTime(
      loc,
      endOfRange.year,
      endOfRange.month,
      endOfRange.day,
    );

    // Iterate by calendar fields (not +24h) so DST-free zones and any
    // future DST zone stay on the intended wall-clock time.
    for (
      var day = startDay;
      !day.isAfter(lastDay);
      day = tz.TZDateTime(loc, day.year, day.month, day.day + 1)
    ) {
      if (!s.daysOfWeek.contains(day.weekday)) continue;
      for (final t in s.times) {
        final parts = t.split(':');
        final at = tz.TZDateTime(
          loc,
          day.year,
          day.month,
          day.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        final atUtc = at.toUtc();
        if (atUtc.isBefore(fromUtc) || atUtc.isAfter(toUtc)) continue;
        if (atUtc.isBefore(med.startDate.toUtc())) continue;
        final end = med.endDate;
        if (end != null && atUtc.isAfter(end.toUtc())) continue;
        final key = occurrenceKey(s.id, atUtc);
        if (loggedKeys.contains(key)) continue;
        out.add(
          Occurrence(
            scheduleId: s.id,
            medicationId: med.id,
            patientId: med.patientId,
            scheduledAt: atUtc,
          ),
        );
      }
    }
  }

  out.sort((a, b) {
    final c = a.scheduledAt.compareTo(b.scheduledAt);
    return c != 0 ? c : a.scheduleId.compareTo(b.scheduleId);
  });
  return limit == null ? out : out.take(limit).toList();
}

/// Occurrences of the same patient at the same minute share one notification.
class NotificationGroup {
  const NotificationGroup({
    required this.patientId,
    required this.scheduledAt,
    required this.occurrences,
  });

  final String patientId;
  final DateTime scheduledAt;
  final List<Occurrence> occurrences;

  List<String> get scheduleIds =>
      (occurrences.map((o) => o.scheduleId).toList()..sort());

  /// Deterministic id: rescheduling never creates duplicates (docs/04 §4).
  int get notificationId =>
      notificationIdFor(scheduleIds.join(','), scheduledAt);
}

List<NotificationGroup> groupOccurrences(List<Occurrence> occurrences) {
  final map = <String, List<Occurrence>>{};
  for (final o in occurrences) {
    map
        .putIfAbsent(
          '${o.patientId}|${o.scheduledAt.millisecondsSinceEpoch}',
          () => [],
        )
        .add(o);
  }
  return [
    for (final list in map.values)
      NotificationGroup(
        patientId: list.first.patientId,
        scheduledAt: list.first.scheduledAt,
        occurrences: list,
      ),
  ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
}

/// `fnv1a32("$scheduleKey|${at.toUtc().toIso8601String()}") & 0x7fffffff`.
int notificationIdFor(String scheduleKey, DateTime at) {
  final input = '$scheduleKey|${at.toUtc().toIso8601String()}';
  var hash = 0x811c9dc5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}

import 'dart:convert';

/// Payload of a dose notification. Ids and instants only: no patient or
/// medication names (safety rule 5).
class DosePayload {
  const DosePayload({
    required this.scheduleIds,
    required this.at,
    required this.patientId,
    this.snoozeCount = 0,
  });

  factory DosePayload.decode(String json) {
    final m = jsonDecode(json) as Map<String, dynamic>;
    return DosePayload(
      scheduleIds: (m['s'] as List<dynamic>).cast<String>(),
      at: DateTime.parse(m['at'] as String).toUtc(),
      patientId: m['p'] as String,
      snoozeCount: (m['n'] as int?) ?? 0,
    );
  }

  final List<String> scheduleIds;

  /// The originally planned dose time (UTC), also for snoozed notifications.
  final DateTime at;
  final String patientId;
  final int snoozeCount;

  String encode() => jsonEncode({
    's': scheduleIds,
    'at': at.toUtc().toIso8601String(),
    'p': patientId,
    'n': snoozeCount,
  });

  DosePayload snoozed() => DosePayload(
    scheduleIds: scheduleIds,
    at: at,
    patientId: patientId,
    snoozeCount: snoozeCount + 1,
  );
}

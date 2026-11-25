import 'package:kizuvia/core/domain/enums.dart';

/// Effective status per occurrence: taken > skipped > missed (docs/05 §4).
DoseStatus effectiveStatus(Iterable<DoseStatus> statuses) {
  if (statuses.contains(DoseStatus.taken)) return DoseStatus.taken;
  if (statuses.contains(DoseStatus.skipped)) return DoseStatus.skipped;
  return DoseStatus.missed;
}

/// `taken / (taken + skipped + missed)`; null when there are no doses.
double? adherence(Iterable<DoseStatus> effective) {
  var taken = 0;
  var total = 0;
  for (final s in effective) {
    total++;
    if (s == DoseStatus.taken) taken++;
  }
  return total == 0 ? null : taken / total;
}

enum DayStatus { none, allTaken, partial, hasMissed }

/// Calendar day summary (docs/07 §2 Riwayat). Skipped counts as not taken.
DayStatus dayStatus(Iterable<DoseStatus> effective) {
  final list = effective.toList();
  if (list.isEmpty) return DayStatus.none;
  final taken = list.where((s) => s == DoseStatus.taken).length;
  if (taken == list.length) return DayStatus.allTaken;
  if (list.contains(DoseStatus.missed)) return DayStatus.hasMissed;
  return DayStatus.partial;
}

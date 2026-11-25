import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/features/dose_log/domain/resolved_dose.dart';
import 'package:kizuvia/features/history/domain/adherence_calculator.dart';

class ReportMedRow {
  const ReportMedRow({
    required this.name,
    required this.schedule,
    required this.taken,
    required this.skipped,
    required this.missed,
  });

  /// "Name strength".
  final String name;

  /// "07:00, 19:00".
  final String schedule;
  final int taken;
  final int skipped;
  final int missed;

  int get total => taken + skipped + missed;

  /// 0..1, null without any dose.
  double? get adherence => total == 0 ? null : taken / total;
}

class ReportEntry {
  const ReportEntry({
    required this.at,
    required this.medication,
    required this.status,
  });

  /// UTC instant of the planned dose.
  final DateTime at;
  final String medication;
  final DoseStatus status;
}

/// Data for the doctor-facing PDF (US-12). Counts only finished doses
/// (taken / skipped / missed); upcoming ones are left out.
class ReportData {
  const ReportData({
    required this.patientName,
    required this.from,
    required this.to,
    required this.rows,
    required this.entries,
  });

  final String patientName;
  final DateTime from;
  final DateTime to;
  final List<ReportMedRow> rows;

  /// Chronological.
  final List<ReportEntry> entries;

  int get taken => rows.fold(0, (n, r) => n + r.taken);
  int get skipped => rows.fold(0, (n, r) => n + r.skipped);
  int get missed => rows.fold(0, (n, r) => n + r.missed);

  double? get adherenceOverall => adherence(entries.map((e) => e.status));
}

ReportData buildReport({
  required String patientName,
  required DateTime from,
  required DateTime to,
  required Iterable<ResolvedDose> doses,
}) {
  final finals = doses.where((d) => d.finalStatus != null).toList()
    ..sort((a, b) => a.at.compareTo(b.at));

  final byMed = <String, List<ResolvedDose>>{};
  for (final d in finals) {
    byMed.putIfAbsent(d.medicationId, () => []).add(d);
  }

  String label(ResolvedDose d) => [
    d.context.medication.name,
    if (d.context.medication.strength != null) d.context.medication.strength!,
  ].join(' ');

  final rows = [
    for (final list in byMed.values)
      ReportMedRow(
        name: label(list.first),
        schedule: list.first.context.schedule.times.join(', '),
        taken: list.where((d) => d.finalStatus == DoseStatus.taken).length,
        skipped: list.where((d) => d.finalStatus == DoseStatus.skipped).length,
        missed: list.where((d) => d.finalStatus == DoseStatus.missed).length,
      ),
  ]..sort((a, b) => a.name.compareTo(b.name));

  return ReportData(
    patientName: patientName,
    from: from,
    to: to,
    rows: rows,
    entries: [
      for (final d in finals)
        ReportEntry(at: d.at, medication: label(d), status: d.finalStatus!),
    ],
  );
}

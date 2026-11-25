import 'dart:io';
import 'dart:typed_data';

import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/features/reports/domain/report_builder.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

String _two(int n) => n.toString().padLeft(2, '0');
String _date(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';
String _time(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

/// Doctor-facing adherence report (US-12). Reports facts only: no advice,
/// no interpretation (safety rule 1). Ends with the product disclaimer.
Future<Uint8List> buildReportPdf(
  ReportData data,
  AppLocalizations l10n, {
  required DateTime generatedAt,
}) async {
  String statusText(DoseStatus s) => switch (s) {
    DoseStatus.taken => l10n.reportTaken,
    DoseStatus.skipped => l10n.reportSkipped,
    DoseStatus.missed => l10n.reportMissed,
  };
  String percent(double? v) => v == null ? '-' : '${(v * 100).round()}%';

  final doc = pw.Document(title: l10n.reportTitle, author: 'Kizuvia');
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${ctx.pageNumber} / ${ctx.pagesCount}',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ),
      build: (ctx) => [
        pw.Text(
          l10n.reportTitle,
          style: const pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(l10n.reportPatient(data.patientName)),
        pw.Text(l10n.reportPeriod(_date(data.from), _date(data.to))),
        pw.Text(
          l10n.reportGenerated(_date(generatedAt)),
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 14),
        pw.Text(
          l10n.reportSummary,
          style: const pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${l10n.reportAdherence}: ${percent(data.adherenceOverall)}   |   '
          '${l10n.reportTaken}: ${data.taken}   |   '
          '${l10n.reportSkipped}: ${data.skipped}   |   '
          '${l10n.reportMissed}: ${data.missed}',
        ),
        pw.SizedBox(height: 10),
        if (data.rows.isEmpty)
          pw.Text(l10n.reportNoData)
        else ...[
          pw.TableHelper.fromTextArray(
            context: ctx,
            headers: [
              l10n.reportMedColumn,
              l10n.reportScheduleColumn,
              l10n.reportTaken,
              l10n.reportSkipped,
              l10n.reportMissed,
              l10n.reportAdherence,
            ],
            data: [
              for (final r in data.rows)
                [
                  r.name,
                  r.schedule,
                  '${r.taken}',
                  '${r.skipped}',
                  '${r.missed}',
                  percent(r.adherence),
                ],
            ],
            headerStyle: const pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            l10n.reportDetail,
            style: const pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.TableHelper.fromTextArray(
            context: ctx,
            headers: [
              l10n.reportDateColumn,
              l10n.reportTimeColumn,
              l10n.reportMedColumn,
              l10n.reportStatusColumn,
            ],
            data: [
              for (final e in data.entries)
                [
                  _date(e.at.toLocal()),
                  _time(e.at.toLocal()),
                  e.medication,
                  statusText(e.status),
                ],
            ],
            headerStyle: const pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
        ],
        pw.SizedBox(height: 18),
        pw.Text(
          l10n.disclaimer,
          style: const pw.TextStyle(
            fontSize: 9,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ],
    ),
  );
  return doc.save();
}

/// Writes the PDF to the temp folder and removes older exports (they hold
/// health data). Returns the file path to share.
Future<String> saveReportTemp(Uint8List bytes) async {
  final dir = await getTemporaryDirectory();
  for (final f in dir.listSync()) {
    if (f is File && p.basename(f.path).startsWith('kizuvia_laporan_')) {
      await f.delete();
    }
  }
  final path = p.join(
    dir.path,
    'kizuvia_laporan_${DateTime.now().millisecondsSinceEpoch}.pdf',
  );
  await File(path).writeAsBytes(bytes, flush: true);
  return path;
}

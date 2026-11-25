import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/features/dose_log/data/dose_log_repository.dart';
import 'package:kizuvia/features/dose_log/domain/resolved_dose.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/features/patients/data/patient_repository.dart';
import 'package:kizuvia/features/reports/data/report_pdf.dart';
import 'package:kizuvia/features/reports/domain/report_builder.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

/// "Ekspor PDF untuk dokter": pick patient + range, build the PDF, share it.
Future<void> showExportReportDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final patients = await ref.read(patientRepositoryProvider).watchAll().first;
  if (!context.mounted) return;
  if (patients.isEmpty) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportNoPatients)));
    return;
  }
  var patientId = patients.first.id;
  var days = 30;

  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(l10n.exportTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (patients.length > 1)
              DropdownButtonFormField<String>(
                initialValue: patientId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.exportPatient),
                items: [
                  for (final p in patients)
                    DropdownMenuItem(value: p.id, child: Text(p.name)),
                ],
                onChanged: (v) => setState(() => patientId = v ?? patientId),
              ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final d in [7, 30, 90])
                  ChoiceChip(
                    label: Text(l10n.exportRange(d)),
                    selected: days == d,
                    onSelected: (_) => setState(() => days = d),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.exportCreate),
          ),
        ],
      ),
    ),
  );
  if (!(go ?? false) || !context.mounted) return;

  try {
    final now = ref.read(clockProvider).now();
    final today = DateTime(
      now.toLocal().year,
      now.toLocal().month,
      now.toLocal().day,
    );
    final from = today.subtract(Duration(days: days - 1));
    final to = now;
    final contexts = await ref
        .read(medicationRepositoryProvider)
        .watchScheduleContexts()
        .first;
    final logs = await ref
        .read(doseLogRepositoryProvider)
        .watchRange(from.toUtc(), to.toUtc())
        .first;
    final doses = resolveDoses(
      contexts: contexts.where((c) => c.patientId == patientId),
      logs: logs,
      from: from.toUtc(),
      to: to.toUtc(),
      now: now,
    );
    final patient = patients.firstWhere((p) => p.id == patientId);
    final data = buildReport(
      patientName: patient.name,
      from: from,
      to: today,
      doses: doses,
    );
    final bytes = await buildReportPdf(data, l10n, generatedAt: now);
    final path = await saveReportTemp(bytes);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path, mimeType: 'application/pdf')]),
    );
  } on Object {
    // No data in the message: the report contains health information.
    messenger.showSnackBar(SnackBar(content: Text(l10n.exportError)));
  }
}

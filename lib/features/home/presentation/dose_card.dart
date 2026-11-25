import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/notifications/alarm_scheduler.dart';
import 'package:kizuvia/core/widgets/status_chip.dart';
import 'package:kizuvia/features/dose_log/domain/resolved_dose.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// One dose in the timeline: name, amount, status (icon + text) and the
/// visible "Sudah minum" button. "Lewati" is in a visible overflow menu, not a
/// hidden gesture (docs/00 §7).
class DoseCard extends StatelessWidget {
  const DoseCard({
    required this.dose,
    required this.showPatient,
    required this.onTaken,
    required this.onSkip,
    required this.onOpen,
    super.key,
  });

  final ResolvedDose dose;
  final bool showPatient;
  final VoidCallback onTaken;
  final VoidCallback onSkip;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final done = dose.view == DoseView.taken || dose.view == DoseView.skipped;

    final (icon, label, color) = switch (dose.view) {
      DoseView.taken => (Icons.check_circle, l10n.statusTaken, tokens.success),
      DoseView.skipped => (
        Icons.remove_circle_outline,
        l10n.statusSkipped,
        tokens.textSecondary,
      ),
      DoseView.missed => (Icons.error, l10n.statusMissed, tokens.danger),
      DoseView.now => (Icons.notifications_active, l10n.statusNow, tokens.info),
      DoseView.upcoming => (
        Icons.access_time,
        l10n.statusUpcoming,
        tokens.textSecondary,
      ),
    };

    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showPatient)
                          Text(
                            dose.context.patientName,
                            style: text.labelMedium?.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                        Text(
                          [
                            dose.context.medication.name,
                            if (dose.context.medication.strength != null)
                              dose.context.medication.strength!,
                          ].join(' '),
                          style: text.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          describeDose(dose.context).split(' — ').last,
                          style: text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (!done)
                    PopupMenuButton<void>(
                      tooltip: l10n.skipAction,
                      itemBuilder: (_) => [
                        PopupMenuItem<void>(
                          onTap: onSkip,
                          child: Text(l10n.skipAction),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              StatusChip(icon: icon, label: label, color: color),
              if (!done) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onTaken,
                    icon: const Icon(Icons.check),
                    label: Text(l10n.takenAction),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

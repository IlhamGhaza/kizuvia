import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/notifications/alarm_scheduler.dart';
import 'package:kizuvia/features/dose_log/domain/resolved_dose.dart';
import 'package:kizuvia/features/home/presentation/dose_photo.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// The next dose still to record: due now first, then the earliest upcoming,
/// then the earliest missed one. Null when everything is recorded.
ResolvedDose? nextDose(Iterable<ResolvedDose> doses) {
  ResolvedDose? pick(DoseView v) {
    final list = doses.where((d) => d.view == v).toList()
      ..sort((a, b) => a.at.compareTo(b.at));
    return list.firstOrNull;
  }

  return pick(DoseView.now) ?? pick(DoseView.upcoming) ?? pick(DoseView.missed);
}

/// Elderly-mode home (docs/07 §2): one big card with the next dose and one
/// primary action. No filters, no timeline.
class ElderlyHome extends StatelessWidget {
  const ElderlyHome({
    required this.doses,
    required this.onTaken,
    required this.onOpen,
    super.key,
  });

  final List<ResolvedDose> doses;
  final void Function(ResolvedDose) onTaken;
  final void Function(ResolvedDose) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final dose = nextDose(doses);

    if (dose == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 72, color: tokens.success),
              const SizedBox(height: AppSpacing.lg),
              Text(
                doses.isEmpty ? l10n.todayNothing : l10n.allDoneToday,
                style: text.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final m = dose.context.medication;
    final sameTime = doses
        .where(
          (d) =>
              d.at == dose.at &&
              d.scheduleId != dose.scheduleId &&
              d.patientId == dose.patientId &&
              (d.view == DoseView.now ||
                  d.view == DoseView.upcoming ||
                  d.view == DoseView.missed),
        )
        .length;
    final missed = dose.view == DoseView.missed;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text(l10n.elderlyNextDose, style: text.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: InkWell(
            onTap: () => onOpen(dose),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DosePhoto(path: m.photoPath),
                  if (m.photoPath != null)
                    const SizedBox(height: AppSpacing.lg),
                  Text(dose.context.patientName, style: text.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    [m.name, if (m.strength != null) m.strength!].join(' '),
                    style: text.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    describeDose(dose.context).split(' — ').last,
                    style: text.titleLarge,
                  ),
                  if (missed) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(Icons.error, color: tokens.danger),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          l10n.statusMissed,
                          style: text.titleMedium?.copyWith(
                            color: tokens.danger,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (sameTime > 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(l10n.elderlyMoreAtSameTime(sameTime)),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          onPressed: () => onTaken(dose),
          icon: const Icon(Icons.check),
          label: Text(l10n.takenAction),
        ),
      ],
    );
  }
}

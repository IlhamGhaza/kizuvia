import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Per-brand steps to disable battery optimisation (docs/04 §3).
/// Shown once in onboarding and again under Pengaturan > "Alarm tidak bunyi?".
class BatteryGuide extends StatelessWidget {
  const BatteryGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      l10n.batteryXiaomi,
      l10n.batteryOppo,
      l10n.batteryVivo,
      l10n.batterySamsung,
      l10n.batteryOther,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.batteryBody, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.lg),
        for (final s in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(s, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ),
      ],
    );
  }
}

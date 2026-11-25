import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/features/onboarding/presentation/battery_guide.dart';
import 'package:kizuvia/features/onboarding/presentation/permission_actions.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// T1.1 disclaimer + consent, T1.2 permissions + battery guide.
/// Steps: 0 welcome/disclaimer/consent, 1 permissions, 2 battery guide.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  bool _consent = false;

  Future<void> _next() async {
    final settings = ref.read(settingsControllerProvider.notifier);
    if (_step == 0) {
      await settings.setConsent(given: true);
    }
    if (_step == 1) {
      await settings.markPermissionsSeen();
    }
    if (_step == 2) {
      await settings.completeOnboarding();
      return; // router redirects to home
    }
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final isLast = _step == 2;
    final canContinue = _step != 0 || _consent;

    final body = switch (_step) {
      0 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onbWelcomeTitle, style: text.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.onbWelcomeBody, style: text.bodyLarge),
          const SizedBox(height: AppSpacing.xl),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(l10n.disclaimer, style: text.bodyLarge),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Not pre-checked (docs/08 §2, UU PDP).
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _consent,
            onChanged: (v) => setState(() => _consent = v ?? false),
            title: Text(l10n.consentLabel, style: text.bodyMedium),
          ),
        ],
      ),
      1 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.permTitle, style: text.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.permBody, style: text.bodyLarge),
          const SizedBox(height: AppSpacing.xl),
          const PermissionActions(),
        ],
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.batteryTitle, style: text.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          const BatteryGuide(),
        ],
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: body,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: canContinue ? _next : null,
                    child: Text(
                      isLast ? l10n.startAction : l10n.continueAction,
                    ),
                  ),
                  if (_step == 1)
                    TextButton(onPressed: _next, child: Text(l10n.skipForNow)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

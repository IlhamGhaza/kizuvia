import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kizuvia/app/router.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/notifications/notification_providers.dart';
import 'package:kizuvia/features/onboarding/presentation/battery_guide.dart';
import 'package:kizuvia/features/onboarding/presentation/permission_actions.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:kizuvia/features/settings/presentation/app_lock.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.elderlyMode),
            subtitle: Text(l10n.elderlyModeHint),
            value: settings.elderlyMode,
            onChanged: (v) => controller.setElderlyMode(on: v),
          ),
          SwitchListTile(
            title: Text(l10n.privacyLock),
            subtitle: Text(l10n.privacyLockHint),
            value: settings.privacyLockScreen,
            onChanged: (v) => controller.setPrivacyLockScreen(on: v),
          ),
          SwitchListTile(
            title: Text(l10n.appLock),
            subtitle: Text(l10n.appLockHint),
            value: settings.appLock,
            onChanged: (v) async {
              // Prove the device can authenticate before turning it on, so
              // the user cannot lock themselves out.
              if (v && !await authenticate(l10n.appLockReason)) return;
              await controller.setAppLock(on: v);
            },
          ),
          ListTile(
            minTileHeight: AppSpacing.minTouch,
            leading: const Icon(Icons.alarm),
            title: Text(l10n.alarmHelpTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.alarmHelp),
          ),
          if (kDebugMode)
            ListTile(
              minTileHeight: AppSpacing.minTouch,
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Uji alarm (debug)'),
              onTap: () => context.push(AppRoutes.alarmTest),
            ),
          if (kDebugMode)
            ListTile(
              minTileHeight: AppSpacing.minTouch,
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Gallery (debug)'),
              onTap: () => context.push(AppRoutes.devGallery),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              l10n.disclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Alarm tidak bunyi?": current permissions + battery guide (docs/04 §3).
class AlarmHelpScreen extends ConsumerWidget {
  const AlarmHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Re-check permissions every time the screen is opened.
    ref.watch(alarmPermissionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.alarmHelpTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: const [
          PermissionActions(),
          SizedBox(height: AppSpacing.xl),
          BatteryGuide(),
        ],
      ),
    );
  }
}

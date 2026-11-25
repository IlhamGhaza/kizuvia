import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/notifications/notification_providers.dart';
import 'package:kizuvia/core/notifications/system_settings.dart';
import 'package:kizuvia/core/widgets/status_chip.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Two buttons that request notification and exact-alarm permission, or a
/// "granted" chip when already allowed. Used in onboarding and help screen.
class PermissionActions extends ConsumerWidget {
  const PermissionActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final perms = ref.watch(alarmPermissionsProvider).value;
    final service = ref.read(notificationServiceProvider);
    final system = ref.read(systemSettingsProvider);

    Widget row({
      required bool granted,
      required String label,
      required Future<void> Function() request,
    }) {
      if (granted) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: StatusChip(
            icon: Icons.check_circle,
            label: '$label: ${l10n.permGranted}',
            color: context.tokens.success,
          ),
        );
      }
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () async {
            await request();
            ref.invalidate(alarmPermissionsProvider);
          },
          child: Text(label),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row(
          granted: perms?.notifications ?? false,
          label: l10n.permNotifAction,
          request: service.requestNotificationPermission,
        ),
        const SizedBox(height: AppSpacing.md),
        row(
          granted: perms?.exactAlarms ?? false,
          label: l10n.permExactAction,
          request: service.requestExactAlarmPermission,
        ),
        const SizedBox(height: AppSpacing.md),
        row(
          granted: perms?.dndAccess ?? false,
          label: l10n.permDndAction,
          request: system.openDndAccess,
        ),
        const SizedBox(height: AppSpacing.md),
        row(
          granted: perms?.fullScreen ?? false,
          label: l10n.permFullScreenAction,
          request: system.openFullScreenIntentSettings,
        ),
      ],
    );
  }
}

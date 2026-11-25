import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/notifications/alarm_scheduler.dart';
import 'package:kizuvia/core/notifications/notification_payload.dart';
import 'package:kizuvia/core/notifications/notification_providers.dart';
import 'package:kizuvia/features/home/presentation/dose_photo.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:timezone/timezone.dart' as tz;

/// Opened by tapping a notification or a dose card: `/dose/:scheduleId?at=ISO`.
class DoseDetailScreen extends ConsumerWidget {
  const DoseDetailScreen({
    required this.scheduleId,
    required this.at,
    super.key,
  });

  final String scheduleId;

  /// Planned time (UTC) of the dose; null if the link was malformed.
  final DateTime? at;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final contexts = ref.watch(scheduleContextsProvider).value ?? const [];
    final ctx = contexts.where((c) => c.schedule.id == scheduleId).firstOrNull;

    if (ctx == null || at == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.doseDetailTitle)),
        body: Center(child: Text(l10n.doseNotFound)),
      );
    }
    final local = tz.TZDateTime.from(
      at!,
      tz.getLocation(ctx.schedule.timezone),
    );
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final payload = DosePayload(
      scheduleIds: [scheduleId],
      at: at!,
      patientId: ctx.patientId,
    );

    Future<void> act(DoseStatus s) async {
      final router = GoRouter.of(context);
      await ref.read(doseActionsProvider).confirm(payload, s);
      if (router.canPop()) router.pop();
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.doseDetailTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          if (ctx.medication.photoPath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: DosePhoto(path: ctx.medication.photoPath, height: 280),
            ),
          Text(ctx.patientName, style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            [
              ctx.medication.name,
              if (ctx.medication.strength != null) ctx.medication.strength!,
            ].join(' '),
            style: text.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(describeDose(ctx).split(' — ').last, style: text.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.scheduledFor(time), style: text.bodyLarge),
          const SizedBox(height: AppSpacing.xxl),
          FilledButton.icon(
            onPressed: () => act(DoseStatus.taken),
            icon: const Icon(Icons.check),
            label: Text(l10n.takenAction),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () => act(DoseStatus.skipped),
            child: Text(l10n.skipAction),
          ),
        ],
      ),
    );
  }
}

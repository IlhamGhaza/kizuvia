import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kizuvia/app/router.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/notifications/notification_payload.dart';
import 'package:kizuvia/core/notifications/notification_providers.dart';
import 'package:kizuvia/core/notifications/occurrence_calculator.dart';
import 'package:kizuvia/core/widgets/app_banner.dart';
import 'package:kizuvia/core/widgets/empty_state.dart';
import 'package:kizuvia/features/dose_log/data/dose_providers.dart';
import 'package:kizuvia/features/dose_log/domain/resolved_dose.dart';
import 'package:kizuvia/features/home/presentation/dose_card.dart';
import 'package:kizuvia/features/home/presentation/elderly_home.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:kizuvia/features/stock/domain/stock_calculator.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:timezone/timezone.dart' as tz;

/// Beranda "Hari ini" (T1.7): patient filter, banners, timeline by hour.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  String? _patientFilter;

  List<ScheduleContext> get _contexts =>
      ref.watch(scheduleContextsProvider).value ?? const <ScheduleContext>[];

  DosePayload _payload(ResolvedDose d) => DosePayload(
    scheduleIds: [d.scheduleId],
    at: d.at,
    patientId: d.patientId,
  );

  String _hhmm(DateTime utc, String zone) {
    final t = tz.TZDateTime.from(utc, tz.getLocation(zone));
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _taken(ResolvedDose d) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final now = ref.read(clockProvider).now().toLocal();
    await ref.read(doseActionsProvider).confirm(_payload(d), DoseStatus.taken);
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.confirmedTaken(d.context.medication.name, time)),
        ),
      );
  }

  Future<void> _skip(ResolvedDose d) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(doseActionsProvider)
        .confirm(_payload(d), DoseStatus.skipped);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.confirmedSkipped(d.context.medication.name)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final doses = ref.watch(todayDosesProvider);
    final perms = ref.watch(alarmPermissionsProvider).value;
    final contexts = _contexts;
    final elderly = ref.watch(
      settingsControllerProvider.select((s) => s.elderlyMode),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: doses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.loadError,
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(todayDosesProvider),
        ),
        data: (all) {
          final hasAnySchedule = contexts.isNotEmpty;
          if (!hasAnySchedule) {
            return EmptyState(
              icon: Icons.medication_outlined,
              title: l10n.todayEmptyTitle,
              body: l10n.todayEmptyBody,
              actionLabel: l10n.homeEmptyAction,
              onAction: () => context.go(AppRoutes.patients),
            );
          }
          if (elderly) {
            return ElderlyHome(
              doses: all,
              onTaken: _taken,
              onOpen: (d) => context.push(
                '/dose/${d.scheduleId}?at=${d.at.toIso8601String()}',
              ),
            );
          }
          final patients = {
            for (final d in all) d.patientId: d.context.patientName,
          };
          final list = all
              .where(
                (d) => _patientFilter == null || d.patientId == _patientFilter,
              )
              .toList();
          final remaining = all.every(
            (d) => d.view == DoseView.taken || d.view == DoseView.skipped,
          );

          // Group by local hour of the schedule's own timezone.
          final groups = <String, List<ResolvedDose>>{};
          for (final d in list) {
            groups
                .putIfAbsent(_hhmm(d.at, d.context.schedule.timezone), () => [])
                .add(d);
          }
          final keys = groups.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (perms != null && !perms.notifications)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppBanner(
                    text: l10n.bannerNotifOff,
                    onTap: () => context.push(AppRoutes.alarmHelp),
                  ),
                )
              else if (perms != null && !perms.exactAlarms)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppBanner(
                    text: l10n.bannerExactOff,
                    onTap: () => context.push(AppRoutes.alarmHelp),
                  ),
                ),
              ..._lowStockBanners(l10n),
              if (patients.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.filterAll),
                        selected: _patientFilter == null,
                        onSelected: (_) =>
                            setState(() => _patientFilter = null),
                      ),
                      for (final e in patients.entries)
                        ChoiceChip(
                          label: Text(e.value),
                          selected: _patientFilter == e.key,
                          onSelected: (_) =>
                              setState(() => _patientFilter = e.key),
                        ),
                    ],
                  ),
                ),
              if (all.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    l10n.todayNothing,
                    style: text.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                )
              else if (remaining)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(l10n.allDoneToday, style: text.titleMedium),
                ),
              for (final k in keys) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.sm,
                  ),
                  child: Text(k, style: text.titleLarge),
                ),
                for (final d in groups[k]!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: DoseCard(
                      dose: d,
                      showPatient: patients.length > 1,
                      onTaken: () => _taken(d),
                      onSkip: () => _skip(d),
                      onOpen: () => context.push(
                        '/dose/${d.scheduleId}?at=${d.at.toIso8601String()}',
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _lowStockBanners(AppLocalizations l10n) {
    final out = <Widget>[];
    final seen = <String>{};
    for (final c in _contexts) {
      final m = c.medication;
      if (!seen.add(m.id)) continue;
      final perDay = _contexts
          .where((x) => x.medication.id == m.id)
          .fold<int>(0, (n, x) => n + x.schedule.times.length);
      if (isLowStock(
        stock: m.stockQty,
        doseQty: m.doseQty,
        dosesPerDay: perDay,
        thresholdDays: m.refillThresholdDays,
      )) {
        final days = daysRemaining(
          stock: m.stockQty,
          doseQty: m.doseQty,
          dosesPerDay: perDay,
        )!.floor();
        out.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppBanner(
              icon: Icons.inventory_2_outlined,
              text: l10n.stockLow(m.name, days),
              onTap: () => context.push('/meds/${m.id}'),
            ),
          ),
        );
      }
    }
    return out;
  }
}

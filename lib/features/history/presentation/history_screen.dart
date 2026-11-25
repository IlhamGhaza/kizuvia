import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:kizuvia/app/theme/app_radius.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/widgets/empty_state.dart';
import 'package:kizuvia/features/dose_log/data/dose_providers.dart';
import 'package:kizuvia/features/dose_log/domain/resolved_dose.dart';
import 'package:kizuvia/features/history/domain/adherence_calculator.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/features/patients/data/patient_repository.dart';
import 'package:kizuvia/features/reports/presentation/export_report.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_screen.g.dart';

/// Resolved doses between [from] and [to] (UTC instants).
@riverpod
AsyncValue<List<ResolvedDose>> historyDoses(
  Ref ref,
  DateTime from,
  DateTime to,
) {
  final now = ref.watch(clockProvider).now();
  final contexts = ref.watch(scheduleContextsProvider);
  final logs = ref.watch(logsInRangeProvider(from, to));
  if (contexts.hasError) {
    return AsyncError(contexts.error!, contexts.stackTrace!);
  }
  if (logs.hasError) return AsyncError(logs.error!, logs.stackTrace!);
  if (!contexts.hasValue || !logs.hasValue) return const AsyncLoading();
  return AsyncData(
    resolveDoses(
      contexts: contexts.requireValue,
      logs: logs.requireValue,
      from: from,
      to: to,
      now: now,
    ),
  );
}

/// Riwayat (T1.9): monthly calendar + 7/30-day adherence.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late DateTime _month;
  DateTime? _selected;
  String? _patientId;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final now = ref.watch(clockProvider).now().toLocal();
    final today = DateTime(now.year, now.month, now.day);

    // One range covers the shown month and the last 30 days.
    final monthEnd = DateTime(_month.year, _month.month + 1);
    final thirtyAgo = today.subtract(const Duration(days: 29));
    final from = (thirtyAgo.isBefore(_month) ? thirtyAgo : _month).toUtc();
    final to =
        (monthEnd.isAfter(today.add(const Duration(days: 1)))
                ? monthEnd
                : today.add(const Duration(days: 1)))
            .toUtc();

    final doses = ref.watch(historyDosesProvider(from, to));
    final patients = ref.watch(patientsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          IconButton(
            tooltip: l10n.exportAction,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => showExportReportDialog(context, ref),
          ),
        ],
      ),
      body: doses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.loadError,
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(historyDosesProvider(from, to)),
        ),
        data: (all) {
          final list = all
              .where((d) => _patientId == null || d.patientId == _patientId)
              .where((d) => d.finalStatus != null)
              .toList();
          if (all.isEmpty) {
            return EmptyState(icon: Icons.history, title: l10n.historyEmpty);
          }

          double? pct(int days, [String? medId]) {
            final since = today.subtract(Duration(days: days - 1)).toUtc();
            return adherence(
              list
                  .where((d) => !d.at.isBefore(since))
                  .where((d) => medId == null || d.medicationId == medId)
                  .map((d) => d.finalStatus!),
            );
          }

          String adherenceText(int days) {
            final p = pct(days);
            return p == null
                ? '${l10n.adherenceNone} ($days)'
                : l10n.adherenceLabel(days, (p * 100).round());
          }

          // Day -> effective statuses (local day of the device).
          final byDay = <DateTime, List<ResolvedDose>>{};
          for (final d in list) {
            final l = d.at.toLocal();
            byDay
                .putIfAbsent(DateTime(l.year, l.month, l.day), () => [])
                .add(d);
          }

          final meds = <String, String>{
            for (final d in list) d.medicationId: d.context.medication.name,
          };

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (patients.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.filterAll),
                        selected: _patientId == null,
                        onSelected: (_) => setState(() => _patientId = null),
                      ),
                      for (final p in patients)
                        ChoiceChip(
                          label: Text(p.name),
                          selected: _patientId == p.id,
                          onSelected: (_) => setState(() => _patientId = p.id),
                        ),
                    ],
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(adherenceText(7), style: text.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(adherenceText(30), style: text.titleMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: l10n.back,
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(
                      () => _month = DateTime(_month.year, _month.month - 1),
                    ),
                  ),
                  Text(
                    DateFormat.yMMMM('id').format(_month),
                    style: text.titleMedium,
                  ),
                  IconButton(
                    tooltip: l10n.continueAction,
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(
                      () => _month = DateTime(_month.year, _month.month + 1),
                    ),
                  ),
                ],
              ),
              _CalendarGrid(
                month: _month,
                today: today,
                byDay: byDay,
                selected: _selected,
                onSelect: (d) => setState(() => _selected = d),
              ),
              const SizedBox(height: AppSpacing.md),
              const _Legend(),
              if (_selected != null && byDay[_selected] != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  DateFormat.yMMMMEEEEd('id').format(_selected!),
                  style: text.titleMedium,
                ),
                for (final d in byDay[_selected]!)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(d.context.medication.name),
                    subtitle: Text(DateFormat.Hm().format(d.at.toLocal())),
                    trailing: Text(switch (d.view) {
                      DoseView.taken => l10n.statusTaken,
                      DoseView.skipped => l10n.statusSkipped,
                      _ => l10n.statusMissed,
                    }),
                  ),
              ],
              if (meds.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(l10n.perMedication, style: text.titleMedium),
                for (final e in meds.entries)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.value),
                    trailing: Text(
                      pct(30, e.key) == null
                          ? '-'
                          : '${(pct(30, e.key)! * 100).round()}%',
                      style: text.titleMedium?.copyWith(
                        color: tokens.textSecondary,
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
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.today,
    required this.byDay,
    required this.selected,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime today;
  final Map<DateTime, List<ResolvedDose>> byDay;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lead = DateTime(month.year, month.month).weekday - 1; // Monday first
    final cells = <Widget>[
      for (final w in [
        l10n.dayMon,
        l10n.dayTue,
        l10n.dayWed,
        l10n.dayThu,
        l10n.dayFri,
        l10n.daySat,
        l10n.daySun,
      ])
        Center(child: Text(w, style: text.labelMedium)),
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var d = 1; d <= daysInMonth; d++)
        _cell(
          context,
          DateTime(month.year, month.month, d),
          l10n,
          tokens,
          text,
        ),
    ];
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.xs,
      crossAxisSpacing: AppSpacing.xs,
      childAspectRatio: 0.8,
      children: cells,
    );
  }

  Widget _cell(
    BuildContext context,
    DateTime day,
    AppLocalizations l10n,
    AppTokens tokens,
    TextTheme text,
  ) {
    final doses = byDay[day];
    final status = dayStatus(doses?.map((d) => d.finalStatus!) ?? const []);
    final (icon, color, label) = switch (status) {
      DayStatus.allTaken => (
        Icons.check_circle,
        tokens.success,
        l10n.legendAll,
      ),
      DayStatus.partial => (
        Icons.timelapse,
        tokens.warning,
        l10n.legendPartial,
      ),
      DayStatus.hasMissed => (Icons.error, tokens.danger, l10n.legendMissed),
      DayStatus.none => (null, tokens.border, l10n.legendNone),
    };
    final isSelected = selected == day;
    return Semantics(
      button: doses != null,
      selected: isSelected,
      label: '${day.day}, $label',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: AppRadius.cardBorder,
        onTap: doses == null ? null : () => onSelect(day),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardBorder,
            color: isSelected ? tokens.primarySoft : null,
            border: Border.all(
              color: day == today
                  ? Theme.of(context).colorScheme.primary
                  : tokens.border,
              width: day == today ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${day.day}', style: text.labelLarge),
              if (icon != null) Icon(icon, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    Widget item(IconData? icon, Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon ?? Icons.crop_square, size: 18, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        item(Icons.check_circle, tokens.success, l10n.legendAll),
        item(Icons.timelapse, tokens.warning, l10n.legendPartial),
        item(Icons.error, tokens.danger, l10n.legendMissed),
        item(null, tokens.textSecondary, l10n.legendNone),
      ],
    );
  }
}

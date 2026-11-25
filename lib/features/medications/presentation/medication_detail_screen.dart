import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:kizuvia/app/theme/app_radius.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/notifications/alarm_scheduler.dart';
import 'package:kizuvia/core/widgets/status_chip.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/features/medications/presentation/medication_labels.dart';
import 'package:kizuvia/features/stock/domain/stock_calculator.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Medication detail with stock (T1.4, T1.8).
class MedicationDetailScreen extends ConsumerWidget {
  const MedicationDetailScreen({required this.medicationId, super.key});

  final String medicationId;

  Future<void> _restock(
    BuildContext context,
    WidgetRef ref,
    MedicationWithSchedule item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final qty = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.restock),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: InputDecoration(labelText: l10n.restockQty),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              ctx,
              double.tryParse(controller.text.trim().replaceAll(',', '.')),
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (qty == null || qty <= 0) return;
    final m = item.medication;
    await ref
        .read(medicationRepositoryProvider)
        .save(m.copyWith(stockQty: (m.stockQty ?? 0) + qty), item.schedule);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteMedTitle),
        content: Text(l10n.deleteMedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(medicationRepositoryProvider).delete(medicationId);
      router.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final item = ref.watch(medicationProvider(medicationId)).value;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.medDetailTitle)),
        body: const SizedBox.shrink(),
      );
    }
    final m = item.medication;
    final s = item.schedule;
    final perDay = s?.times.length ?? 0;
    final days = daysRemaining(
      stock: m.stockQty,
      doseQty: m.doseQty,
      dosesPerDay: perDay,
    );
    final low =
        !m.isPrn &&
        isLowStock(
          stock: m.stockQty,
          doseQty: m.doseQty,
          dosesPerDay: perDay,
          thresholdDays: m.refillThresholdDays,
        );

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: text.bodyMedium?.copyWith(
                color: context.tokens.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: text.bodyLarge)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medDetailTitle),
        actions: [
          IconButton(
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/meds/$medicationId/edit'),
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (m.photoPath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: ClipRRect(
                borderRadius: AppRadius.cardBorder,
                child: Image.file(
                  File(m.photoPath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          Text(
            [m.name, if (m.strength != null) m.strength!].join(' '),
            style: text.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          row(
            l10n.fieldDoseQty,
            [
              formatQty(m.doseQty),
              if (m.form != null) formLabel(l10n, m.form!),
            ].join(' '),
          ),
          row(
            l10n.fieldTimes,
            m.isPrn || s == null
                ? l10n.prnNote
                : '${s.times.join(', ')}\n${daysSummary(l10n, s.daysOfWeek)}',
          ),
          if (m.mealRelation != null)
            row(l10n.fieldMeal, mealLabel(l10n, m.mealRelation!)),
          if ((m.instructions ?? '').isNotEmpty)
            row(l10n.fieldInstructions, m.instructions!),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.stockQty == null
                        ? l10n.stockUnknown
                        : l10n.stockLeft(formatQty(m.stockQty!)),
                    style: text.titleMedium,
                  ),
                  if (days != null)
                    Text(
                      l10n.stockDaysLeft(days.floor()),
                      style: text.bodyMedium,
                    ),
                  if (low) ...[
                    const SizedBox(height: AppSpacing.sm),
                    StatusChip(
                      icon: Icons.inventory_2_outlined,
                      label: l10n.stockLow(m.name, days!.floor()),
                      color: context.tokens.warning,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => _restock(context, ref, item),
                    icon: const Icon(Icons.add_box_outlined),
                    label: Text(l10n.restock),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

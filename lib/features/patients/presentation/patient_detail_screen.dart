import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/widgets/confirm_delete.dart';
import 'package:kizuvia/core/widgets/empty_state.dart';
import 'package:kizuvia/core/widgets/status_chip.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/features/patients/data/patient_repository.dart';
import 'package:kizuvia/features/stock/domain/stock_calculator.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

enum _Action { edit, delete }

class PatientDetailScreen extends ConsumerStatefulWidget {
  const PatientDetailScreen({required this.patientId, super.key});

  final String patientId;

  @override
  ConsumerState<PatientDetailScreen> createState() =>
      _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen> {
  String get patientId => widget.patientId;

  /// Non-null while in medication selection mode.
  Set<String>? _selected;

  void _toggle(String id) => setState(() {
    final s = _selected!;
    s.contains(id) ? s.remove(id) : s.add(id);
  });

  Future<void> _deleteMeds(List<String> ids) async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmDelete(
      context,
      title: ids.length == 1
          ? l10n.deleteMedTitle
          : l10n.deleteMedsTitle(ids.length),
      body: l10n.deleteMedBody,
    );
    if (!ok) return;
    final repo = ref.read(medicationRepositoryProvider);
    for (final id in ids) {
      await repo.delete(id);
    }
    if (mounted) setState(() => _selected = null);
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePatientTitle),
        content: Text(l10n.deletePatientBody),
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
      await ref.read(patientRepositoryProvider).delete(patientId);
      router.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final patientsAsync = ref.watch(patientsProvider);
    final patient = patientsAsync.value
        ?.where((p) => p.id == patientId)
        .firstOrNull;
    final meds = ref.watch(patientMedicationsProvider(patientId));

    if (patientsAsync.hasValue && patient == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final selected = _selected;
    final medList = meds.value ?? const [];
    return PopScope(
      canPop: selected == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _selected = null);
      },
      child: Scaffold(
        appBar: selected == null
            ? AppBar(
                title: Text(patient?.name ?? ''),
                actions: [
                  if (medList.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() => _selected = {}),
                      child: Text(l10n.selectItems),
                    ),
                  IconButton(
                    tooltip: l10n.educationTitle,
                    icon: const Icon(Icons.menu_book_outlined),
                    onPressed: () =>
                        context.push('/patients/$patientId/education'),
                  ),
                  IconButton(
                    tooltip: l10n.edit,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.push('/patients/$patientId/edit'),
                  ),
                  IconButton(
                    tooltip: l10n.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _confirmDelete,
                  ),
                ],
              )
            : AppBar(
                leading: IconButton(
                  tooltip: l10n.cancelSelection,
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selected = null),
                ),
                title: Text(l10n.selectedCount(selected.length)),
                actions: [
                  IconButton(
                    tooltip: l10n.selectAll,
                    icon: const Icon(Icons.select_all),
                    onPressed: () => setState(
                      () => _selected = {
                        for (final m in medList) m.medication.id,
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: selected.isEmpty
                        ? null
                        : () => _deleteMeds(selected.toList()),
                  ),
                ],
              ),
        floatingActionButton: selected != null
            ? null
            : FloatingActionButton.extended(
                onPressed: () => context.push('/patients/$patientId/meds/new'),
                icon: const Icon(Icons.add),
                label: Text(l10n.addMed),
              ),
        body: meds.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.loadError,
            actionLabel: l10n.retry,
            onAction: () =>
                ref.invalidate(patientMedicationsProvider(patientId)),
          ),
          data: (list) {
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.medication_outlined,
                title: l10n.medsEmpty,
                actionLabel: l10n.addMed,
                onAction: () => context.push('/patients/$patientId/meds/new'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                96,
              ),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final m = list[i].medication;
                final s = list[i].schedule;
                final low =
                    !m.isPrn &&
                    isLowStock(
                      stock: m.stockQty,
                      doseQty: m.doseQty,
                      dosesPerDay: s?.times.length ?? 0,
                      thresholdDays: m.refillThresholdDays,
                    );
                final checked = selected?.contains(m.id) ?? false;
                return Card(
                  child: ListTile(
                    minTileHeight: AppSpacing.xxxl + AppSpacing.lg,
                    selected: checked,
                    leading: selected == null
                        ? null
                        : Checkbox(
                            value: checked,
                            onChanged: (_) => _toggle(m.id),
                          ),
                    title: Text(
                      [m.name, if (m.strength != null) m.strength!].join(' '),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.isPrn || s == null
                              ? l10n.prnNote
                              : l10n.scheduleSummary(s.times.join(', ')),
                        ),
                        if (low)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: StatusChip(
                              icon: Icons.inventory_2_outlined,
                              label: l10n.lowStockBadge,
                              color: context.tokens.warning,
                            ),
                          ),
                      ],
                    ),
                    trailing: selected != null
                        ? null
                        : PopupMenuButton<_Action>(
                            onSelected: (a) => switch (a) {
                              _Action.edit => context.push(
                                '/meds/${m.id}/edit',
                              ),
                              _Action.delete => _deleteMeds([m.id]),
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: _Action.edit,
                                child: Text(l10n.edit),
                              ),
                              PopupMenuItem(
                                value: _Action.delete,
                                child: Text(l10n.delete),
                              ),
                            ],
                          ),
                    onTap: () => selected == null
                        ? context.push('/meds/${m.id}')
                        : _toggle(m.id),
                    onLongPress: () => selected == null
                        ? setState(() => _selected = {m.id})
                        : _toggle(m.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/widgets/confirm_delete.dart';
import 'package:kizuvia/core/widgets/empty_state.dart';
import 'package:kizuvia/features/patients/data/patient_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

enum _Action { edit, delete }

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  /// Non-null while in selection mode.
  Set<String>? _selected;

  bool get _selecting => _selected != null;

  void _toggle(String id) => setState(() {
    final s = _selected!;
    s.contains(id) ? s.remove(id) : s.add(id);
  });

  Future<void> _delete(List<String> ids) async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmDelete(
      context,
      title: ids.length == 1
          ? l10n.deletePatientTitle
          : l10n.deletePatientsTitle(ids.length),
      body: l10n.deletePatientBody,
    );
    if (!ok) return;
    final repo = ref.read(patientRepositoryProvider);
    for (final id in ids) {
      await repo.delete(id);
    }
    if (mounted) setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final patients = ref.watch(patientsProvider);
    final list = patients.value ?? const [];
    final selected = _selected;
    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _selected = null);
      },
      child: Scaffold(
        appBar: selected == null
            ? AppBar(
                title: Text(l10n.patientsTitle),
                actions: [
                  if (list.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() => _selected = {}),
                      child: Text(l10n.selectItems),
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
                      () => _selected = {for (final p in list) p.id},
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: selected.isEmpty
                        ? null
                        : () => _delete(selected.toList()),
                  ),
                ],
              ),
        floatingActionButton: !_selecting && list.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () => context.push('/patients/new'),
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(l10n.patientsEmptyAction),
              )
            : null,
        body: patients.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.loadError,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(patientsProvider),
          ),
          data: (list) {
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.group_outlined,
                title: l10n.patientsEmpty,
                actionLabel: l10n.patientsEmptyAction,
                onAction: () => context.push('/patients/new'),
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
                final p = list[i];
                final checked = selected?.contains(p.id) ?? false;
                return Card(
                  child: ListTile(
                    minTileHeight: AppSpacing.xxxl + AppSpacing.lg,
                    selected: checked,
                    leading: selected == null
                        ? const Icon(Icons.person_outline)
                        : Checkbox(
                            value: checked,
                            onChanged: (_) => _toggle(p.id),
                          ),
                    title: Text(p.name),
                    subtitle: p.conditions.isEmpty
                        ? null
                        : Text(p.conditions.join(', ')),
                    trailing: selected != null
                        ? null
                        : PopupMenuButton<_Action>(
                            onSelected: (a) => switch (a) {
                              _Action.edit => context.push(
                                '/patients/${p.id}/edit',
                              ),
                              _Action.delete => _delete([p.id]),
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
                        ? context.push('/patients/${p.id}')
                        : _toggle(p.id),
                    onLongPress: () => selected == null
                        ? setState(() => _selected = {p.id})
                        : _toggle(p.id),
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

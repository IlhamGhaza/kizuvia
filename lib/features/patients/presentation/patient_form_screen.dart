import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/features/patients/data/patient_repository.dart';
import 'package:kizuvia/features/patients/domain/patient.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Create (`patientId == null`) or edit a patient (T1.3).
/// Conditions are free-text labels only (safety rule 2).
class PatientFormScreen extends ConsumerStatefulWidget {
  const PatientFormScreen({super.key, this.patientId});

  final String? patientId;

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _year = TextEditingController();
  final _conditions = TextEditingController();
  final _notes = TextEditingController();
  Patient? _existing;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.patientId;
    if (id != null) {
      final p = await ref.read(patientRepositoryProvider).get(id);
      if (p != null) {
        _existing = p;
        _name.text = p.name;
        _year.text = p.birthYear?.toString() ?? '';
        _conditions.text = p.conditions.join(', ');
        _notes.text = p.notes ?? '';
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _year.dispose();
    _conditions.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    final labels = _conditions.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final result = await ref
        .read(patientRepositoryProvider)
        .save(
          (_existing ?? const Patient(id: '', name: '')).copyWith(
            name: _name.text,
            birthYear: int.tryParse(_year.text.trim()),
            conditions: labels,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    result.when(
      ok: (_) => router.pop(),
      err: (_) =>
          messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.patientId == null ? l10n.patientFormNew : l10n.patientFormEdit,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(labelText: l10n.fieldName),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l10n.errNameRequired : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _year,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l10n.fieldBirthYear),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return null;
                      final y = int.tryParse(t);
                      return y == null || y < 1900 || y > DateTime.now().year
                          ? l10n.errBirthYear
                          : null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _conditions,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.fieldConditions,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _notes,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(labelText: l10n.fieldNotes),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
    );
  }
}

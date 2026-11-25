import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/features/auth/data/auth_repository.dart';
import 'package:kizuvia/features/family/data/family_service.dart';
import 'package:kizuvia/features/family/presentation/family_failure_text.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Enter an invite code, or arrive here from `kizuvia://invite/{code}`.
/// Also used to create a family (`createMode`).
class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key, this.code, this.createMode = false});

  final String? code;
  final bool createMode;

  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _code = TextEditingController(text: widget.code ?? '');
  final _name = TextEditingController();
  final _family = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _family.dispose();
    super.dispose();
  }

  Future<bool> _confirmAttach() async {
    final l10n = AppLocalizations.of(context);
    final count = await ref.read(accountMigratorProvider).localPatientCount();
    if (count == 0 || !mounted) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.attachLocalTitle),
        content: Text(l10n.attachLocalBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.attachAction),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    if (!await _confirmAttach()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final service = ref.read(familyServiceProvider);
    final display = _name.text.trim().isEmpty ? null : _name.text.trim();
    final r = widget.createMode
        ? await service.create(_family.text, displayName: display)
        : await service.join(_code.text, displayName: display);
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(
      ok: (_) => router.go('/family'),
      err: (f) => setState(() => _error = familyFailureText(l10n, f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final signedIn = ref.watch(authUserProvider).value != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.createMode ? l10n.createFamilyAction : l10n.joinFamilyAction,
        ),
      ),
      body: !signedIn
          ? Center(
              child: FilledButton(
                onPressed: () => context.push('/login'),
                child: Text(l10n.signInAction),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  if (widget.createMode)
                    TextFormField(
                      controller: _family,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.fieldFamilyName,
                      ),
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? l10n.errFamilyName : null,
                    )
                  else
                    TextFormField(
                      controller: _code,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: l10n.fieldInviteCode,
                      ),
                      validator: (v) => (v ?? '').trim().length == 6
                          ? null
                          : l10n.errInviteCode,
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(labelText: l10n.fieldYourName),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(
                      widget.createMode
                          ? l10n.createFamilyAction
                          : l10n.joinAction,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

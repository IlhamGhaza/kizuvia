import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/errors/app_failure.dart';
import 'package:kizuvia/core/supabase/supabase_config.dart';
import 'package:kizuvia/features/auth/data/auth_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Email magic-link login (T2.2): the link reopens the app via
/// kizuvia://login-callback and supabase_flutter completes the session.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _linkSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Future<void> _send() async {
    if (!(_emailKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(authRepositoryProvider).sendOtp(_email.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      r.when(
        ok: (_) => _linkSent = true,
        err: (f) => _error = f is AuthFailure && f.message == 'rate limited'
            ? l10n.errRateLimit
            : l10n.errSendCode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          if (!SupabaseConfig.isReady) ...[
            Text(
              '${l10n.accountUnavailable} (${SupabaseConfig.initError ?? (SupabaseConfig.isConfigured ? 'init' : 'config')})',
              style: text.bodyLarge,
            ),
          ] else ...[
            Text(l10n.loginBody, style: text.bodyLarge),
            const SizedBox(height: AppSpacing.xl),
            Form(
              key: _emailKey,
              child: TextFormField(
                controller: _email,
                enabled: !_linkSent,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: l10n.fieldEmail),
                validator: (v) =>
                    _emailRe.hasMatch((v ?? '').trim()) ? null : l10n.errEmail,
                onFieldSubmitted: (_) => _linkSent ? null : _send(),
              ),
            ),
            if (_linkSent) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.codeSentTo(_email.text.trim()), style: text.bodyMedium),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Text(
                  _error!,
                  style: text.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _busy ? null : _send,
              child: Text(_linkSent ? l10n.resendCode : l10n.sendCode),
            ),
          ],
        ],
      ),
    );
  }
}

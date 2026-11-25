import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kizuvia/app/router.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_ui/material_ui.dart';

/// Device biometric / PIN prompt. False on cancel, error or no screen lock.
Future<bool> authenticate(String reason) async {
  try {
    final auth = LocalAuthentication();
    if (!await auth.isDeviceSupported()) return false;
    return await auth.authenticate(localizedReason: reason);
  } on PlatformException {
    return false;
  }
}

/// Covers the app with a lock screen when [AppSettings.appLock] is on.
/// Locks again whenever the app goes to the background.
/// The dose screen (`/dose/...`, opened by the alarm) stays reachable so a
/// patient can always confirm a dose (docs/08).
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  bool _locked = true;
  bool _prompting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // `paused` only: the biometric prompt itself causes `inactive`.
    if (state == AppLifecycleState.paused && !_prompting) {
      setState(() => _locked = true);
    }
    if (state == AppLifecycleState.resumed && _locked) _unlock();
  }

  Future<void> _unlock() async {
    if (_prompting || !mounted) return;
    if (!ref.read(settingsControllerProvider).appLock) return;
    _prompting = true;
    final ok = await authenticate(AppLocalizations.of(context).appLockReason);
    _prompting = false;
    if (ok && mounted) setState(() => _locked = false);
  }

  bool get _onDoseRoute => ref
      .read(routerProvider)
      .routeInformationProvider
      .value
      .uri
      .path
      .startsWith('/dose/');

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(
      settingsControllerProvider.select((s) => s.appLock),
    );
    if (!enabled || !_locked || _onDoseRoute) return widget.child;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.appLockTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(onPressed: _unlock, child: Text(l10n.appLockUnlock)),
            ],
          ),
        ),
      ),
    );
  }
}

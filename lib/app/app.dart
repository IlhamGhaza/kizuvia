import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kizuvia/app/router.dart';
import 'package:kizuvia/app/theme/app_theme.dart';
import 'package:kizuvia/core/notifications/notification_providers.dart';
import 'package:kizuvia/core/push/push_registrar.dart';
import 'package:kizuvia/core/sync/sync_controller.dart';
import 'package:kizuvia/core/utils/device_l10n.dart';
import 'package:kizuvia/features/family/data/family_service.dart';
import 'package:kizuvia/features/home/data/home_widget_sync.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:kizuvia/features/settings/presentation/app_lock.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class KizuviaApp extends ConsumerStatefulWidget {
  const KizuviaApp({super.key});

  @override
  ConsumerState<KizuviaApp> createState() => _KizuviaAppState();
}

class _KizuviaAppState extends ConsumerState<KizuviaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Resume: permissions may have changed in system settings, and the 48 h
  /// window must be rolled forward (docs/04 §4).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(alarmPermissionsProvider);
      ref.read(alarmAutoRescheduleProvider.notifier).run();
      ref.read(syncControllerProvider.notifier).syncNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keeps OS alarms in sync with the database (app start + every change).
    ref.watch(alarmAutoRescheduleProvider);
    // Cloud sync (only active when signed in and attached to a family).
    ref.watch(syncControllerProvider);
    ref.watch(pushRegistrarProvider);
    ref.watch(autoFamilyProvider);
    ref.watch(homeWidgetSyncProvider);
    final elderly = ref.watch(
      settingsControllerProvider.select((s) => s.elderlyMode),
    );
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      routerConfig: ref.watch(routerProvider),
      theme: AppTheme.light(elderly: elderly),
      darkTheme: AppTheme.dark(elderly: elderly),
      themeMode: ThemeMode.system,
      builder: (context, child) => AppLockGate(child: child!),
      localeResolutionCallback: (device, _) => resolveLocale(device),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
    );
  }
}

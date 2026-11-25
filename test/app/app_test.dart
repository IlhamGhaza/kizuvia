import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/app/app.dart';
import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/app/theme/app_theme.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/notifications/notification_gateway.dart';
import 'package:kizuvia/core/notifications/notification_providers.dart';
import 'package:kizuvia/core/notifications/notification_service.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Records notifications instead of calling the OS plugin.
class FakeNotificationService extends NotificationService {
  FakeNotificationService()
    : super(
        FlutterLocalNotificationsPlugin(),
        lookupAppLocalizations(const Locale('id')),
      );

  final List<PlannedNotification> scheduled = [];

  @override
  Future<void> schedule(PlannedNotification n) async => scheduled.add(n);

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<bool> canScheduleExact() async => true;

  @override
  Future<bool> notificationsEnabled() async => true;
}

Future<ProviderScope> appScope({
  FakeNotificationService? notifications,
  List<Override> extraOverrides = const [],
  Map<String, Object> prefs = const {},
  Widget child = const KizuviaApp(),
}) async {
  tzdata.initializeTimeZones();
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  // Not closed: closing needs real async, which testWidgets' fake clock blocks.
  final db = AppDatabase(NativeDatabase.memory());
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      appDatabaseProvider.overrideWithValue(db),
      notificationServiceProvider.overrideWithValue(
        notifications ?? FakeNotificationService(),
      ),
      alarmPermissionsProvider.overrideWith(
        (ref) async =>
            const AlarmPermissions(notifications: true, exactAlarms: true),
      ),
      ...extraOverrides,
    ],
    child: child,
  );
}

/// Drift streams need real async time; plain pumpAndSettle would spin forever
/// on the loading indicator.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// Unmounts the app so Drift's stream timers are cancelled before teardown.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  // Let disposal timers (Riverpod, Drift streams) fire.
  await tester.pump(const Duration(minutes: 2));
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  testWidgets('first launch shows disclaimer; consent is not pre-checked', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('id')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(await appScope());
    await settle(tester);
    expect(find.textContaining('tidak memberikan saran medis'), findsOneWidget);
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isFalse);
    final next = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(next.onPressed, isNull);
    await unmount(tester);
  });

  testWidgets('onboarding -> permissions -> battery guide -> Hari ini', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('id')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(await appScope());
    await settle(tester);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Lanjut'));
    await settle(tester);
    expect(find.text('Izinkan pengingat'), findsOneWidget);

    await tester.tap(find.text('Lanjut'));
    await settle(tester);
    expect(find.text('Agar alarm tidak terlewat'), findsOneWidget);

    await tester.tap(find.text('Mulai'));
    await settle(tester);
    expect(find.text('Hari ini'), findsWidgets);
    expect(find.text('Belum ada obat'), findsOneWidget);
    expect(find.text('Pasien'), findsOneWidget); // bottom nav

    final sp = await SharedPreferences.getInstance();
    expect(sp.getBool(SettingsKeys.onboardingDone), isTrue);
    await unmount(tester);
  });

  testWidgets('returning user skips onboarding', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('id')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(
      await appScope(
        prefs: {
          SettingsKeys.onboardingDone: true,
          SettingsKeys.consentGiven: true,
        },
      ),
    );
    await settle(tester);
    expect(find.text('Belum ada obat'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('layout survives 200% text scale', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('id')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      await appScope(
        prefs: {SettingsKeys.onboardingDone: true},
        child: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: KizuviaApp(),
        ),
      ),
    );
    await settle(tester);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  group('themes', () {
    test('tokens registered in light, dark and elderly', () {
      for (final t in [
        AppTheme.light(),
        AppTheme.dark(),
        AppTheme.light(elderly: true),
        AppTheme.dark(elderly: true),
      ]) {
        expect(t.extension<AppTokens>(), isNotNull);
        expect(t.useMaterial3, isTrue);
        expect(t.textTheme.bodyLarge?.fontFamily, 'PlusJakartaSans');
      }
    });

    test('elderly: 22sp base, buttons >= 64dp', () {
      final t = AppTheme.light(elderly: true);
      expect(t.textTheme.bodyLarge!.fontSize, closeTo(22, 0.01));
      final size = t.filledButtonTheme.style!.minimumSize!.resolve({});
      expect(size!.height, AppSpacing.elderlyButtonHeight);
    });

    test('normal: buttons >= 48dp', () {
      final size = AppTheme.light().filledButtonTheme.style!.minimumSize!
          .resolve({});
      expect(size!.height, greaterThanOrEqualTo(AppSpacing.minTouch));
    });
  });
}

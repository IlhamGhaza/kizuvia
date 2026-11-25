import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_repository.g.dart';

/// App preferences (not health data). Backed by SharedPreferences so the
/// background notification isolate can read them too.
class AppSettings {
  const AppSettings({
    this.onboardingDone = false,
    this.consentGiven = false,
    this.permissionsSeen = false,
    this.elderlyMode = false,
    this.privacyLockScreen = false,
    this.appLock = false,
    this.familyId,
    this.familyName,
  });

  final bool onboardingDone;
  final bool consentGiven;

  /// The notification/alarm permission step of onboarding was shown.
  final bool permissionsSeen;
  final bool elderlyMode;
  final bool privacyLockScreen;

  /// Device biometric / PIN required to open the app (T3.5).
  final bool appLock;

  /// Family this device is attached to (null = local-only mode). Cached so
  /// the app knows it while offline.
  final String? familyId;
  final String? familyName;

  AppSettings copyWith({
    bool? onboardingDone,
    bool? consentGiven,
    bool? permissionsSeen,
    bool? elderlyMode,
    bool? privacyLockScreen,
    bool? appLock,
    String? familyId,
    String? familyName,
    bool clearFamily = false,
  }) => AppSettings(
    onboardingDone: onboardingDone ?? this.onboardingDone,
    consentGiven: consentGiven ?? this.consentGiven,
    permissionsSeen: permissionsSeen ?? this.permissionsSeen,
    elderlyMode: elderlyMode ?? this.elderlyMode,
    privacyLockScreen: privacyLockScreen ?? this.privacyLockScreen,
    appLock: appLock ?? this.appLock,
    familyId: clearFamily ? null : (familyId ?? this.familyId),
    familyName: clearFamily ? null : (familyName ?? this.familyName),
  );
}

abstract final class SettingsKeys {
  static const onboardingDone = 'onboarding_done';
  static const consentGiven = 'consent_given';
  static const permissionsSeen = 'permissions_seen';
  static const elderlyMode = 'elderly_mode';
  static const privacyLockScreen = 'privacy_lock_screen';
  static const appLock = 'app_lock';
  static const familyId = 'family_id';
  static const familyName = 'family_name';
}

AppSettings readSettings(SharedPreferences p) => AppSettings(
  onboardingDone: p.getBool(SettingsKeys.onboardingDone) ?? false,
  consentGiven: p.getBool(SettingsKeys.consentGiven) ?? false,
  permissionsSeen: p.getBool(SettingsKeys.permissionsSeen) ?? false,
  elderlyMode: p.getBool(SettingsKeys.elderlyMode) ?? false,
  privacyLockScreen: p.getBool(SettingsKeys.privacyLockScreen) ?? false,
  appLock: p.getBool(SettingsKeys.appLock) ?? false,
  familyId: p.getString(SettingsKeys.familyId),
  familyName: p.getString(SettingsKeys.familyName),
);

/// Overridden in `main()` with the loaded instance.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('override sharedPreferencesProvider');

@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  @override
  AppSettings build() => readSettings(ref.watch(sharedPreferencesProvider));

  Future<void> _set(String key, bool value, AppSettings next) async {
    state = next;
    await ref.read(sharedPreferencesProvider).setBool(key, value);
  }

  Future<void> setConsent({required bool given}) => _set(
    SettingsKeys.consentGiven,
    given,
    state.copyWith(consentGiven: given),
  );

  Future<void> completeOnboarding() => _set(
    SettingsKeys.onboardingDone,
    true,
    state.copyWith(onboardingDone: true),
  );

  Future<void> markPermissionsSeen() => _set(
    SettingsKeys.permissionsSeen,
    true,
    state.copyWith(permissionsSeen: true),
  );

  Future<void> setElderlyMode({required bool on}) =>
      _set(SettingsKeys.elderlyMode, on, state.copyWith(elderlyMode: on));

  Future<void> setPrivacyLockScreen({required bool on}) => _set(
    SettingsKeys.privacyLockScreen,
    on,
    state.copyWith(privacyLockScreen: on),
  );

  Future<void> setAppLock({required bool on}) =>
      _set(SettingsKeys.appLock, on, state.copyWith(appLock: on));

  Future<void> setFamily(String id, String name) async {
    state = state.copyWith(familyId: id, familyName: name);
    final p = ref.read(sharedPreferencesProvider);
    await p.setString(SettingsKeys.familyId, id);
    await p.setString(SettingsKeys.familyName, name);
  }

  Future<void> clearFamily() async {
    state = state.copyWith(clearFamily: true);
    final p = ref.read(sharedPreferencesProvider);
    await p.remove(SettingsKeys.familyId);
    await p.remove(SettingsKeys.familyName);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationL10n)
final notificationL10nProvider = NotificationL10nProvider._();

final class NotificationL10nProvider
    extends
        $FunctionalProvider<
          AppLocalizations,
          AppLocalizations,
          AppLocalizations
        >
    with $Provider<AppLocalizations> {
  NotificationL10nProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationL10nProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationL10nHash();

  @$internal
  @override
  $ProviderElement<AppLocalizations> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLocalizations create(Ref ref) {
    return notificationL10n(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLocalizations value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLocalizations>(value),
    );
  }
}

String _$notificationL10nHash() => r'cf15ed0acb38e9eb307a14df024b883aa526bde7';

/// Overridden in `main()` with the instance that was `init()`-ed in bootstrap.

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

/// Overridden in `main()` with the instance that was `init()`-ed in bootstrap.

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  /// Overridden in `main()` with the instance that was `init()`-ed in bootstrap.
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'113f282f920cb13d98eed3ce426f11e3173e4a7b';

@ProviderFor(alarmScheduler)
final alarmSchedulerProvider = AlarmSchedulerProvider._();

final class AlarmSchedulerProvider
    extends $FunctionalProvider<AlarmScheduler, AlarmScheduler, AlarmScheduler>
    with $Provider<AlarmScheduler> {
  AlarmSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alarmSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alarmSchedulerHash();

  @$internal
  @override
  $ProviderElement<AlarmScheduler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AlarmScheduler create(Ref ref) {
    return alarmScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AlarmScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AlarmScheduler>(value),
    );
  }
}

String _$alarmSchedulerHash() => r'2651af3fca8791bb8f8a3b081ee3a9972b349b04';

@ProviderFor(doseActions)
final doseActionsProvider = DoseActionsProvider._();

final class DoseActionsProvider
    extends $FunctionalProvider<DoseActions, DoseActions, DoseActions>
    with $Provider<DoseActions> {
  DoseActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'doseActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$doseActionsHash();

  @$internal
  @override
  $ProviderElement<DoseActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DoseActions create(Ref ref) {
    return doseActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DoseActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DoseActions>(value),
    );
  }
}

String _$doseActionsHash() => r'982e19ffb69227cbe3cdf5cb13206faa702a28ea';

/// Keeps the OS alarms in sync with the database: runs whenever schedules,
/// medications or the privacy setting change (docs/04 §4). Watch it once at
/// the app root.

@ProviderFor(AlarmAutoReschedule)
final alarmAutoRescheduleProvider = AlarmAutoRescheduleProvider._();

/// Keeps the OS alarms in sync with the database: runs whenever schedules,
/// medications or the privacy setting change (docs/04 §4). Watch it once at
/// the app root.
final class AlarmAutoRescheduleProvider
    extends $NotifierProvider<AlarmAutoReschedule, void> {
  /// Keeps the OS alarms in sync with the database: runs whenever schedules,
  /// medications or the privacy setting change (docs/04 §4). Watch it once at
  /// the app root.
  AlarmAutoRescheduleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alarmAutoRescheduleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alarmAutoRescheduleHash();

  @$internal
  @override
  AlarmAutoReschedule create() => AlarmAutoReschedule();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$alarmAutoRescheduleHash() =>
    r'7ac7f2e901e9cb4f8ce373bd6683ef2b58f135f7';

/// Keeps the OS alarms in sync with the database: runs whenever schedules,
/// medications or the privacy setting change (docs/04 §4). Watch it once at
/// the app root.

abstract class _$AlarmAutoReschedule extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(alarmPermissions)
final alarmPermissionsProvider = AlarmPermissionsProvider._();

final class AlarmPermissionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AlarmPermissions>,
          AlarmPermissions,
          FutureOr<AlarmPermissions>
        >
    with $FutureModifier<AlarmPermissions>, $FutureProvider<AlarmPermissions> {
  AlarmPermissionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alarmPermissionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alarmPermissionsHash();

  @$internal
  @override
  $FutureProviderElement<AlarmPermissions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AlarmPermissions> create(Ref ref) {
    return alarmPermissions(ref);
  }
}

String _$alarmPermissionsHash() => r'55c1860cd2a2a91472163db44144e6f161f79f5e';

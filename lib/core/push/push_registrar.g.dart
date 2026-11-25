// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_registrar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps this device's FCM token in `device_tokens` while signed in and
/// attached to a family (T2.6, docs/04 §7), and shows caregiver alerts that
/// arrive while the app is open (FCM only displays them in the background).

@ProviderFor(PushRegistrar)
final pushRegistrarProvider = PushRegistrarProvider._();

/// Keeps this device's FCM token in `device_tokens` while signed in and
/// attached to a family (T2.6, docs/04 §7), and shows caregiver alerts that
/// arrive while the app is open (FCM only displays them in the background).
final class PushRegistrarProvider
    extends $NotifierProvider<PushRegistrar, void> {
  /// Keeps this device's FCM token in `device_tokens` while signed in and
  /// attached to a family (T2.6, docs/04 §7), and shows caregiver alerts that
  /// arrive while the app is open (FCM only displays them in the background).
  PushRegistrarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushRegistrarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushRegistrarHash();

  @$internal
  @override
  PushRegistrar create() => PushRegistrar();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$pushRegistrarHash() => r'c191bfff23241da9137bf3af88a977140562db5b';

/// Keeps this device's FCM token in `device_tokens` while signed in and
/// attached to a family (T2.6, docs/04 §7), and shows caregiver alerts that
/// arrive while the app is open (FCM only displays them in the background).

abstract class _$PushRegistrar extends $Notifier<void> {
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs the [SyncEngine] when signed in and attached to a family: at start,
/// on resume, 2 s after a local change, on realtime events, every 5 minutes,
/// and with exponential backoff (2^n s, max 10 min) while offline
/// (docs/05-SYNC.md §1). Alarms never wait for any of this.

@ProviderFor(SyncController)
final syncControllerProvider = SyncControllerProvider._();

/// Runs the [SyncEngine] when signed in and attached to a family: at start,
/// on resume, 2 s after a local change, on realtime events, every 5 minutes,
/// and with exponential backoff (2^n s, max 10 min) while offline
/// (docs/05-SYNC.md §1). Alarms never wait for any of this.
final class SyncControllerProvider
    extends $NotifierProvider<SyncController, SyncUiState> {
  /// Runs the [SyncEngine] when signed in and attached to a family: at start,
  /// on resume, 2 s after a local change, on realtime events, every 5 minutes,
  /// and with exponential backoff (2^n s, max 10 min) while offline
  /// (docs/05-SYNC.md §1). Alarms never wait for any of this.
  SyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncControllerHash();

  @$internal
  @override
  SyncController create() => SyncController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncUiState>(value),
    );
  }
}

String _$syncControllerHash() => r'e7a299158b925efdeb7ac79e821cbe9ff610f860';

/// Runs the [SyncEngine] when signed in and attached to a family: at start,
/// on resume, 2 s after a local change, on realtime events, every 5 minutes,
/// and with exponential backoff (2^n s, max 10 min) while offline
/// (docs/05-SYNC.md §1). Alarms never wait for any of this.

abstract class _$SyncController extends $Notifier<SyncUiState> {
  SyncUiState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SyncUiState, SyncUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncUiState, SyncUiState>,
              SyncUiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

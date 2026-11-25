// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Redirects to onboarding until it is completed. Auth/family redirects are
/// added in Phase 2 (docs/02-ARCHITECTURE.md §6).

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// Redirects to onboarding until it is completed. Auth/family redirects are
/// added in Phase 2 (docs/02-ARCHITECTURE.md §6).

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Redirects to onboarding until it is completed. Auth/family redirects are
  /// added in Phase 2 (docs/02-ARCHITECTURE.md §6).
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'303738f953950f00ef280ae738f4412a5cb423a6';

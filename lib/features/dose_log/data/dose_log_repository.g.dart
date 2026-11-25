// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(doseLogRepository)
final doseLogRepositoryProvider = DoseLogRepositoryProvider._();

final class DoseLogRepositoryProvider
    extends
        $FunctionalProvider<
          DoseLogRepository,
          DoseLogRepository,
          DoseLogRepository
        >
    with $Provider<DoseLogRepository> {
  DoseLogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'doseLogRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$doseLogRepositoryHash();

  @$internal
  @override
  $ProviderElement<DoseLogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DoseLogRepository create(Ref ref) {
    return doseLogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DoseLogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DoseLogRepository>(value),
    );
  }
}

String _$doseLogRepositoryHash() => r'ee511d84d47637ba672e57ffbcf36c3738ecc4c5';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(familyService)
final familyServiceProvider = FamilyServiceProvider._();

final class FamilyServiceProvider
    extends $FunctionalProvider<FamilyService, FamilyService, FamilyService>
    with $Provider<FamilyService> {
  FamilyServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyServiceHash();

  @$internal
  @override
  $ProviderElement<FamilyService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FamilyService create(Ref ref) {
    return familyService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FamilyService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FamilyService>(value),
    );
  }
}

String _$familyServiceHash() => r'a7ccd66af12e11774ce400c423765650d94ddb11';

@ProviderFor(accountMigrator)
final accountMigratorProvider = AccountMigratorProvider._();

final class AccountMigratorProvider
    extends
        $FunctionalProvider<AccountMigrator, AccountMigrator, AccountMigrator>
    with $Provider<AccountMigrator> {
  AccountMigratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountMigratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountMigratorHash();

  @$internal
  @override
  $ProviderElement<AccountMigrator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountMigrator create(Ref ref) {
    return accountMigrator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountMigrator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountMigrator>(value),
    );
  }
}

String _$accountMigratorHash() => r'10a5388157227f59f859c02edd8a5b3105be7146';

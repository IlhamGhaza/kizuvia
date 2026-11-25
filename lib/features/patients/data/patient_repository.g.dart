// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(patientRepository)
final patientRepositoryProvider = PatientRepositoryProvider._();

final class PatientRepositoryProvider
    extends
        $FunctionalProvider<
          PatientRepository,
          PatientRepository,
          PatientRepository
        >
    with $Provider<PatientRepository> {
  PatientRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'patientRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$patientRepositoryHash();

  @$internal
  @override
  $ProviderElement<PatientRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PatientRepository create(Ref ref) {
    return patientRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PatientRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PatientRepository>(value),
    );
  }
}

String _$patientRepositoryHash() => r'84effa7de3b1ec0533eecbeac97964cdf1f9f658';

@ProviderFor(patients)
final patientsProvider = PatientsProvider._();

final class PatientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Patient>>,
          List<Patient>,
          Stream<List<Patient>>
        >
    with $FutureModifier<List<Patient>>, $StreamProvider<List<Patient>> {
  PatientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'patientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$patientsHash();

  @$internal
  @override
  $StreamProviderElement<List<Patient>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Patient>> create(Ref ref) {
    return patients(ref);
  }
}

String _$patientsHash() => r'204119f308259648b76d595dd99af10d7aa786fd';

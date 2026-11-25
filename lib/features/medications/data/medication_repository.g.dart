// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(medicationRepository)
final medicationRepositoryProvider = MedicationRepositoryProvider._();

final class MedicationRepositoryProvider
    extends
        $FunctionalProvider<
          MedicationRepository,
          MedicationRepository,
          MedicationRepository
        >
    with $Provider<MedicationRepository> {
  MedicationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'medicationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$medicationRepositoryHash();

  @$internal
  @override
  $ProviderElement<MedicationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MedicationRepository create(Ref ref) {
    return medicationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MedicationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MedicationRepository>(value),
    );
  }
}

String _$medicationRepositoryHash() =>
    r'404834247ca6e7f282119ee4b7939978d509e4cb';

@ProviderFor(patientMedications)
final patientMedicationsProvider = PatientMedicationsFamily._();

final class PatientMedicationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MedicationWithSchedule>>,
          List<MedicationWithSchedule>,
          Stream<List<MedicationWithSchedule>>
        >
    with
        $FutureModifier<List<MedicationWithSchedule>>,
        $StreamProvider<List<MedicationWithSchedule>> {
  PatientMedicationsProvider._({
    required PatientMedicationsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'patientMedicationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$patientMedicationsHash();

  @override
  String toString() {
    return r'patientMedicationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<MedicationWithSchedule>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MedicationWithSchedule>> create(Ref ref) {
    final argument = this.argument as String;
    return patientMedications(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PatientMedicationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$patientMedicationsHash() =>
    r'58a6d98b93a6126257227a789a220447b18a1641';

final class PatientMedicationsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<MedicationWithSchedule>>,
          String
        > {
  PatientMedicationsFamily._()
    : super(
        retry: null,
        name: r'patientMedicationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PatientMedicationsProvider call(String patientId) =>
      PatientMedicationsProvider._(argument: patientId, from: this);

  @override
  String toString() => r'patientMedicationsProvider';
}

@ProviderFor(medication)
final medicationProvider = MedicationFamily._();

final class MedicationProvider
    extends
        $FunctionalProvider<
          AsyncValue<MedicationWithSchedule?>,
          MedicationWithSchedule?,
          Stream<MedicationWithSchedule?>
        >
    with
        $FutureModifier<MedicationWithSchedule?>,
        $StreamProvider<MedicationWithSchedule?> {
  MedicationProvider._({
    required MedicationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'medicationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$medicationHash();

  @override
  String toString() {
    return r'medicationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<MedicationWithSchedule?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<MedicationWithSchedule?> create(Ref ref) {
    final argument = this.argument as String;
    return medication(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MedicationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$medicationHash() => r'd156908970012f5094b14e95735944630366a4e6';

final class MedicationFamily extends $Family
    with $FunctionalFamilyOverride<Stream<MedicationWithSchedule?>, String> {
  MedicationFamily._()
    : super(
        retry: null,
        name: r'medicationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MedicationProvider call(String id) =>
      MedicationProvider._(argument: id, from: this);

  @override
  String toString() => r'medicationProvider';
}

@ProviderFor(scheduleContexts)
final scheduleContextsProvider = ScheduleContextsProvider._();

final class ScheduleContextsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScheduleContext>>,
          List<ScheduleContext>,
          Stream<List<ScheduleContext>>
        >
    with
        $FutureModifier<List<ScheduleContext>>,
        $StreamProvider<List<ScheduleContext>> {
  ScheduleContextsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleContextsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleContextsHash();

  @$internal
  @override
  $StreamProviderElement<List<ScheduleContext>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ScheduleContext>> create(Ref ref) {
    return scheduleContexts(ref);
  }
}

String _$scheduleContextsHash() => r'ed2b900b0d62921214ab51a312c4372d5f6bb035';

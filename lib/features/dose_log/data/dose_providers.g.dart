// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Current time, refreshed every minute so statuses move upcoming -> now -> missed.

@ProviderFor(minuteTick)
final minuteTickProvider = MinuteTickProvider._();

/// Current time, refreshed every minute so statuses move upcoming -> now -> missed.

final class MinuteTickProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, Stream<DateTime>>
    with $FutureModifier<DateTime>, $StreamProvider<DateTime> {
  /// Current time, refreshed every minute so statuses move upcoming -> now -> missed.
  MinuteTickProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'minuteTickProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$minuteTickHash();

  @$internal
  @override
  $StreamProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime> create(Ref ref) {
    return minuteTick(ref);
  }
}

String _$minuteTickHash() => r'35d540f44c06994d02ee4f7d444f5eb97956b766';

@ProviderFor(logsInRange)
final logsInRangeProvider = LogsInRangeFamily._();

final class LogsInRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DoseLog>>,
          List<DoseLog>,
          Stream<List<DoseLog>>
        >
    with $FutureModifier<List<DoseLog>>, $StreamProvider<List<DoseLog>> {
  LogsInRangeProvider._({
    required LogsInRangeFamily super.from,
    required (DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'logsInRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$logsInRangeHash();

  @override
  String toString() {
    return r'logsInRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<DoseLog>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DoseLog>> create(Ref ref) {
    final argument = this.argument as (DateTime, DateTime);
    return logsInRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is LogsInRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$logsInRangeHash() => r'603b5421c66835b02605a20034bb73f5b39cea54';

final class LogsInRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<Stream<List<DoseLog>>, (DateTime, DateTime)> {
  LogsInRangeFamily._()
    : super(
        retry: null,
        name: r'logsInRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LogsInRangeProvider call(DateTime from, DateTime to) =>
      LogsInRangeProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'logsInRangeProvider';
}

/// Doses of the device-local "today".

@ProviderFor(todayDoses)
final todayDosesProvider = TodayDosesProvider._();

/// Doses of the device-local "today".

final class TodayDosesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ResolvedDose>>,
          AsyncValue<List<ResolvedDose>>,
          AsyncValue<List<ResolvedDose>>
        >
    with $Provider<AsyncValue<List<ResolvedDose>>> {
  /// Doses of the device-local "today".
  TodayDosesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayDosesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayDosesHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<ResolvedDose>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<ResolvedDose>> create(Ref ref) {
    return todayDoses(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<ResolvedDose>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<ResolvedDose>>>(
        value,
      ),
    );
  }
}

String _$todayDosesHash() => r'fd7ec48b10f5ace31731a7eef1339d0620380727';

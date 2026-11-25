// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolved doses between [from] and [to] (UTC instants).

@ProviderFor(historyDoses)
final historyDosesProvider = HistoryDosesFamily._();

/// Resolved doses between [from] and [to] (UTC instants).

final class HistoryDosesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ResolvedDose>>,
          AsyncValue<List<ResolvedDose>>,
          AsyncValue<List<ResolvedDose>>
        >
    with $Provider<AsyncValue<List<ResolvedDose>>> {
  /// Resolved doses between [from] and [to] (UTC instants).
  HistoryDosesProvider._({
    required HistoryDosesFamily super.from,
    required (DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'historyDosesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyDosesHash();

  @override
  String toString() {
    return r'historyDosesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<ResolvedDose>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<ResolvedDose>> create(Ref ref) {
    final argument = this.argument as (DateTime, DateTime);
    return historyDoses(ref, argument.$1, argument.$2);
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

  @override
  bool operator ==(Object other) {
    return other is HistoryDosesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyDosesHash() => r'c78145e7c5d29c05641d11ed1aa6f43b303a6562';

/// Resolved doses between [from] and [to] (UTC instants).

final class HistoryDosesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<List<ResolvedDose>>,
          (DateTime, DateTime)
        > {
  HistoryDosesFamily._()
    : super(
        retry: null,
        name: r'historyDosesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resolved doses between [from] and [to] (UTC instants).

  HistoryDosesProvider call(DateTime from, DateTime to) =>
      HistoryDosesProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'historyDosesProvider';
}

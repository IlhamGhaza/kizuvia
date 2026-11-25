import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/features/dose_log/data/dose_log_repository.dart';
import 'package:kizuvia/features/dose_log/domain/dose_log.dart';
import 'package:kizuvia/features/dose_log/domain/resolved_dose.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dose_providers.g.dart';

/// Current time, refreshed every minute so statuses move upcoming -> now -> missed.
@riverpod
Stream<DateTime> minuteTick(Ref ref) async* {
  final clock = ref.watch(clockProvider);
  yield clock.now();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => clock.now());
}

@riverpod
Stream<List<DoseLog>> logsInRange(Ref ref, DateTime from, DateTime to) =>
    ref.watch(doseLogRepositoryProvider).watchRange(from, to);

/// Doses of the device-local "today".
@riverpod
AsyncValue<List<ResolvedDose>> todayDoses(Ref ref) {
  final now =
      ref.watch(minuteTickProvider).value ?? ref.watch(clockProvider).now();
  final local = now.toLocal();
  final start = DateTime(local.year, local.month, local.day);
  final end = DateTime(
    local.year,
    local.month,
    local.day + 1,
  ).subtract(const Duration(seconds: 1));
  final contexts = ref.watch(scheduleContextsProvider);
  final logs = ref.watch(logsInRangeProvider(start.toUtc(), end.toUtc()));
  if (contexts.hasError) {
    return AsyncError(contexts.error!, contexts.stackTrace!);
  }
  if (logs.hasError) return AsyncError(logs.error!, logs.stackTrace!);
  if (!contexts.hasValue || !logs.hasValue) return const AsyncLoading();
  return AsyncData(
    resolveDoses(
      contexts: contexts.requireValue,
      logs: logs.requireValue,
      from: start.toUtc(),
      to: end.toUtc(),
      now: now,
    ),
  );
}

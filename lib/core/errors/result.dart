import 'package:kizuvia/core/errors/app_failure.dart';

/// `Result<T, AppFailure>` (docs/02-ARCHITECTURE.md §7).
sealed class Result<T, E extends AppFailure> {
  const Result();

  const factory Result.ok(T value) = Ok<T, E>;
  const factory Result.err(E failure) = Err<T, E>;

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  /// Value if ok, otherwise null.
  T? get valueOrNull => switch (this) {
    Ok<T, E>(:final value) => value,
    Err<T, E>() => null,
  };

  R when<R>({
    required R Function(T value) ok,
    required R Function(E failure) err,
  }) => switch (this) {
    Ok<T, E>(:final value) => ok(value),
    Err<T, E>(:final failure) => err(failure),
  };

  Result<R, E> map<R>(R Function(T value) f) => switch (this) {
    Ok<T, E>(:final value) => Result.ok(f(value)),
    Err<T, E>(:final failure) => Result.err(failure),
  };
}

final class Ok<T, E extends AppFailure> extends Result<T, E> {
  const Ok(this.value);

  final T value;
}

final class Err<T, E extends AppFailure> extends Result<T, E> {
  const Err(this.failure);

  final E failure;
}

/// Runs [body], converting any thrown error to `Err(onError(e))`.
Future<Result<T, AppFailure>> guard<T>(
  Future<T> Function() body, {
  AppFailure Function(Object error)? onError,
}) async {
  try {
    return Result.ok(await body());
  } on Object catch (e) {
    // Only the type is kept: the message may contain patient data.
    return Result.err(
      onError?.call(e) ?? UnknownFailure(e.runtimeType.toString()),
    );
  }
}

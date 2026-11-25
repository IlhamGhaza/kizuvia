import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/errors/app_failure.dart';
import 'package:kizuvia/core/errors/result.dart';

void main() {
  test('ok / err basics', () {
    const Result<int, AppFailure> ok = Result.ok(2);
    const Result<int, AppFailure> err = Result.err(NotFoundFailure());
    expect(ok.isOk, isTrue);
    expect(ok.map((v) => v * 2).valueOrNull, 4);
    expect(err.isErr, isTrue);
    expect(err.valueOrNull, isNull);
    expect(err.when(ok: (_) => 'ok', err: (f) => f.message), 'not found');
  });

  test('guard keeps only the error type, not its message', () async {
    final r = await guard<int>(() async => throw StateError('Budi Amlodipine'));
    final failure = (r as Err<int, AppFailure>).failure;
    expect(failure, isA<UnknownFailure>());
    expect(failure.message, 'StateError');
    expect(failure.message, isNot(contains('Budi')));
  });

  test('guard returns ok value', () async {
    final r = await guard<int>(() async => 7);
    expect(r.valueOrNull, 7);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/utils/app_logger.dart';

void main() {
  test('redacts sensitive keys, recursively', () {
    final lines = <String>[];
    AppLogger(sink: lines.add, isRelease: false).info(
      'saved',
      fields: {
        'id': 'abc',
        'name': 'Amlodipine',
        'nested': {'Notes': 'secret', 'qty': 1},
        'list': [
          {'conditions': 'stroke'},
        ],
      },
    );
    final out = lines.single;
    expect(out, contains('abc'));
    expect(out, isNot(contains('Amlodipine')));
    expect(out, isNot(contains('secret')));
    expect(out, isNot(contains('stroke')));
    expect(out, contains(AppLogger.redacted));
  });

  test('release build prints only warning and above', () {
    final lines = <String>[];
    AppLogger(sink: lines.add, isRelease: true)
      ..debug('d')
      ..info('i')
      ..warning('w');
    expect(lines, ['[warning] w']);
  });

  test('error logs the type, never the message', () {
    final lines = <String>[];
    AppLogger(
      sink: lines.add,
      isRelease: true,
    ).error('failed', error: StateError('Budi minum Amlodipine'));
    expect(lines.single, contains('StateError'));
    expect(lines.single, isNot(contains('Budi')));
  });
}

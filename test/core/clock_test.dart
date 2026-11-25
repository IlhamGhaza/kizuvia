import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/clock/clock.dart';

void main() {
  test('FixedClock returns the set time', () {
    final c = FixedClock(DateTime(2026, 1, 1, 7));
    expect(c.now(), DateTime(2026, 1, 1, 7));
    c.current = DateTime(2026, 1, 2);
    expect(c.now(), DateTime(2026, 1, 2));
  });

  test('clockProvider can be overridden', () {
    final fixed = FixedClock(DateTime(2026, 5, 5));
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(fixed)],
    );
    addTearDown(container.dispose);
    expect(container.read(clockProvider).now(), DateTime(2026, 5, 5));
  });
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// All time access goes through this (docs/02-ARCHITECTURE.md §2) so tests can fake it.
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Test helper; also usable for previews.
class FixedClock implements Clock {
  FixedClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();

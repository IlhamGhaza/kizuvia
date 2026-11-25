import 'package:freezed_annotation/freezed_annotation.dart';

part 'med_schedule.freezed.dart';

@freezed
abstract class MedSchedule with _$MedSchedule {
  const factory MedSchedule({
    required String id,
    required String medicationId,

    /// Local times, `HH:mm`.
    required List<String> times,
    @Default(<int>[1, 2, 3, 4, 5, 6, 7]) List<int> daysOfWeek,
    @Default('Asia/Jakarta') String timezone,
    @Default(30) int graceMinutes,
  }) = _MedSchedule;
}

/// Frequency templates (US-04). Times are defaults the user may edit.
enum FrequencyTemplate {
  once(['08:00']),
  twice(['08:00', '20:00']),
  thrice(['07:00', '13:00', '19:00']),
  fourTimes(['06:00', '12:00', '18:00', '22:00']);

  const FrequencyTemplate(this.times);

  final List<String> times;
}

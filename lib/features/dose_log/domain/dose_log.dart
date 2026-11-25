import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kizuvia/core/domain/enums.dart';

part 'dose_log.freezed.dart';

@freezed
abstract class DoseLog with _$DoseLog {
  const factory DoseLog({
    required String id,
    required String scheduleId,
    required String patientId,

    /// UTC instant of the planned dose.
    required DateTime scheduledAt,
    required DoseStatus status,
    required DateTime createdAt,
    DateTime? confirmedAt,
    String? note,
    @Default(DoseSource.device) DoseSource source,
  }) = _DoseLog;
}

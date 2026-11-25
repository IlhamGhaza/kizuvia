import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kizuvia/core/domain/enums.dart';

part 'medication.freezed.dart';

/// All data comes from user input or a confirmed scan draft (safety rules 1, 3).
@freezed
abstract class Medication with _$Medication {
  const factory Medication({
    required String id,
    required String patientId,
    required String name,
    required DateTime startDate,
    @Default(1.0) double doseQty,
    @Default(3) int refillThresholdDays,
    @Default(false) bool isPrn,
    @Default(true) bool isActive,
    @Default('manual') String source,
    String? strength,
    MedForm? form,
    String? instructions,
    MealRelation? mealRelation,
    String? prescribedBy,
    double? stockQty,
    String? photoPath,

    /// Key in the private photo bucket; set by sync, not by the form.
    String? photoRemotePath,

    /// Inclusive instant: no occurrence is created after it.
    DateTime? endDate,
  }) = _Medication;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kizuvia/core/domain/enums.dart';

part 'parsed_label.freezed.dart';

/// OCR result: always a DRAFT the user must review (safety rule 3). Fields
/// below confidence 0.6 are left null rather than guessed (docs/06 §5).
@freezed
abstract class ParsedLabel with _$ParsedLabel {
  const factory ParsedLabel({
    required String rawText,

    /// Per field, 0..1. Includes fields that were dropped for low confidence.
    required Map<String, double> confidence,
    String? name,
    String? strength,
    int? timesPerDay,
    double? doseQty,
    MedForm? form,
    MealRelation? mealRelation,
    bool? isPrn,
  }) = _ParsedLabel;
}

extension ParsedLabelX on ParsedLabel {
  /// Anything useful found? (If not, ask for a better photo.)
  bool get hasAnyField =>
      name != null ||
      strength != null ||
      timesPerDay != null ||
      doseQty != null ||
      form != null ||
      mealRelation != null ||
      isPrn != null;
}

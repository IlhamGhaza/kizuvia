import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient.freezed.dart';

@freezed
abstract class Patient with _$Patient {
  const factory Patient({
    required String id,
    required String name,
    String? familyId,
    int? birthYear,
    @Default(<String>[]) List<String> conditions,
    String? notes,
    String? photoPath,
  }) = _Patient;
}

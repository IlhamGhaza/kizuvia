import 'package:freezed_annotation/freezed_annotation.dart';

part 'family.freezed.dart';

@freezed
abstract class FamilySummary with _$FamilySummary {
  const factory FamilySummary({
    required String id,
    required String name,
    required String role,
    @Default(1) int memberCount,
  }) = _FamilySummary;
}

@freezed
abstract class FamilyMember with _$FamilyMember {
  const factory FamilyMember({
    required String userId,
    required String role,
    String? displayName,
    @Default(true) bool notifyMissed,
  }) = _FamilyMember;
}

abstract final class FamilyRole {
  static const owner = 'owner';
  static const caregiver = 'caregiver';
  static const patient = 'patient';
}

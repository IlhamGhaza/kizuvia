import 'package:kizuvia/core/errors/app_failure.dart';
import 'package:kizuvia/features/family/data/family_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';

/// Localised, blame-free message for a family/RPC failure (brand §6.2).
String familyFailureText(AppLocalizations l10n, AppFailure f) {
  if (f is NetworkFailure) return l10n.errNetwork;
  if (f is ValidationFailure) {
    return switch (f.message) {
      FamilyFailure.inviteInvalid => l10n.errInviteInvalid,
      FamilyFailure.alreadyMember => l10n.errAlreadyMember,
      FamilyFailure.lastOwner => l10n.errLastOwner,
      FamilyFailure.forbidden => l10n.errForbidden,
      FamilyFailure.tooManyInvites => l10n.errTooManyInvites,
      _ => l10n.errorGeneric,
    };
  }
  return l10n.errorGeneric;
}

String roleLabel(AppLocalizations l10n, String role) => switch (role) {
  'owner' => l10n.roleOwner,
  'patient' => l10n.rolePatient,
  _ => l10n.roleCaregiver,
};

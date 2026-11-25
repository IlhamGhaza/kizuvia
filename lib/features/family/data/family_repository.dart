import 'package:kizuvia/core/errors/app_failure.dart';
import 'package:kizuvia/core/errors/result.dart';
import 'package:kizuvia/core/supabase/supabase_config.dart';
import 'package:kizuvia/features/family/domain/family.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

part 'family_repository.g.dart';

/// Failure keys the UI maps to localised copy.
abstract final class FamilyFailure {
  static const inviteInvalid = 'invite_invalid';
  static const alreadyMember = 'already_member';
  static const lastOwner = 'last_owner';
  static const forbidden = 'forbidden';
  static const tooManyInvites = 'too_many_invites';
}

/// Server side of families / members / invites (RPCs from docs/03 §3).
abstract interface class FamilyRepository {
  Future<Result<List<FamilySummary>, AppFailure>> myFamilies();
  Future<Result<String, AppFailure>> createFamily(
    String name, {
    String? displayName,
  });
  Future<Result<String, AppFailure>> acceptInvite(
    String code, {
    String? displayName,
  });
  Future<Result<String, AppFailure>> createInvite(
    String familyId, {
    String role = FamilyRole.caregiver,
  });
  Future<Result<List<FamilyMember>, AppFailure>> members(String familyId);
  Future<Result<void, AppFailure>> setRole(
    String familyId,
    String userId,
    String role,
  );
  Future<Result<void, AppFailure>> removeMember(String familyId, String userId);
  Future<Result<void, AppFailure>> setNotifyMissed(
    String familyId, {
    required bool value,
  });
}

class OfflineFamilyRepository implements FamilyRepository {
  const OfflineFamilyRepository();

  Result<T, AppFailure> _off<T>() =>
      const Result.err(NetworkFailure('supabase not configured'));

  @override
  Future<Result<List<FamilySummary>, AppFailure>> myFamilies() async => _off();
  @override
  Future<Result<String, AppFailure>> createFamily(
    String name, {
    String? displayName,
  }) async => _off();
  @override
  Future<Result<String, AppFailure>> acceptInvite(
    String code, {
    String? displayName,
  }) async => _off();
  @override
  Future<Result<String, AppFailure>> createInvite(
    String familyId, {
    String role = FamilyRole.caregiver,
  }) async => _off();
  @override
  Future<Result<List<FamilyMember>, AppFailure>> members(
    String familyId,
  ) async => _off();
  @override
  Future<Result<void, AppFailure>> setRole(
    String familyId,
    String userId,
    String role,
  ) async => _off();
  @override
  Future<Result<void, AppFailure>> removeMember(
    String familyId,
    String userId,
  ) async => _off();
  @override
  Future<Result<void, AppFailure>> setNotifyMissed(
    String familyId, {
    required bool value,
  }) async => _off();
}

class SupabaseFamilyRepository implements FamilyRepository {
  SupabaseFamilyRepository(this._client);

  final sb.SupabaseClient _client;

  /// Maps Postgres error codes raised by the RPCs to stable keys.
  static AppFailure _failure(Object e) {
    if (e is sb.PostgrestException) {
      return switch (e.code) {
        'P0002' => const ValidationFailure(FamilyFailure.inviteInvalid),
        '23505' => const ValidationFailure(FamilyFailure.alreadyMember),
        '23514' => const ValidationFailure(FamilyFailure.lastOwner),
        '42501' => const ValidationFailure(FamilyFailure.forbidden),
        '54000' => const ValidationFailure(FamilyFailure.tooManyInvites),
        _ => const UnknownFailure('postgrest'),
      };
    }
    return const NetworkFailure();
  }

  @override
  Future<Result<List<FamilySummary>, AppFailure>> myFamilies() =>
      guard(() async {
        final rows = await _client.rpc<List<dynamic>>('my_families');
        return [
          for (final r in rows.cast<Map<String, dynamic>>())
            FamilySummary(
              id: r['family_id'] as String,
              name: r['name'] as String,
              role: r['role'] as String,
              memberCount: (r['member_count'] as num).toInt(),
            ),
        ];
      }, onError: _failure);

  @override
  Future<Result<String, AppFailure>> createFamily(
    String name, {
    String? displayName,
  }) => guard(
    () => _client.rpc<String>(
      'create_family',
      params: {'p_name': name, 'p_display_name': displayName},
    ),
    onError: _failure,
  );

  @override
  Future<Result<String, AppFailure>> acceptInvite(
    String code, {
    String? displayName,
  }) => guard(
    () => _client.rpc<String>(
      'accept_invite',
      params: {'p_code': code, 'p_display_name': displayName},
    ),
    onError: _failure,
  );

  @override
  Future<Result<String, AppFailure>> createInvite(
    String familyId, {
    String role = FamilyRole.caregiver,
  }) => guard(
    () => _client.rpc<String>(
      'create_invite',
      params: {'p_family_id': familyId, 'p_role': role},
    ),
    onError: _failure,
  );

  @override
  Future<Result<List<FamilyMember>, AppFailure>> members(String familyId) =>
      guard(() async {
        final rows = await _client
            .from('family_members')
            .select('user_id, role, display_name, notify_missed')
            .eq('family_id', familyId)
            .order('joined_at');
        return [
          for (final r in rows)
            FamilyMember(
              userId: r['user_id'] as String,
              role: r['role'] as String,
              displayName: r['display_name'] as String?,
              notifyMissed: r['notify_missed'] as bool,
            ),
        ];
      }, onError: _failure);

  @override
  Future<Result<void, AppFailure>> setRole(
    String familyId,
    String userId,
    String role,
  ) => guard(
    () => _client.rpc<void>(
      'set_member_role',
      params: {'p_family_id': familyId, 'p_user_id': userId, 'p_role': role},
    ),
    onError: _failure,
  );

  @override
  Future<Result<void, AppFailure>> removeMember(
    String familyId,
    String userId,
  ) => guard(
    () => _client.rpc<void>(
      'remove_member',
      params: {'p_family_id': familyId, 'p_user_id': userId},
    ),
    onError: _failure,
  );

  @override
  Future<Result<void, AppFailure>> setNotifyMissed(
    String familyId, {
    required bool value,
  }) => guard(() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('not signed in');
    await _client
        .from('family_members')
        .update({'notify_missed': value})
        .eq('family_id', familyId)
        .eq('user_id', uid);
  }, onError: _failure);
}

@Riverpod(keepAlive: true)
FamilyRepository familyRepository(Ref ref) => SupabaseConfig.isReady
    ? SupabaseFamilyRepository(sb.Supabase.instance.client)
    : const OfflineFamilyRepository();

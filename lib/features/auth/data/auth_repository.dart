import 'package:kizuvia/core/errors/app_failure.dart';
import 'package:kizuvia/core/errors/result.dart';
import 'package:kizuvia/core/supabase/supabase_config.dart';
import 'package:kizuvia/features/auth/domain/app_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

part 'auth_repository.g.dart';

/// Deep link the email's sign-in link opens (see AndroidManifest).
const authRedirectUrl = 'kizuvia://login-callback';

/// Email OTP login (T2.2). Everything works without an account; this is only
/// needed for family sharing and sync.
abstract interface class AuthRepository {
  AppUser? get currentUser;

  /// Emits the current user now and on every sign-in / sign-out.
  Stream<AppUser?> watchUser();

  Future<Result<void, AppFailure>> sendOtp(String email);
  Future<Result<AppUser, AppFailure>> verifyOtp(String email, String code);
  Future<void> signOut();
}

/// Used when Supabase is not configured (no env file) and in tests.
class OfflineAuthRepository implements AuthRepository {
  const OfflineAuthRepository();

  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> watchUser() => Stream.value(null);

  @override
  Future<Result<void, AppFailure>> sendOtp(String email) async =>
      const Result.err(NetworkFailure('supabase not configured'));

  @override
  Future<Result<AppUser, AppFailure>> verifyOtp(
    String email,
    String code,
  ) async => const Result.err(NetworkFailure('supabase not configured'));

  @override
  Future<void> signOut() async {}
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final sb.SupabaseClient _client;

  static AppUser? _map(sb.User? u) =>
      u == null ? null : AppUser(id: u.id, email: u.email);

  @override
  AppUser? get currentUser => _map(_client.auth.currentUser);

  @override
  Stream<AppUser?> watchUser() async* {
    yield currentUser;
    yield* _client.auth.onAuthStateChange.map((e) => _map(e.session?.user));
  }

  @override
  Future<Result<void, AppFailure>> sendOtp(String email) => guard(
    () => _client.auth.signInWithOtp(
      email: email.trim(),
      shouldCreateUser: true,
      // The email link returns to the app (must be listed under Supabase >
      // Authentication > URL Configuration > Redirect URLs).
      emailRedirectTo: authRedirectUrl,
    ),
    onError: _failure,
  );

  @override
  Future<Result<AppUser, AppFailure>> verifyOtp(
    String email,
    String code,
  ) async {
    final r = await guard(
      () => _client.auth.verifyOTP(
        email: email.trim(),
        token: code.trim(),
        type: sb.OtpType.email,
      ),
      onError: _failure,
    );
    return r.when(
      ok: (res) {
        final u = _map(res.user);
        return u == null
            ? const Result.err(AuthFailure('no user'))
            : Result.ok(u);
      },
      err: Result.err,
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  /// Never include the email or server message in the failure.
  static AppFailure _failure(Object e) => switch (e) {
    sb.AuthException(:final statusCode) when statusCode == '429' =>
      const AuthFailure('rate limited'),
    sb.AuthException() => const AuthFailure('auth rejected'),
    _ => const NetworkFailure(),
  };
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => SupabaseConfig.isReady
    ? SupabaseAuthRepository(sb.Supabase.instance.client)
    : const OfflineAuthRepository();

@Riverpod(keepAlive: true)
Stream<AppUser?> authUser(Ref ref) =>
    ref.watch(authRepositoryProvider).watchUser();

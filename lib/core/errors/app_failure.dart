/// Failure returned by repositories instead of throwing to the UI.
/// Messages must never contain patient/medication data (docs/08 §3).
sealed class AppFailure {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

final class DatabaseFailure extends AppFailure {
  const DatabaseFailure([super.message = 'database error']);
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'network error']);
}

final class AuthFailure extends AppFailure {
  const AuthFailure([super.message = 'auth error']);
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'not found']);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'unknown error']);
}

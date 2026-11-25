/// Build-time config from `--dart-define-from-file=env.<flavor>.json`
/// (docs/02 §8). Only the public anon/publishable key belongs here; the
/// service-role key must never be in the app (safety rule 6).
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Set by `bootstrap()` after `Supabase.initialize` succeeded. Everything
  /// cloud-related stays off (local-only mode) until then.
  static bool initialized = false;

  /// Exception type (never data) when init failed; shown to help diagnosis.
  static String? initError;

  static bool get isReady => isConfigured && initialized;
}

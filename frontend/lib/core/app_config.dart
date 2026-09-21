/// Application configuration for RadarScholar.
///
/// Centralizes environment-dependent settings like API base URL
/// and Supabase credentials. Values are loaded from compile-time
/// environment variables with sensible defaults for development.
///
/// Security (agents.md §12):
/// - Only the ANON key (public, rate-limited) is stored here.
/// - The SERVICE_ROLE key is NEVER used client-side.
class AppConfig {
  AppConfig._();

  /// Base URL for the FastAPI backend.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Supabase project URL.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase anonymous (public) key.
  /// This is safe to include client-side — it only allows
  /// rate-limited, authenticated operations.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Application name.
  static const String appName = 'RadarScholar';

  /// Current version.
  static const String version = '0.1.0';
}

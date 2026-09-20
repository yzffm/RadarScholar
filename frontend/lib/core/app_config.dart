/// Application configuration for RadarScholar.
///
/// Centralizes environment-dependent settings like API base URL.
/// In M0, defaults are used. In future milestones, these will be
/// loaded from environment or build configuration.
class AppConfig {
  AppConfig._();

  /// Base URL for the FastAPI backend.
  ///
  /// Default points to local development server.
  /// Override via environment configuration in future milestones.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Application name.
  static const String appName = 'RadarScholar';

  /// Current version.
  static const String version = '0.1.0';
}

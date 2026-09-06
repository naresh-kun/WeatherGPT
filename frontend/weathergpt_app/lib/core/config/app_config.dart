/// WeatherGPT — App Configuration
/// Environment-based configuration for the Flutter app.
/// API base URL and other settings are loaded here.
library;

class AppConfig {
  AppConfig._(); // prevent instantiation

  /// Base URL of the WeatherGPT FastAPI backend.
  /// Override per environment (dev / staging / prod).
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';

  /// Default timeout for API requests.
  static const Duration apiTimeout = Duration(seconds: 15);
}

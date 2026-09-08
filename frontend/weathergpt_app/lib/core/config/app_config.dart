/// WeatherGPT — App Configuration
/// Environment-based configuration for the Flutter app.
/// API base URL and other settings are loaded here.
library;

class AppConfig {
  AppConfig._(); // prevent instantiation

  /// Base URL of the WeatherGPT FastAPI backend.
  ///
  /// For Android emulator:  'http://10.0.2.2:8000/api/v1'
  /// For iOS simulator/web: 'http://localhost:8000/api/v1'
  /// For physical devices:  'http://<YOUR_PC_IP>:8000/api/v1'
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';

  /// Default timeout for API requests.
  static const Duration apiTimeout = Duration(seconds: 15);
}

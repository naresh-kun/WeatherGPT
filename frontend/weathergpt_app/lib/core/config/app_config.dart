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
  /// For physical devices:  `http://<YOUR_PC_IP>:8000/api/v1`
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api/v1';

  /// Default timeout for general API requests.
  static const Duration apiTimeout = Duration(seconds: 15);

  /// Dedicated timeout for AI chat requests (accommodates LLM generation latency).
  static const Duration chatApiTimeout = Duration(seconds: 60);
}

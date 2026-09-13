/// WeatherGPT — App Configuration
/// Environment-based configuration for the Flutter app.
/// API base URL and other settings are loaded here.
library;

import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._(); // prevent instantiation

  /// Local development backend base URL.
  static const String _defaultDevBaseUrl = 'http://127.0.0.1:8000/api/v1';

  /// Production Railway HTTPS backend base URL.
  static const String _defaultProdBaseUrl =
      'https://weathergpt-production-84b3.up.railway.app/api/v1';

  /// Base URL of the WeatherGPT FastAPI backend.
  ///
  /// Defaults to local development in debug mode and Railway HTTPS in release mode.
  /// Can be customized at run/build time via:
  ///   `flutter run --dart-define=API_BASE_URL=https://your-service.up.railway.app/api/v1`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kReleaseMode ? _defaultProdBaseUrl : _defaultDevBaseUrl,
  );

  /// Default timeout for general API requests.
  static const Duration apiTimeout = Duration(seconds: 15);

  /// Dedicated timeout for AI chat requests (accommodates LLM generation latency).
  static const Duration chatApiTimeout = Duration(seconds: 60);
}

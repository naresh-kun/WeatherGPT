/// WeatherGPT — App Constants
/// Shared string constants, asset paths, and configuration values.
library;

class AppConstants {
  AppConstants._();

  // ---- API endpoints (relative paths) ----------------------
  static const String healthEndpoint        = '/health';
  static const String weatherCurrentEndpoint = '/weather/current';
  static const String weatherForecastEndpoint = '/weather/forecast';
  static const String chatEndpoint          = '/chat';
  static const String alertsEndpoint        = '/alerts';
  static const String advisoryEndpoint      = '/advisory';
  static const String climateTrendsEndpoint = '/climate/trends';

  // ---- Asset paths -----------------------------------------
  static const String imagesPath     = 'assets/images/';
  static const String iconsPath      = 'assets/icons/';
  static const String animationsPath = 'assets/animations/';
}

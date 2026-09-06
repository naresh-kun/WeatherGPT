/// WeatherGPT — App Errors
/// Custom exception types for the WeatherGPT app.
/// Not yet implemented — placeholder only.
library;

/// Thrown when an API request fails.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thrown when a network connection cannot be established.
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

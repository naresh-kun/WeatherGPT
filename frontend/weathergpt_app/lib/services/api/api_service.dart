/// WeatherGPT — API Service
/// HTTP client for communicating with the WeatherGPT FastAPI backend.
library;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weathergpt_app/core/config/app_config.dart';
import 'package:weathergpt_app/models/models.dart';

// ---------------------------------------------------------------------------
// API Exceptions
// ---------------------------------------------------------------------------

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException() : super('Request timed out. Please try again.');
}

class ApiConnectionException extends ApiException {
  const ApiConnectionException()
      : super('Unable to reach server. Check your connection.');
}

class LocationNotFoundException extends ApiException {
  const LocationNotFoundException() : super('Location not found.');
}

class ServiceUnavailableException extends ApiException {
  const ServiceUnavailableException()
      : super('Weather service is temporarily unavailable.');
}

// ---------------------------------------------------------------------------
// ApiService
// ---------------------------------------------------------------------------

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _client = client ?? http.Client();

  // --- generic GET ---

  Future<dynamic> _get(
    String endpoint, [
    Map<String, String>? queryParams,
  ]) async {
    final uri =
        Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri).timeout(AppConfig.apiTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw const LocationNotFoundException();
      } else if (response.statusCode >= 500) {
        throw const ServiceUnavailableException();
      } else {
        throw ApiException(
            'Unexpected error (${response.statusCode}). Please try again.');
      }
    } on TimeoutException {
      throw const ApiTimeoutException();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiConnectionException();
    }
  }

  // --- generic POST ---

  Future<dynamic> _post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else if (response.statusCode == 400) {
        final detail = _extractDetail(response.body);
        throw ApiException(detail ?? 'Invalid request.');
      } else if (response.statusCode >= 500) {
        throw const ServiceUnavailableException();
      } else {
        throw ApiException(
            'Unexpected error (${response.statusCode}). Please try again.');
      }
    } on TimeoutException {
      throw const ApiTimeoutException();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiConnectionException();
    }
  }

  String? _extractDetail(String responseBody) {
    try {
      final decoded = json.decode(responseBody) as Map<String, dynamic>;
      return decoded['detail'] as String?;
    } catch (_) {
      return null;
    }
  }

  // --- Weather endpoints ---

  Future<WeatherCurrent> getCurrentWeather(double lat, double lon) async {
    final data = await _get('/weather/current', {
      'lat': lat.toString(),
      'lon': lon.toString(),
    });
    return WeatherCurrent.fromJson(data as Map<String, dynamic>);
  }

  Future<WeatherForecast> getForecast(double lat, double lon,
      {int days = 7}) async {
    final data = await _get('/weather/forecast', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'days': days.toString(),
    });
    return WeatherForecast.fromJson(data as Map<String, dynamic>);
  }

  Future<List<HourlyForecast>> getHourly(double lat, double lon,
      {int limit = 24}) async {
    final data = await _get('/weather/hourly', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'limit': limit.toString(),
    });
    return (data as List)
        .map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LocationSearchResult>> searchLocations(String query) async {
    final data = await _get('/weather/search', {'q': query});
    return (data as List)
        .map((e) => LocationSearchResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WeatherAlertsResponse> getAlerts(double lat, double lon) async {
    final data = await _get('/alerts', {
      'lat': lat.toString(),
      'lon': lon.toString(),
    });
    return WeatherAlertsResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<WeatherAdvisoriesResponse> getAdvisories(
    double lat,
    double lon, {
    String category = 'general',
  }) async {
    final data = await _get('/advisory', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'category': category,
    });
    return WeatherAdvisoriesResponse.fromJson(data as Map<String, dynamic>);
  }

  // --- Chat endpoint (Phase 5) ---

  /// Send a natural-language message to the WeatherGPT AI chat backend.
  ///
  /// The [lat]/[lon] are the user's currently selected location and are
  /// included in every request so the backend can ground the answer in
  /// real weather data. The Gemini API key is **never** sent from Flutter.
  Future<ChatApiResponse> sendChatMessage({
    required String message,
    required double lat,
    required double lon,
    String? conversationId,
  }) async {
    final body = ChatApiRequest(
      message: message,
      lat: lat,
      lon: lon,
      conversationId: conversationId,
    ).toJson();

    final data = await _post('/chat', body);
    return ChatApiResponse.fromJson(data as Map<String, dynamic>);
  }
}

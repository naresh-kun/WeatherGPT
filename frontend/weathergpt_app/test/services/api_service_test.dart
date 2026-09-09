/// WeatherGPT — API Service Tests
/// Tests parsing of backend JSON responses using a mocked HTTP client.
/// No live FastAPI server, WeatherAPI key, or real GPS required.

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weathergpt_app/services/api/api_service.dart';

// ---------------------------------------------------------------------------
// Helpers — sample JSON responses that match the API contract
// ---------------------------------------------------------------------------

const _currentWeatherJson = {
  'location': {
    'lat': 9.93,
    'lon': 78.12,
    'city': 'Madurai',
    'country': 'IN',
    'timezone': 'Asia/Kolkata',
  },
  'temperature': 32.4,
  'feels_like': 36.1,
  'humidity': 60,
  'wind_speed': 4.2,
  'wind_direction': 220,
  'description': 'Partly cloudy',
  'icon': '02d',
  'uv_index': 7.2,
  'visibility': 10.0,
  'timestamp': 1756137600,
};

const _forecastJson = {
  'location': {
    'lat': 9.93,
    'lon': 78.12,
    'city': 'Madurai',
    'country': 'IN',
    'timezone': 'Asia/Kolkata',
  },
  'units': 'metric',
  'hourly': [
    {
      'timestamp': 1756137600,
      'temperature': 32.4,
      'feels_like': 36.1,
      'humidity': 60,
      'wind_speed': 4.2,
      'description': 'Partly cloudy',
      'icon': '02d',
      'precipitation_probability': 0.1,
    },
  ],
  'daily': [
    {
      'date': '2026-09-07',
      'temp_min': 26.0,
      'temp_max': 35.0,
      'humidity': 65,
      'wind_speed': 5.0,
      'description': 'Mostly sunny',
      'icon': '01d',
      'sunrise': 1756100400,
      'sunset': 1756145000,
      'precipitation_probability': 0.05,
    },
  ],
};

const _searchJson = [
  {
    'name': 'Madurai',
    'region': 'Tamil Nadu',
    'country': 'India',
    'lat': 9.93,
    'lon': 78.12,
    'url': 'madurai-tamil-nadu-india',
  },
];

const _alertsJson = {
  'alerts': [
    {
      'alert_id': 'alert-001',
      'alert_type': 'thunderstorm',
      'severity': 'moderate',
      'title': 'Thunderstorm Warning',
      'description': 'Heavy thunderstorms expected.',
      'area': 'Madurai District',
      'start_time': 1756137600,
      'end_time': 1756159200,
      'source': 'India Meteorological Department',
    },
  ],
  'total': 1,
};

const _emptyAlertsJson = {'alerts': [], 'total': 0};

// ---------------------------------------------------------------------------
// Factories for mock HTTP clients
// ---------------------------------------------------------------------------

MockClient _mockClient(dynamic body, {int status = 200}) {
  return MockClient((request) async {
    return http.Response(json.encode(body), status,
        headers: {'content-type': 'application/json'});
  });
}

MockClient _errorClient(int status) {
  return MockClient((_) async {
    return http.Response(
        json.encode({'detail': 'error'}), status,
        headers: {'content-type': 'application/json'});
  });
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const baseUrl = 'http://test.local/api/v1';

  group('ApiService.getCurrentWeather', () {
    test('parses a valid current weather response', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _mockClient(_currentWeatherJson),
      );

      final weather = await service.getCurrentWeather(9.93, 78.12);

      expect(weather.temperature, 32.4);
      expect(weather.feelsLike, 36.1);
      expect(weather.humidity, 60);
      expect(weather.windSpeed, 4.2);
      expect(weather.windDirection, 220);
      expect(weather.description, 'Partly cloudy');
      expect(weather.icon, '02d');
      expect(weather.uvIndex, 7.2);
      expect(weather.visibility, 10.0);
      expect(weather.timestamp, 1756137600);
      expect(weather.location.city, 'Madurai');
      expect(weather.location.lat, 9.93);
    });

    test('throws LocationNotFoundException on 404', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _errorClient(404),
      );

      expect(
        () => service.getCurrentWeather(0, 0),
        throwsA(isA<LocationNotFoundException>()),
      );
    });

    test('throws ServiceUnavailableException on 503', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _errorClient(503),
      );

      expect(
        () => service.getCurrentWeather(0, 0),
        throwsA(isA<ServiceUnavailableException>()),
      );
    });

    test('throws ApiConnectionException on network failure', () async {
      final client = MockClient((_) async => throw Exception('network error'));
      final service = ApiService(baseUrl: baseUrl, client: client);

      expect(
        () => service.getCurrentWeather(9.93, 78.12),
        throwsA(isA<ApiConnectionException>()),
      );
    });
  });

  group('ApiService.getForecast', () {
    test('parses hourly and daily forecast correctly', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _mockClient(_forecastJson),
      );

      final forecast = await service.getForecast(9.93, 78.12);

      expect(forecast.units, 'metric');
      expect(forecast.location.city, 'Madurai');
      expect(forecast.hourly.length, 1);
      expect(forecast.hourly.first.temperature, 32.4);
      expect(forecast.hourly.first.precipitationProbability, 0.1);
      expect(forecast.daily.length, 1);
      expect(forecast.daily.first.tempMin, 26.0);
      expect(forecast.daily.first.tempMax, 35.0);
      expect(forecast.daily.first.date, '2026-09-07');
    });

    test('hourly displayTime is derived from timestamp', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _mockClient(_forecastJson),
      );

      final forecast = await service.getForecast(9.93, 78.12);

      // timestamp 1756137600 → check it is a non-empty string
      expect(forecast.hourly.first.displayTime, isNotNull);
      expect(forecast.hourly.first.displayTime!.isNotEmpty, true);
    });

    test('daily displayDay is derived from date string', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _mockClient(_forecastJson),
      );

      final forecast = await service.getForecast(9.93, 78.12);

      // 2026-09-07 is a Monday
      expect(forecast.daily.first.displayDay, 'Mon');
    });
  });

  group('ApiService.searchLocations', () {
    test('parses location search results', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _mockClient(_searchJson),
      );

      final results = await service.searchLocations('Madurai');

      expect(results.length, 1);
      expect(results.first.name, 'Madurai');
      expect(results.first.region, 'Tamil Nadu');
      expect(results.first.country, 'India');
      expect(results.first.lat, 9.93);
      expect(results.first.lon, 78.12);
    });

    test('returns empty list for empty JSON array', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _mockClient(<dynamic>[]),
      );

      final results = await service.searchLocations('xyz123');
      expect(results, isEmpty);
    });
  });

  group('ApiService.getAlerts', () {
    test('parses alerts response with one alert', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _mockClient(_alertsJson),
      );

      final response = await service.getAlerts(9.93, 78.12);

      expect(response.total, 1);
      expect(response.alerts.length, 1);
      expect(response.alerts.first.title, 'Thunderstorm Warning');
      expect(response.alerts.first.alertType, 'thunderstorm');
    });

    test('parses empty alerts response gracefully', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _mockClient(_emptyAlertsJson),
      );

      final response = await service.getAlerts(9.93, 78.12);

      expect(response.total, 0);
      expect(response.alerts, isEmpty);
    });

    test('does not throw on empty alerts — empty is not an error', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _mockClient(_emptyAlertsJson),
      );

      // Should complete without throwing
      final response = await service.getAlerts(9.93, 78.12);
      expect(response, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Phase 5: ApiService.sendChatMessage
  // ---------------------------------------------------------------------------

  const chatResponseJson = {
    'message': 'It is 31°C and partly cloudy.',
    'conversation_id': 'conv-123',
    'language': 'en',
    'suggestions': <String>[],
  };

  group('ApiService.sendChatMessage', () {
    test('parses a valid chat response', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _mockClient(chatResponseJson),
      );

      final response = await service.sendChatMessage(
        message: 'What is the weather?',
        lat: 9.93,
        lon: 78.12,
      );

      expect(response.message, 'It is 31°C and partly cloudy.');
      expect(response.conversationId, 'conv-123');
      expect(response.language, 'en');
      expect(response.suggestions, isEmpty);
    });

    test('sends location in the request body', () async {
      Map<String, dynamic>? capturedBody;

      final client = MockClient((request) async {
        capturedBody = json.decode(request.body) as Map<String, dynamic>;
        return http.Response(
          json.encode(chatResponseJson),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ApiService(baseUrl: baseUrl, client: client);
      await service.sendChatMessage(
          message: 'Will it rain?', lat: 9.93, lon: 78.12);

      expect(capturedBody, isNotNull);
      expect(capturedBody!['location']['lat'], 9.93);
      expect(capturedBody!['location']['lon'], 78.12);
    });

    test('request body does NOT contain any API key', () async {
      Map<String, dynamic>? capturedBody;

      final client = MockClient((request) async {
        capturedBody = json.decode(request.body) as Map<String, dynamic>;
        return http.Response(
          json.encode(chatResponseJson),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ApiService(baseUrl: baseUrl, client: client);
      await service.sendChatMessage(
          message: 'Test', lat: 9.93, lon: 78.12);

      // Gemini key must NEVER appear in the Flutter → backend request
      final bodyStr = json.encode(capturedBody);
      expect(bodyStr.contains('gemini'), isFalse);
      expect(bodyStr.contains('api_key'), isFalse);
      expect(bodyStr.contains('GEMINI'), isFalse);
    });

    test('throws ServiceUnavailableException on 503', () async {
      final service = ApiService(
        baseUrl: baseUrl,
        client: _errorClient(503),
      );

      expect(
        () => service.sendChatMessage(message: 'Test', lat: 9.93, lon: 78.12),
        throwsA(isA<ServiceUnavailableException>()),
      );
    });

    test('throws ApiConnectionException on network failure', () async {
      final client = MockClient((_) async => throw Exception('network error'));
      final service = ApiService(baseUrl: baseUrl, client: client);

      expect(
        () => service.sendChatMessage(message: 'Test', lat: 9.93, lon: 78.12),
        throwsA(isA<ApiConnectionException>()),
      );
    });
  });
}

/// WeatherGPT — Weather Provider Tests
/// Tests loading/success/error state transitions in WeatherProvider.
library;

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weathergpt_app/models/models.dart';
import 'package:weathergpt_app/providers/weather_provider.dart';
import 'package:weathergpt_app/services/api/api_service.dart';

// ---------------------------------------------------------------------------
// Sample JSON that matches the API contract
// ---------------------------------------------------------------------------

const _currentWeatherJson = {
  'location': {
    'lat': 9.93,
    'lon': 78.12,
    'city': 'Madurai',
    'country': 'IN',
    'timezone': 'Asia/Kolkata',
  },
  'temperature': 29.0,
  'feels_like': 31.0,
  'humidity': 72,
  'wind_speed': 14.0,
  'wind_direction': 220,
  'description': 'Partly cloudy',
  'icon': '02d',
  'uv_index': 6.0,
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
      'temperature': 29.0,
      'feels_like': 31.0,
      'humidity': 72,
      'wind_speed': 14.0,
      'description': 'Partly cloudy',
      'icon': '02d',
      'precipitation_probability': 0.15,
    },
  ],
  'daily': [
    {
      'date': '2026-09-07',
      'temp_min': 25.0,
      'temp_max': 33.0,
      'humidity': 72,
      'wind_speed': 14.0,
      'description': 'Partly cloudy',
      'icon': '02d',
      'sunrise': 1756100400,
      'sunset': 1756145000,
      'precipitation_probability': 0.35,
    },
  ],
};

const _emptyAlertsJson = {'alerts': [], 'total': 0};

const _oneAlertJson = {
  'alerts': [
    {
      'alert_id': 'alert-001',
      'alert_type': 'thunderstorm',
      'severity': 'moderate',
      'title': 'Thunderstorm Warning',
      'description': 'Heavy thunderstorms expected.',
      'area': 'Madurai District',
      'start_time': 1756137600,
    },
  ],
  'total': 1,
};

const _advisoriesJson = {
  'advisories': [
    {
      'advisory_id': 'adv-001',
      'category': 'health',
      'title': 'Heat Safety Advisory',
      'message': 'High temperature detected.',
      'recommendation': 'Drink 2-3 litres of water.',
      'valid_until': 1756224000,
    },
    {
      'advisory_id': 'adv-002',
      'category': 'outdoor',
      'title': 'UV Advisory',
      'message': 'High solar radiation.',
      'recommendation': 'Wear sunscreen.',
      'valid_until': 1756224000,
    },
  ],
  'total': 2,
};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a mock HTTP client that cycles through [responses] based on URL path.
MockClient _routedClient({
  required Map<String, dynamic> currentResponse,
  required Map<String, dynamic> forecastResponse,
  required Map<String, dynamic> alertsResponse,
  Map<String, dynamic>? advisoryResponse,
  int statusCode = 200,
}) {
  return MockClient((request) async {
    final path = request.url.path;
    dynamic body;
    if (path.contains('/weather/current')) {
      body = currentResponse;
    } else if (path.contains('/weather/forecast')) {
      body = forecastResponse;
    } else if (path.contains('/alerts')) {
      body = alertsResponse;
    } else if (path.contains('/advisory')) {
      body = advisoryResponse ?? {'advisories': [], 'total': 0};
    } else {
      body = {};
    }
    return http.Response(
      json.encode(body),
      statusCode,
      headers: {'content-type': 'application/json'},
    );
  });
}

MockClient _alwaysErrorClient(int status) {
  return MockClient((_) async => http.Response(
        json.encode({'detail': 'service error'}),
        status,
        headers: {'content-type': 'application/json'},
      ));
}

MockClient _networkFailClient() {
  return MockClient((_) async => throw Exception('network failure'));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('WeatherProvider state transitions', () {
    test('starts in initial state', () {
      final provider = WeatherProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _routedClient(
            currentResponse: _currentWeatherJson,
            forecastResponse: _forecastJson,
            alertsResponse: _emptyAlertsJson,
          ),
        ),
      );

      expect(provider.state, WeatherState.initial);
      expect(provider.currentWeather, isNull);
      expect(provider.forecast, isNull);
      expect(provider.alerts, isEmpty);
      expect(provider.errorMessage, isNull);
    });

    test('transitions to loading then success on successful fetch', () async {
      final states = <WeatherState>[];

      final provider = WeatherProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _routedClient(
            currentResponse: _currentWeatherJson,
            forecastResponse: _forecastJson,
            alertsResponse: _emptyAlertsJson,
          ),
        ),
      );

      provider.addListener(() => states.add(provider.state));

      await provider.loadWeather(9.93, 78.12);

      expect(states.contains(WeatherState.loading), true);
      expect(states.last, WeatherState.success);
      expect(provider.currentWeather, isNotNull);
      expect(provider.forecast, isNotNull);
      expect(provider.errorMessage, isNull);
    });

    test('populates currentWeather fields from backend response', () async {
      final provider = WeatherProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _routedClient(
            currentResponse: _currentWeatherJson,
            forecastResponse: _forecastJson,
            alertsResponse: _emptyAlertsJson,
          ),
        ),
      );

      await provider.loadWeather(9.93, 78.12);

      expect(provider.currentWeather!.temperature, 29.0);
      expect(provider.currentWeather!.humidity, 72);
      expect(provider.currentWeather!.description, 'Partly cloudy');
      expect(provider.currentWeather!.location.city, 'Madurai');
    });

    test('populates forecast fields from backend response', () async {
      final provider = WeatherProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _routedClient(
            currentResponse: _currentWeatherJson,
            forecastResponse: _forecastJson,
            alertsResponse: _emptyAlertsJson,
          ),
        ),
      );

      await provider.loadWeather(9.93, 78.12);

      expect(provider.forecast!.hourly.length, 1);
      expect(provider.forecast!.daily.length, 1);
      expect(provider.forecast!.units, 'metric');
    });

    test('alerts list is empty when backend returns no alerts', () async {
      final provider = WeatherProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _routedClient(
            currentResponse: _currentWeatherJson,
            forecastResponse: _forecastJson,
            alertsResponse: _emptyAlertsJson,
          ),
        ),
      );

      await provider.loadWeather(9.93, 78.12);

      expect(provider.state, WeatherState.success);
      expect(provider.alerts, isEmpty);
    });

    test('alerts list is populated when backend returns alerts', () async {
      final provider = WeatherProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _routedClient(
            currentResponse: _currentWeatherJson,
            forecastResponse: _forecastJson,
            alertsResponse: _oneAlertJson,
          ),
        ),
      );

      await provider.loadWeather(9.93, 78.12);

      expect(provider.alerts.length, 1);
      expect(provider.alerts.first.title, 'Thunderstorm Warning');
    });

    test('advisories list is empty when backend returns no advisories', () async {
      final provider = WeatherProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _routedClient(
            currentResponse: _currentWeatherJson,
            forecastResponse: _forecastJson,
            alertsResponse: _emptyAlertsJson,
            advisoryResponse: {'advisories': [], 'total': 0},
          ),
        ),
      );

      await provider.loadWeather(9.93, 78.12);

      expect(provider.advisories, isEmpty);
    });

    test('advisories list is populated when backend returns advisories', () async {
      final provider = WeatherProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _routedClient(
            currentResponse: _currentWeatherJson,
            forecastResponse: _forecastJson,
            alertsResponse: _emptyAlertsJson,
            advisoryResponse: _advisoriesJson,
          ),
        ),
      );

      await provider.loadWeather(9.93, 78.12);

      expect(provider.advisories.length, 2);
      expect(provider.advisories.first.title, 'Heat Safety Advisory');
      expect(provider.advisories.first.category, AdvisoryCategory.health);
    });

    test('advisoriesForCategory filters correctly', () async {
      final provider = WeatherProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _routedClient(
            currentResponse: _currentWeatherJson,
            forecastResponse: _forecastJson,
            alertsResponse: _emptyAlertsJson,
            advisoryResponse: _advisoriesJson,
          ),
        ),
      );

      await provider.loadWeather(9.93, 78.12);

      final health = provider.advisoriesForCategory(AdvisoryCategory.health);
      final outdoor = provider.advisoriesForCategory(AdvisoryCategory.outdoor);
      final travel = provider.advisoriesForCategory(AdvisoryCategory.travel);

      expect(health.length, 1);
      expect(health.first.title, 'Heat Safety Advisory');
      expect(outdoor.length, 1);
      expect(outdoor.first.title, 'UV Advisory');
      expect(travel, isEmpty);
    });

    test('transitions to error state on 503 backend error', () async {
      final provider = WeatherProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _alwaysErrorClient(503),
        ),
      );

      await provider.loadWeather(9.93, 78.12);

      expect(provider.state, WeatherState.error);
      expect(provider.errorMessage, isNotNull);
      expect(provider.currentWeather, isNull);
    });

    test('transitions to error state on network failure', () async {
      final provider = WeatherProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _networkFailClient(),
        ),
      );

      await provider.loadWeather(9.93, 78.12);

      expect(provider.state, WeatherState.error);
      expect(provider.errorMessage, isNotNull);
    });

    test('clears previous error on successful retry', () async {
      var shouldFail = true;

      final client = MockClient((request) async {
        if (shouldFail) {
          return http.Response(
            json.encode({'detail': 'error'}),
            503,
            headers: {'content-type': 'application/json'},
          );
        }
        final path = request.url.path;
        dynamic body;
        if (path.contains('/weather/current')) {
          body = _currentWeatherJson;
        } else if (path.contains('/weather/forecast')) {
          body = _forecastJson;
        } else {
          body = _emptyAlertsJson;
        }
        return http.Response(
          json.encode(body),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final provider = WeatherProvider(
        api: ApiService(baseUrl: 'http://test.local/api/v1', client: client),
      );

      // First call — should fail
      await provider.loadWeather(9.93, 78.12);
      expect(provider.state, WeatherState.error);

      // Second call — should succeed
      shouldFail = false;
      await provider.refresh(9.93, 78.12);

      expect(provider.state, WeatherState.success);
      expect(provider.errorMessage, isNull);
    });
  });
}

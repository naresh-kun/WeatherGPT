/// WeatherGPT — Climate Provider Tests (Phase 7)
library;

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weathergpt_app/providers/climate_provider.dart';
import 'package:weathergpt_app/services/api/api_service.dart';

final _sampleClimateJson = {
  'location': 'Madurai',
  'year_from': 2000,
  'year_to': 2023,
  'temperature_trend': {
    'location': 'Madurai',
    'metric': 'temperature',
    'unit': '°C',
    'period': '2000–2023',
    'values': [
      {'year': 2000, 'value': 29.5},
      {'year': 2023, 'value': 29.8},
    ],
  },
  'rainfall_trend': {
    'location': 'Madurai',
    'metric': 'rainfall',
    'unit': 'mm',
    'period': '2000–2023',
    'values': [
      {'year': 2000, 'value': 717.4},
      {'year': 2023, 'value': 820.0},
    ],
  },
  'temperature_comparison': {
    'metric': 'temperature',
    'current_value': 29.8,
    'historical_average': 29.3,
    'difference': 0.5,
    'difference_percent': 1.7,
    'interpretation': 'above_average',
  },
  'rainfall_comparison': {
    'metric': 'rainfall',
    'current_value': 820.0,
    'historical_average': 860.0,
    'difference': -40.0,
    'difference_percent': -4.7,
    'interpretation': 'near_average',
  },
  'temperature_anomaly': 0.5,
  'rainfall_anomaly': -40.0,
  'season': 'Southwest Monsoon',
  'insight': 'Recent temperatures are slightly above the long-term baseline.',
  'data_source': 'Prototype/reference dataset',
  'available_locations': ['Madurai', 'Chennai', 'Coimbatore', 'Tirunelveli'],
};

void main() {
  group('ClimateProvider', () {
    test('initial state has correct defaults', () {
      final provider = ClimateProvider();
      expect(provider.state, ClimateState.initial);
      expect(provider.selectedLocation, 'Madurai');
      expect(provider.yearFrom, 2000);
      expect(provider.yearTo, 2023);
      expect(provider.climateResponse, isNull);
      expect(provider.errorMessage, isNull);
      expect(provider.availableLocations, contains('Madurai'));
    });

    test('loadClimate transitions to loading then success on 200', () async {
      final client = MockClient((request) async {
        expect(request.url.path, contains('/climate'));
        return http.Response(jsonEncode(_sampleClimateJson), 200, headers: {
          'content-type': 'application/json',
        });
      });

      final api = ApiService(baseUrl: 'http://localhost:8000/api/v1', client: client);
      final provider = ClimateProvider(api: api);

      final states = <ClimateState>[];
      provider.addListener(() => states.add(provider.state));

      await provider.loadClimate();

      expect(states, [ClimateState.loading, ClimateState.success]);
      expect(provider.state, ClimateState.success);
      expect(provider.climateResponse, isNotNull);
      expect(provider.climateResponse!.location, 'Madurai');
      expect(provider.climateResponse!.temperatureTrend.values.length, 2);
      expect(provider.climateResponse!.rainfallTrend.values.length, 2);
      expect(provider.errorMessage, isNull);
    });

    test('loadClimate transitions to error on 404 location not found', () async {
      final client = MockClient((request) async {
        return http.Response('{"detail": "Not found"}', 404);
      });

      final api = ApiService(baseUrl: 'http://localhost:8000/api/v1', client: client);
      final provider = ClimateProvider(api: api);

      await provider.loadClimate(location: 'UnknownCity');

      expect(provider.state, ClimateState.error);
      expect(provider.errorMessage, contains('UnknownCity'));
    });

    test('loadClimate transitions to error on 500 server failure', () async {
      final client = MockClient((request) async {
        return http.Response('{"detail": "Server error"}', 500);
      });

      final api = ApiService(baseUrl: 'http://localhost:8000/api/v1', client: client);
      final provider = ClimateProvider(api: api);

      await provider.loadClimate();

      expect(provider.state, ClimateState.error);
      expect(provider.errorMessage, isNotNull);
    });

    test('setLocation updates location and triggers load', () async {
      String? requestedLocation;
      final client = MockClient((request) async {
        requestedLocation = request.url.queryParameters['location'];
        final json = Map<String, dynamic>.from(_sampleClimateJson);
        json['location'] = requestedLocation;
        return http.Response(
          jsonEncode(json),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = ApiService(baseUrl: 'http://localhost:8000/api/v1', client: client);
      final provider = ClimateProvider(api: api);

      await provider.setLocation('Chennai');

      expect(requestedLocation, 'Chennai');
      expect(provider.selectedLocation, 'Chennai');
      expect(provider.state, ClimateState.success);
    });

    test('setYearRange updates years and triggers load', () async {
      int? fromYear;
      int? toYear;
      final client = MockClient((request) async {
        fromYear = int.tryParse(request.url.queryParameters['year_from'] ?? '');
        toYear = int.tryParse(request.url.queryParameters['year_to'] ?? '');
        return http.Response(
          jsonEncode(_sampleClimateJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = ApiService(baseUrl: 'http://localhost:8000/api/v1', client: client);
      final provider = ClimateProvider(api: api);

      await provider.setYearRange(2010, 2020);

      expect(fromYear, 2010);
      expect(toYear, 2020);
      expect(provider.yearFrom, 2010);
      expect(provider.yearTo, 2020);
    });

    test('retry clears error and re-runs load', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return http.Response('Error', 500);
        }
        return http.Response(
          jsonEncode(_sampleClimateJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = ApiService(baseUrl: 'http://localhost:8000/api/v1', client: client);
      final provider = ClimateProvider(api: api);

      await provider.loadClimate();
      expect(provider.state, ClimateState.error);

      await provider.retry();
      expect(provider.state, ClimateState.success);
      expect(callCount, 2);
    });
  });
}

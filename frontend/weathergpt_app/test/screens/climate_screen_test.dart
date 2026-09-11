/// WeatherGPT — Climate Screen Widget Tests (Phase 7)
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weathergpt_app/providers/climate_provider.dart';
import 'package:weathergpt_app/screens/climate/climate_screen.dart';
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
  group('ClimateScreen Widgets', () {
    testWidgets('renders loading state indicator', (tester) async {
      final completer = Completer<http.Response>();
      final client = MockClient((request) => completer.future);

      final api = ApiService(baseUrl: 'http://localhost:8000/api/v1', client: client);
      final provider = ClimateProvider(api: api);

      await tester.pumpWidget(
        MaterialApp(
          home: ClimateScreen(provider: provider),
        ),
      );

      // Trigger build while request is in flight
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing historical climate records...'), findsOneWidget);

      // Complete the request and settle to clean up
      completer.complete(http.Response(
        jsonEncode(_sampleClimateJson),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ));
      await tester.pumpAndSettle();
    });

    testWidgets('renders error state with retry button', (tester) async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final api = ApiService(baseUrl: 'http://localhost:8000/api/v1', client: client);
      final provider = ClimateProvider(api: api);

      await tester.pumpWidget(
        MaterialApp(
          home: ClimateScreen(provider: provider),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed to load climate data'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders success state with insights, comparisons, and charts', (tester) async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(_sampleClimateJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final api = ApiService(baseUrl: 'http://localhost:8000/api/v1', client: client);
      final provider = ClimateProvider(api: api);

      await tester.pumpWidget(
        MaterialApp(
          home: ClimateScreen(provider: provider),
        ),
      );

      await tester.pumpAndSettle();

      // App bar & headers
      expect(find.text('Climate Intelligence'), findsOneWidget);
      expect(find.text('Location:'), findsOneWidget);
      expect(find.text('Period Range'), findsOneWidget);

      // Insight & Season
      expect(find.text('Climate Intelligence Insight'), findsOneWidget);
      expect(find.text('Southwest Monsoon'), findsOneWidget);
      expect(
        find.text('Recent temperatures are slightly above the long-term baseline.'),
        findsOneWidget,
      );

      // Comparisons
      expect(
        find.text('Historical Comparison vs 2000–2023 Baseline'),
        findsOneWidget,
      );
      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('Rainfall'), findsOneWidget);

      // Sections
      expect(find.text('Temperature Trend'), findsOneWidget);
      expect(find.text('Annual Rainfall Trend'), findsOneWidget);
    });
  });
}

/// WeatherGPT — Alerts Screen & AlertCard Widget Tests
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weathergpt_app/models/alert.dart';
import 'package:weathergpt_app/providers/weather_provider.dart';
import 'package:weathergpt_app/screens/alerts/alerts_screen.dart';
import 'package:weathergpt_app/services/api/api_service.dart';
import 'package:weathergpt_app/widgets/alerts/alert_card.dart';

const _locationJson = {
  'lat': 9.93,
  'lon': 78.12,
  'city': 'Madurai',
  'country': 'IN',
  'timezone': 'Asia/Kolkata',
};

const _currentWeatherJson = {
  'location': _locationJson,
  'temperature': 35.0,
  'feels_like': 38.0,
  'humidity': 60,
  'wind_speed': 10.0,
  'wind_direction': 180,
  'description': 'Clear',
  'icon': '01d',
  'uv_index': 6.0,
  'visibility': 10.0,
  'timestamp': 1756137600,
};

const _forecastJson = {
  'location': _locationJson,
  'units': 'metric',
  'hourly': [],
  'daily': [],
};

void main() {
  group('AlertsScreen & AlertCard Widgets', () {
    testWidgets('AlertCard renders title, description, and observed sensor value', (tester) async {
      final alert = WeatherAlert(
        alertId: 'sae-001',
        alertType: 'heat',
        severity: AlertSeverity.severe,
        title: 'Extreme Heat Alert',
        description: 'Dangerously high temperature of 43.5°C detected.',
        area: 'Madurai',
        startTime: 1756137600,
        relevantValue: 43.5,
        threshold: 42.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCard(alert: alert),
          ),
        ),
      );

      expect(find.text('Extreme Heat Alert'), findsOneWidget);
      expect(find.text('Dangerously high temperature of 43.5°C detected.'), findsOneWidget);
      expect(find.textContaining('Observed: 43.5°C'), findsOneWidget);
      expect(find.textContaining('Threshold: 42.0'), findsOneWidget);
      expect(find.text('Madurai'), findsOneWidget);
    });

    testWidgets('AlertCard renders cleanly without observed value when relevantValue is null', (tester) async {
      final alert = WeatherAlert(
        alertId: 'alert-002',
        alertType: 'thunderstorm',
        severity: AlertSeverity.moderate,
        title: 'Thunderstorm Warning',
        description: 'Approaching thunderstorm.',
        area: 'Madurai',
        startTime: 1756137600,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertCard(alert: alert),
          ),
        ),
      );

      expect(find.text('Thunderstorm Warning'), findsOneWidget);
      expect(find.text('Approaching thunderstorm.'), findsOneWidget);
      expect(find.byIcon(Icons.sensors), findsNothing);
    });

    testWidgets('AlertsScreen renders app bar title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AlertsScreen(),
        ),
      );

      expect(find.text('Weather Alerts'), findsOneWidget);
    });

    testWidgets('WeatherProvider parses smart alerts correctly via mock API', (tester) async {
      final mockClient = MockClient((request) async {
        final path = request.url.path;
        dynamic body;
        if (path.contains('/alerts')) {
          body = {
            'alerts': [
              {
                'alert_id': 'sae-001',
                'alert_type': 'heat',
                'severity': 'severe',
                'title': 'Extreme Heat Alert',
                'description': 'Dangerously high temperature of 43.5°C detected.',
                'area': 'Madurai',
                'start_time': 1756137600,
                'relevant_value': 43.5,
                'threshold': 42.0,
              },
            ],
            'total': 1,
          };
        } else if (path.contains('/weather/current')) {
          body = _currentWeatherJson;
        } else if (path.contains('/weather/forecast')) {
          body = _forecastJson;
        } else {
          body = {'advisories': [], 'total': 0};
        }
        return http.Response(json.encode(body), 200,
            headers: {'content-type': 'application/json'});
      });

      final testApi = ApiService(baseUrl: 'http://test.local/api/v1', client: mockClient);
      final p = WeatherProvider(api: testApi);
      await p.loadWeather(9.93, 78.12);

      expect(p.alerts.length, 1);
      expect(p.alerts.first.title, 'Extreme Heat Alert');
      expect(p.alerts.first.relevantValue, 43.5);
      expect(p.alerts.first.formattedRelevantValue, '43.5°C');
    });
  });
}

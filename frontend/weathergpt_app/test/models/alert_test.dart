/// WeatherGPT — Weather Alert Model Tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_app/models/alert.dart';

void main() {
  group('WeatherAlert model', () {
    test('parses smart engine alert JSON with relevant_value and threshold', () {
      final json = {
        'alert_id': 'sae-12345678',
        'alert_type': 'heat',
        'severity': 'severe',
        'title': 'Extreme Heat Alert',
        'description': 'Dangerously high temperature of 42.5°C detected.',
        'area': 'Madurai',
        'start_time': 1756137600,
        'end_time': 1756224000,
        'source': 'WeatherGPT Smart Alert Engine',
        'relevant_value': 42.5,
        'threshold': 42.0,
      };

      final alert = WeatherAlert.fromJson(json);

      expect(alert.alertId, 'sae-12345678');
      expect(alert.alertType, 'heat');
      expect(alert.severity, AlertSeverity.severe);
      expect(alert.title, 'Extreme Heat Alert');
      expect(alert.area, 'Madurai');
      expect(alert.relevantValue, 42.5);
      expect(alert.threshold, 42.0);
      expect(alert.formattedRelevantValue, '42.5°C');
    });

    test('formats relevant values correctly for different alert types', () {
      final heatAlert = WeatherAlert(
        alertId: '1',
        alertType: 'heat',
        severity: AlertSeverity.moderate,
        title: 'Heat Advisory',
        description: 'Warm',
        area: 'City',
        startTime: 0,
        relevantValue: 39.2,
      );
      expect(heatAlert.formattedRelevantValue, '39.2°C');

      final rainAlert = WeatherAlert(
        alertId: '2',
        alertType: 'rain',
        severity: AlertSeverity.moderate,
        title: 'Rain Advisory',
        description: 'Rainy',
        area: 'City',
        startTime: 0,
        relevantValue: 85.0,
      );
      expect(rainAlert.formattedRelevantValue, '85%');

      final windAlert = WeatherAlert(
        alertId: '3',
        alertType: 'wind',
        severity: AlertSeverity.severe,
        title: 'Wind Alert',
        description: 'Windy',
        area: 'City',
        startTime: 0,
        relevantValue: 65.0,
      );
      expect(windAlert.formattedRelevantValue, '65 km/h');

      final uvAlert = WeatherAlert(
        alertId: '4',
        alertType: 'uv',
        severity: AlertSeverity.severe,
        title: 'UV Alert',
        description: 'Sunny',
        area: 'City',
        startTime: 0,
        relevantValue: 9.0,
      );
      expect(uvAlert.formattedRelevantValue, 'UV 9');
    });

    test('parses passthrough alert with null relevant_value and threshold', () {
      final json = {
        'alert_id': 'alert-001',
        'alert_type': 'thunderstorm',
        'severity': 'moderate',
        'title': 'Thunderstorm Warning',
        'description': 'Thunderstorms approaching.',
        'area': 'Region',
        'start_time': 1756137600,
      };

      final alert = WeatherAlert.fromJson(json);

      expect(alert.alertId, 'alert-001');
      expect(alert.relevantValue, isNull);
      expect(alert.threshold, isNull);
      expect(alert.formattedRelevantValue, isNull);
    });

    test('parses all severities correctly', () {
      expect(
        WeatherAlert.fromJson({'severity': 'minor'}).severity,
        AlertSeverity.minor,
      );
      expect(
        WeatherAlert.fromJson({'severity': 'moderate'}).severity,
        AlertSeverity.moderate,
      );
      expect(
        WeatherAlert.fromJson({'severity': 'severe'}).severity,
        AlertSeverity.severe,
      );
      expect(
        WeatherAlert.fromJson({'severity': 'extreme'}).severity,
        AlertSeverity.extreme,
      );
      expect(
        WeatherAlert.fromJson({'severity': 'unknown'}).severity,
        AlertSeverity.minor,
      );
    });
  });

  group('WeatherAlertsResponse model', () {
    test('parses multiple alerts and total count', () {
      final json = {
        'alerts': [
          {
            'alert_id': '1',
            'alert_type': 'heat',
            'severity': 'moderate',
            'title': 'Heat Advisory',
            'description': 'Warm',
            'area': 'Madurai',
            'start_time': 1000,
          },
          {
            'alert_id': '2',
            'alert_type': 'rain',
            'severity': 'moderate',
            'title': 'Rain Advisory',
            'description': 'Rain',
            'area': 'Madurai',
            'start_time': 1000,
          },
        ],
        'total': 2,
      };

      final response = WeatherAlertsResponse.fromJson(json);
      expect(response.total, 2);
      expect(response.alerts.length, 2);
    });
  });
}

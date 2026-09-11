/// WeatherGPT — Climate Model Tests (Phase 7)
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_app/models/climate.dart';

void main() {
  group('ClimateTrendPoint', () {
    test('parses from valid JSON', () {
      final json = {'year': 2020, 'value': 29.5};
      final point = ClimateTrendPoint.fromJson(json);

      expect(point.year, 2020);
      expect(point.value, 29.5);
    });

    test('serializes to JSON correctly', () {
      const point = ClimateTrendPoint(year: 2021, value: 30.1);
      final json = point.toJson();

      expect(json['year'], 2021);
      expect(json['value'], 30.1);
    });
  });

  group('ClimateTrend', () {
    test('parses from valid JSON with points list', () {
      final json = {
        'location': 'Madurai',
        'metric': 'temperature',
        'unit': '°C',
        'period': '2000–2023',
        'values': [
          {'year': 2000, 'value': 28.5},
          {'year': 2001, 'value': 28.8},
        ],
      };

      final trend = ClimateTrend.fromJson(json);
      expect(trend.location, 'Madurai');
      expect(trend.metric, 'temperature');
      expect(trend.unit, '°C');
      expect(trend.period, '2000–2023');
      expect(trend.values.length, 2);
      expect(trend.values[0].year, 2000);
      expect(trend.values[0].value, 28.5);
    });

    test('handles empty values gracefully', () {
      final json = {
        'location': 'Chennai',
        'metric': 'rainfall',
        'unit': 'mm',
        'period': '2000–2023',
      };
      final trend = ClimateTrend.fromJson(json);
      expect(trend.values, isEmpty);
    });
  });

  group('ClimateComparison', () {
    test('parses comparison JSON and tests interpretation helpers', () {
      final json = {
        'metric': 'temperature',
        'current_value': 30.2,
        'historical_average': 29.5,
        'difference': 0.7,
        'difference_percent': 2.37,
        'interpretation': 'above_average',
      };

      final comp = ClimateComparison.fromJson(json);
      expect(comp.metric, 'temperature');
      expect(comp.currentValue, 30.2);
      expect(comp.historicalAverage, 29.5);
      expect(comp.difference, 0.7);
      expect(comp.differencePercent, 2.37);
      expect(comp.isAboveAverage, isTrue);
      expect(comp.isBelowAverage, isFalse);
      expect(comp.isNearAverage, isFalse);
    });

    test('correctly identifies below_average and near_average', () {
      const below = ClimateComparison(
        metric: 'rainfall',
        currentValue: 700.0,
        historicalAverage: 850.0,
        difference: -150.0,
        differencePercent: -17.6,
        interpretation: 'below_average',
      );
      expect(below.isBelowAverage, isTrue);
      expect(below.isAboveAverage, isFalse);

      const near = ClimateComparison(
        metric: 'rainfall',
        currentValue: 845.0,
        historicalAverage: 850.0,
        difference: -5.0,
        differencePercent: -0.6,
        interpretation: 'near_average',
      );
      expect(near.isNearAverage, isTrue);
      expect(near.isAboveAverage, isFalse);
      expect(near.isBelowAverage, isFalse);
    });
  });

  group('ClimateResponse', () {
    test('parses full API response JSON', () {
      final json = {
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
        'insight': 'Temperatures show a slight warming trend over the selected period.',
        'data_source': 'Prototype/reference dataset',
        'available_locations': ['Madurai', 'Chennai', 'Coimbatore', 'Tirunelveli'],
      };

      final response = ClimateResponse.fromJson(json);

      expect(response.location, 'Madurai');
      expect(response.yearFrom, 2000);
      expect(response.yearTo, 2023);
      expect(response.temperatureTrend.values.length, 2);
      expect(response.rainfallTrend.values.length, 2);
      expect(response.temperatureComparison.currentValue, 29.8);
      expect(response.rainfallComparison.difference, -40.0);
      expect(response.temperatureAnomaly, 0.5);
      expect(response.rainfallAnomaly, -40.0);
      expect(response.season, 'Southwest Monsoon');
      expect(response.insight, contains('warming trend'));
      expect(response.availableLocations, contains('Coimbatore'));
    });
  });
}

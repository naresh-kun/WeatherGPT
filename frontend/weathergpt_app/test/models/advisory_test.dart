/// WeatherGPT — Weather Advisory Model Tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_app/models/advisory.dart';

void main() {
  group('WeatherAdvisory model', () {
    test('parses advisory JSON correctly with all categories', () {
      final healthJson = {
        'advisory_id': 'adv-001',
        'category': 'health',
        'title': 'Heat Safety Advisory',
        'message': 'High temperature of 39.5°C detected. Stay hydrated.',
        'recommendation': 'Drink 2-3 litres of water daily.',
        'valid_until': 1756224000,
      };

      final advisory = WeatherAdvisory.fromJson(healthJson);

      expect(advisory.advisoryId, 'adv-001');
      expect(advisory.category, AdvisoryCategory.health);
      expect(advisory.title, 'Heat Safety Advisory');
      expect(advisory.message, contains('39.5°C'));
      expect(advisory.recommendation, contains('2-3 litres'));
      expect(advisory.validUntil, 1756224000);
    });

    test('parses outdoor, travel, and general categories', () {
      expect(
        WeatherAdvisory.fromJson({'category': 'outdoor'}).category,
        AdvisoryCategory.outdoor,
      );
      expect(
        WeatherAdvisory.fromJson({'category': 'travel'}).category,
        AdvisoryCategory.travel,
      );
      expect(
        WeatherAdvisory.fromJson({'category': 'general'}).category,
        AdvisoryCategory.general,
      );
      expect(
        WeatherAdvisory.fromJson({'category': 'unknown'}).category,
        AdvisoryCategory.general,
      );
    });

    test('WeatherAdvisoriesResponse parses list of advisories', () {
      final json = {
        'advisories': [
          {
            'advisory_id': 'adv-001',
            'category': 'health',
            'title': 'Heat Advisory',
            'message': 'Stay cool',
            'recommendation': 'Hydrate',
          },
          {
            'advisory_id': 'adv-002',
            'category': 'outdoor',
            'title': 'UV Advisory',
            'message': 'High solar radiation',
            'recommendation': 'Wear sunscreen',
          },
        ],
        'total': 2,
      };

      final response = WeatherAdvisoriesResponse.fromJson(json);

      expect(response.total, 2);
      expect(response.advisories.length, 2);
      expect(response.advisories[0].title, 'Heat Advisory');
      expect(response.advisories[1].title, 'UV Advisory');
    });

    test('WeatherAdvisoriesResponse handles empty response', () {
      final response = WeatherAdvisoriesResponse.fromJson({'advisories': [], 'total': 0});
      expect(response.total, 0);
      expect(response.advisories, isEmpty);
    });
  });
}

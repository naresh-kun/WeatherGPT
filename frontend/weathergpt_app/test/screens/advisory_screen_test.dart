/// WeatherGPT — Advisory Screen Widget Tests
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_app/models/advisory.dart';
import 'package:weathergpt_app/screens/advisory/advisory_screen.dart';
import 'package:weathergpt_app/widgets/advisory/advisory_card.dart';

void main() {
  group('AdvisoryScreen & AdvisoryCard Widgets', () {
    testWidgets('AdvisoryCard renders title, message, and recommendation', (tester) async {
      final advisory = WeatherAdvisory(
        advisoryId: 'adv-001',
        category: AdvisoryCategory.health,
        title: 'Heat Safety Advisory',
        message: 'High temperature of 40.5°C detected.',
        recommendation: 'Stay hydrated and seek shade.',
        validUntil: 1756224000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdvisoryCard(advisory: advisory),
          ),
        ),
      );

      expect(find.text('Heat Safety Advisory'), findsOneWidget);
      expect(find.text('High temperature of 40.5°C detected.'), findsOneWidget);
      expect(find.text('Recommendation'), findsOneWidget);
      expect(find.text('Stay hydrated and seek shade.'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
    });

    testWidgets('AdvisoryDetailCard renders reason and weather factors when present', (tester) async {
      final advisory = WeatherAdvisory(
        advisoryId: 'adv-002',
        category: AdvisoryCategory.outdoor,
        title: 'UV Advisory',
        message: 'Extreme UV index.',
        recommendation: 'Wear sunscreen SPF 50+.',
        reason: 'UV index exceeds danger threshold.',
        weatherFactors: const ['UV Index: 12.0', 'Direct noon sun'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdvisoryDetailCard(advisory: advisory),
          ),
        ),
      );

      expect(find.text('UV Advisory'), findsOneWidget);
      expect(find.text('Reason'), findsOneWidget);
      expect(find.text('UV index exceeds danger threshold.'), findsOneWidget);
      expect(find.text('Weather factors considered'), findsOneWidget);
      expect(find.text('UV Index: 12.0'), findsOneWidget);
      expect(find.text('Direct noon sun'), findsOneWidget);
    });

    testWidgets('AdvisoryScreen renders app bar title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdvisoryScreen(),
        ),
      );

      expect(find.text('Weather Advisory'), findsOneWidget);
    });
  });
}

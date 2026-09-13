/// WeatherGPT — Chat Cards Widget Tests (Phase 10)
/// Tests for WeatherChatCard and ForecastChatCard widgets.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_app/models/chat.dart';
import 'package:weathergpt_app/widgets/chat/weather_chat_card.dart';
import 'package:weathergpt_app/widgets/chat/forecast_chat_card.dart';

void main() {
  group('WeatherChatCard', () {
    testWidgets('renders all compact weather details properly', (tester) async {
      const summary = WeatherSummary(
        location: 'Madurai',
        temperatureC: 32.5,
        feelsLikeC: 36.2,
        condition: 'Partly cloudy',
        humidityPct: 65,
        windKph: 4.8,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherChatCard(summary: summary),
          ),
        ),
      );

      expect(find.text('Madurai'), findsOneWidget);
      expect(find.text('33°C'), findsOneWidget);
      expect(find.text('Partly cloudy'), findsOneWidget);
      expect(find.text('Feels 36°C'), findsOneWidget);
      expect(find.text('65% humidity'), findsOneWidget);
      expect(find.text('5 km/h'), findsOneWidget);
    });

    testWidgets('renders condition and location cleanly', (tester) async {
      const summary = WeatherSummary(
        location: 'Chennai',
        temperatureC: 30.0,
        feelsLikeC: 33.0,
        condition: 'Clear',
        humidityPct: 70,
        windKph: 12.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherChatCard(summary: summary),
          ),
        ),
      );

      expect(find.text('Chennai'), findsOneWidget);
      expect(find.text('30°C'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('Feels 33°C'), findsOneWidget);
    });
  });

  group('ForecastChatCard', () {
    testWidgets('renders hourly forecast items properly', (tester) async {
      const forecast = ForecastSummary(
        headline: 'Hourly Forecast for Madurai',
        items: [
          HourlyForecastItem(
            time: '12 PM',
            tempC: 34.0,
            condition: 'Sunny',
            rainChance: 10,
          ),
          HourlyForecastItem(
            time: '1 PM',
            tempC: 35.2,
            condition: 'Partly cloudy',
            rainChance: 40,
          ),
          HourlyForecastItem(
            time: '2 PM',
            tempC: 33.1,
            condition: 'Thunderstorm',
            rainChance: 80,
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ForecastChatCard(forecast: forecast),
          ),
        ),
      );

      expect(find.text('Hourly Forecast for Madurai'), findsOneWidget);
      expect(find.text('12 PM'), findsOneWidget);
      expect(find.text('1 PM'), findsOneWidget);
      expect(find.text('2 PM'), findsOneWidget);
      expect(find.text('34°C'), findsOneWidget);
      expect(find.text('35°C'), findsOneWidget);
      expect(find.text('33°C'), findsOneWidget);
      expect(find.text('10%'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets('returns empty widget when items is empty', (tester) async {
      const forecast = ForecastSummary(
        headline: 'Empty Forecast',
        items: [],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ForecastChatCard(forecast: forecast),
          ),
        ),
      );

      expect(find.text('Empty Forecast'), findsNothing);
    });
  });
}

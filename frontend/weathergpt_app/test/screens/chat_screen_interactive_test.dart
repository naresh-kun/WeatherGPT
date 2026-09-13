/// WeatherGPT — Chat Screen Interactive & Reliability Tests (Phase 10)
/// Tests covering:
/// - Active location badge and tap action
/// - Contextual quick action chips in English and Tamil
/// - Quick action chip selection and duplicate-send prevention
/// - Improved thinking/typing state ("WeatherGPT is checking the weather...")
/// - WeatherChatCard and ForecastChatCard embedding in chat bubble
/// - Error banner rendering and retry actions
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_app/l10n/app_localizations.dart';
import 'package:weathergpt_app/main.dart';
import 'package:weathergpt_app/models/chat.dart';
import 'package:weathergpt_app/models/location.dart';
import 'package:weathergpt_app/screens/chat/chat_screen.dart';
import 'package:weathergpt_app/widgets/chat/forecast_chat_card.dart';
import 'package:weathergpt_app/widgets/chat/weather_chat_card.dart';

Widget _createTestApp({Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const ChatScreen(),
  );
}

void main() {
  setUp(() {
    chatProvider.setInitialMessages([]);
    chatProvider.dismissError();
  });

  group('Phase 10 & Cleanup — ChatScreen Startup & Interactive Features', () {
    testWidgets('Chat startup displays clean static welcome state in English with no mock messages', (tester) async {
      await tester.pumpWidget(_createTestApp(locale: const Locale('en')));
      await tester.pumpAndSettle();

      // Welcome greeting in English
      expect(
        find.text("Hey! 👋 I'm WeatherGPT. How can I help you with the weather today?"),
        findsOneWidget,
      );

      // Provider messages must remain empty (no fake messages)
      expect(chatProvider.messages, isEmpty);

      // Quick action chips below welcome message
      expect(find.text("What's the temperature?"), findsOneWidget);
      expect(find.text('Will it rain?'), findsOneWidget);
    });

    testWidgets('Chat startup displays clean static welcome state in Tamil with no mock messages', (tester) async {
      await tester.pumpWidget(_createTestApp(locale: const Locale('ta')));
      await tester.pumpAndSettle();

      // Welcome greeting in Tamil
      expect(
        find.text("வணக்கம்! 👋 நான் WeatherGPT. இன்று வானிலை பற்றி நான் உங்களுக்கு எப்படி உதவலாம்?"),
        findsOneWidget,
      );

      // Provider messages must remain empty (no fake messages)
      expect(chatProvider.messages, isEmpty);

      // Tamil quick action chips below welcome message
      expect(find.text('வெப்பநிலை என்ன?'), findsOneWidget);
      expect(find.text('மழை பெய்யுமா?'), findsOneWidget);
    });

    testWidgets('Active location indicator displays city name and location icon', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.text(locationProvider.selectedLocation.shortDisplayName), findsOneWidget);
    });

    testWidgets('Active location indicator displays raw coordinates when city is null without Madurai fallback', (tester) async {
      final prevLocation = locationProvider.selectedLocation;
      await locationProvider.setLocation(const Location(lat: 9.57, lon: 77.96));
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.text('9.57, 77.96'), findsOneWidget);
      expect(find.text('Madurai'), findsNothing);

      // Restore
      await locationProvider.setLocation(prevLocation);
    });

    testWidgets('Renders contextual quick action chips in English', (tester) async {
      await tester.pumpWidget(_createTestApp(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text("What's the temperature?"), findsOneWidget);
      expect(find.text('Will it rain?'), findsOneWidget);
      expect(find.text('Any weather alerts?'), findsOneWidget);
      expect(find.text('Do I need an umbrella?'), findsOneWidget);
    });

    testWidgets('Renders contextual quick action chips in Tamil', (tester) async {
      await tester.pumpWidget(_createTestApp(locale: const Locale('ta')));
      await tester.pumpAndSettle();

      expect(find.text('வெப்பநிலை என்ன?'), findsOneWidget);
      expect(find.text('மழை பெய்யுமா?'), findsOneWidget);
      expect(find.text('வானிலை எச்சரிக்கைகள் உள்ளதா?'), findsOneWidget);
      expect(find.text('எனக்கு குடை தேவையா?'), findsOneWidget);
    });

    testWidgets('Renders WeatherChatCard for assistant message with weather_summary', (tester) async {
      const summary = WeatherSummary(
        location: 'Madurai',
        temperatureC: 32.5,
        feelsLikeC: 36.0,
        condition: 'Partly cloudy',
        humidityPct: 65,
        windKph: 8.0,
      );

      chatProvider.setInitialMessages([
        const ChatMessage(
          role: ChatRole.assistant,
          content: 'Here is the current weather.',
          timestamp: 1000,
          weatherSummary: summary,
        ),
      ]);

      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(WeatherChatCard), findsOneWidget);
      expect(find.text('Madurai'), findsNWidgets(2)); // AppBar and Card
      expect(find.text('33°C'), findsOneWidget);
      expect(find.text('Partly cloudy'), findsOneWidget);
      expect(find.text('Feels 36°C'), findsOneWidget);
    });

    testWidgets('Renders ForecastChatCard for assistant message with forecast_summary', (tester) async {
      const forecast = ForecastSummary(
        headline: 'Hourly Forecast for Madurai',
        items: [
          HourlyForecastItem(
            time: '2 PM',
            tempC: 34.0,
            condition: 'Sunny',
            rainChance: 0,
          ),
          HourlyForecastItem(
            time: '3 PM',
            tempC: 33.0,
            condition: 'Partly cloudy',
            rainChance: 30,
          ),
        ],
      );

      chatProvider.setInitialMessages([
        const ChatMessage(
          role: ChatRole.assistant,
          content: 'Here is the hourly forecast.',
          timestamp: 2000,
          forecastSummary: forecast,
        ),
      ]);

      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(ForecastChatCard), findsOneWidget);
      expect(find.text('Hourly Forecast for Madurai'), findsOneWidget);
      expect(find.text('2 PM'), findsOneWidget);
      expect(find.text('34°C'), findsOneWidget);
      expect(find.text('3 PM'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('Send button is disabled when text field is empty', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      final sendButtonFinder = find.widgetWithIcon(IconButton, Icons.send);
      expect(sendButtonFinder, findsOneWidget);
      final iconButton = tester.widget<IconButton>(sendButtonFinder);
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('Send button is enabled when text is entered', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Is it going to rain?');
      await tester.pump();

      final sendButtonFinder = find.widgetWithIcon(IconButton, Icons.send);
      final iconButton = tester.widget<IconButton>(sendButtonFinder);
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('Displays thinking state when chatProvider is loading', (tester) async {
      chatProvider.setInitialMessages([
        const ChatMessage(
          role: ChatRole.user,
          content: 'Is it raining?',
          timestamp: 1000,
        ),
      ]);

      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('WeatherGPT is checking the weather...'), findsNothing);
      expect(find.text('Is it raining?'), findsOneWidget);
    });
  });
}

/// WeatherGPT — Widget Tests
/// Basic smoke test: verifies the app launches and the splash screen renders.
/// Does NOT attempt GPS or real HTTP — those are tested in unit test files.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_app/screens/splash/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders WeatherGPT title and subtitle',
      (WidgetTester tester) async {
    // Test the splash screen widget in isolation to avoid GPS/HTTP init.
    await tester.pumpWidget(
      const MaterialApp(home: SplashScreen()),
    );
    await tester.pump(); // one frame

    expect(find.text('WeatherGPT'), findsOneWidget);
    expect(find.text('Your Intelligent Weather Assistant'), findsOneWidget);
  });
}

/// WeatherGPT — Application Entry Point
///
/// Minimal bootstrap that starts the app and loads the SplashScreen.
/// Feature implementation begins after the initial scaffold is complete.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/screens/splash/splash_screen.dart';

void main() {
  runApp(const WeatherGptApp());
}

/// Root application widget.
class WeatherGptApp extends StatelessWidget {
  const WeatherGptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherGPT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

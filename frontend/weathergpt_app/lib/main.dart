/// WeatherGPT — Application Entry Point

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/navigation/app_routes.dart';
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
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}

/// WeatherGPT — Navigation
/// App routing and navigation configuration.

library;

import 'package:flutter/material.dart';
import 'package:weathergpt_app/main.dart';
import 'package:weathergpt_app/navigation/main_shell.dart';
import 'package:weathergpt_app/screens/forecast/forecast_screen.dart';
import 'package:weathergpt_app/screens/location/location_search_screen.dart';
import 'package:weathergpt_app/screens/settings/settings_screen.dart';
import 'package:weathergpt_app/screens/splash/splash_screen.dart';

/// Route names for the WeatherGPT application.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String forecast = '/forecast';
  static const String alerts = '/alerts';
  static const String advisory = '/advisory';
  static const String climate = '/climate';
  static const String settings = '/settings';
  static const String locationSearch = '/location-search';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        home: (_) => const MainShell(),
        chat: (_) => const MainShell(initialIndex: 1),
        forecast: (_) => const ForecastScreen(),
        alerts: (_) => const MainShell(initialIndex: 2),
        advisory: (_) => const MainShell(initialIndex: 3),
        climate: (_) => const MainShell(initialIndex: 4),
        settings: (_) => const SettingsScreen(),
        locationSearch: (_) =>
            LocationSearchScreen(locationProvider: locationProvider),
      };
}

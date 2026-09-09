/// WeatherGPT — Application Entry Point

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/navigation/app_routes.dart';
import 'package:weathergpt_app/providers/weather_provider.dart';
import 'package:weathergpt_app/providers/location_provider.dart';
import 'package:weathergpt_app/providers/chat_provider.dart';

/// Global providers — lightweight approach without a DI framework.
/// Shared across all screens via InheritedWidget-style accessor.
final weatherProvider = WeatherProvider();
final locationProvider = LocationProvider();
final chatProvider = ChatProvider(); // Phase 5: real Gemini-backed chat

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherGptApp());
}

/// Root application widget.
class WeatherGptApp extends StatefulWidget {
  const WeatherGptApp({super.key});

  @override
  State<WeatherGptApp> createState() => _WeatherGptAppState();
}

class _WeatherGptAppState extends State<WeatherGptApp> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await locationProvider.init();
    _loadWeather();
    locationProvider.addListener(_onLocationChanged);
  }

  void _onLocationChanged() {
    _loadWeather();
  }

  void _loadWeather() {
    final loc = locationProvider.selectedLocation;
    weatherProvider.loadWeather(loc.lat, loc.lon);
  }

  @override
  void dispose() {
    locationProvider.removeListener(_onLocationChanged);
    super.dispose();
  }

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

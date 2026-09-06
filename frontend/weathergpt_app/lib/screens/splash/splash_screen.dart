/// WeatherGPT — Splash Screen
/// Initial loading / branding screen. Not yet implemented.
library;

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('WeatherGPT')),
    );
  }
}

/// WeatherGPT — Home Screen
/// Main dashboard showing current weather. Not yet implemented.
library;

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WeatherGPT — Home')),
      body: const Center(child: Text('Home Screen — not yet implemented')),
    );
  }
}

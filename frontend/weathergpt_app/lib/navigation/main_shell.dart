import 'package:flutter/material.dart';
import 'package:weathergpt_app/navigation/app_routes.dart';
import 'package:weathergpt_app/screens/advisory/advisory_screen.dart';
import 'package:weathergpt_app/screens/alerts/alerts_screen.dart';
import 'package:weathergpt_app/screens/chat/chat_screen.dart';
import 'package:weathergpt_app/screens/climate/climate_screen.dart';
import 'package:weathergpt_app/screens/home/home_screen.dart';

import 'package:weathergpt_app/l10n/app_localizations.dart';

/// Main application shell with bottom navigation.
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    this.initialIndex = 0,
    this.initialChatMessage,
  });

  final int initialIndex;
  final String? initialChatMessage;

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  late int _currentIndex;
  String? _pendingChatMessage;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pendingChatMessage = widget.initialChatMessage;
  }

  void navigateToTab(int index, {String? chatMessage}) {
    setState(() {
      _currentIndex = index;
      if (chatMessage != null) {
        _pendingChatMessage = chatMessage;
      }
    });
  }

  void _onChatMessageConsumed() {
    _pendingChatMessage = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onNavigateToChat: (message) => navigateToTab(1, chatMessage: message),
            onNavigateToAlerts: () => navigateToTab(2),
          ),
          ChatScreen(
            initialMessage: _pendingChatMessage,
            onInitialMessageConsumed: _onChatMessageConsumed,
          ),
          const AlertsScreen(),
          const AdvisoryScreen(),
          const ClimateScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n?.navHome ?? 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_outlined),
            selectedIcon: const Icon(Icons.chat),
            label: l10n?.navChat ?? 'WeatherGPT',
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications),
            label: l10n?.navAlerts ?? 'Alerts',
          ),
          NavigationDestination(
            icon: const Icon(Icons.tips_and_updates_outlined),
            selectedIcon: const Icon(Icons.tips_and_updates),
            label: l10n?.navAdvisory ?? 'Advisory',
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_outlined),
            selectedIcon: const Icon(Icons.show_chart),
            label: l10n?.navClimate ?? 'Climate',
          ),
        ],
      ),
    );
  }
}

/// Helper to open settings from any screen.
void openSettings(BuildContext context) {
  Navigator.of(context).pushNamed(AppRoutes.settings);
}

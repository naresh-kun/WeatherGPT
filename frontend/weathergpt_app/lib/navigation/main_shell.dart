import 'package:flutter/material.dart';
import 'package:weathergpt_app/navigation/app_routes.dart';
import 'package:weathergpt_app/screens/advisory/advisory_screen.dart';
import 'package:weathergpt_app/screens/alerts/alerts_screen.dart';
import 'package:weathergpt_app/screens/chat/chat_screen.dart';
import 'package:weathergpt_app/screens/climate/climate_screen.dart';
import 'package:weathergpt_app/screens/home/home_screen.dart';

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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'WeatherGPT',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.tips_and_updates_outlined),
            selectedIcon: Icon(Icons.tips_and_updates),
            label: 'Advisory',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Climate',
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

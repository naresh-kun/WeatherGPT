/// WeatherGPT — Settings Screen
/// User preferences and configuration (local state only).

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';
import 'package:weathergpt_app/l10n/app_localizations.dart';
import 'package:weathergpt_app/main.dart'
    show languageProvider, locationProvider, weatherProvider, climateProvider;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _weatherAlertsEnabled = true;
  bool _voiceResponsesEnabled = false;

  @override
  void initState() {
    super.initState();
    languageProvider.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    languageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  void _selectLanguage(String code) {
    languageProvider.setLanguageCode(code);
    final loc = locationProvider.selectedLocation;
    weatherProvider.loadWeather(loc.lat, loc.lon, language: code);
    climateProvider.loadClimate(language: code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTamil = languageProvider.isTamil;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settingsTitle ?? 'Settings'),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: l10n?.locationSection ?? 'Location',
            children: [
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(l10n?.currentLocation ?? 'Current Location'),
                subtitle: Text(locationProvider.selectedLocation.displayName.isNotEmpty
                    ? locationProvider.selectedLocation.displayName
                    : MockData.currentLocation.displayName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location selection will be available in a future phase.'),
                    ),
                  );
                },
              ),
            ],
          ),
          _SettingsSection(
            title: l10n?.languageSection ?? 'Language',
            children: [
              _LanguageTile(
                label: 'English',
                selected: !isTamil,
                onTap: () => _selectLanguage('en'),
              ),
              _LanguageTile(
                label: 'தமிழ்',
                selected: isTamil,
                onTap: () => _selectLanguage('ta'),
              ),
            ],
          ),
          _SettingsSection(
            title: l10n?.notificationsSection ?? 'Notifications',
            children: [
              SwitchListTile(
                title: Text(l10n?.weatherAlerts ?? 'Weather Alerts'),
                subtitle: Text(l10n?.receiveWeatherAlerts ?? 'Receive weather alert notifications'),
                value: _weatherAlertsEnabled,
                onChanged: (value) => setState(() => _weatherAlertsEnabled = value),
              ),
            ],
          ),
          _SettingsSection(
            title: l10n?.voiceSection ?? 'Voice',
            children: [
              SwitchListTile(
                title: Text(l10n?.voiceResponses ?? 'Voice Responses'),
                subtitle: Text(l10n?.enableTts ?? 'Enable text-to-speech for WeatherGPT'),
                value: _voiceResponsesEnabled,
                onChanged: (value) => setState(() => _voiceResponsesEnabled = value),
              ),
            ],
          ),
          _SettingsSection(
            title: l10n?.unitsSection ?? 'Units',
            children: [
              ListTile(
                leading: const Icon(Icons.thermostat_outlined),
                title: Text(l10n?.temperature ?? 'Temperature'),
                trailing: const Text('°C'),
              ),
              ListTile(
                leading: const Icon(Icons.speed_outlined),
                title: Text(l10n?.wind ?? 'Wind'),
                trailing: const Text('km/h'),
              ),
            ],
          ),
          _SettingsSection(
            title: l10n?.aboutSection ?? 'About',
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cloud_queue, color: AppColors.primary),
                ),
                title: Text(l10n?.appTitle ?? 'WeatherGPT'),
                subtitle: Text(
                  l10n?.aboutSubtitle ?? 'SIH Prototype\nAI-powered conversational weather assistant',
                ),
                isThreeLine: true,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }
}

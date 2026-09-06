/// WeatherGPT — Settings Screen
/// User preferences and configuration (local state only).

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _weatherAlertsEnabled = true;
  bool _voiceResponsesEnabled = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Location',
            children: [
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Current Location'),
                subtitle: Text(MockData.currentLocation.displayName),
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
            title: 'Language',
            children: [
              _LanguageTile(
                label: 'English',
                selected: _selectedLanguage == 'English',
                onTap: () => setState(() => _selectedLanguage = 'English'),
              ),
              _LanguageTile(
                label: 'Tamil',
                selected: _selectedLanguage == 'Tamil',
                onTap: () {
                  setState(() => _selectedLanguage = 'Tamil');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tamil localization will be available in a future phase.'),
                    ),
                  );
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                title: const Text('Weather Alerts'),
                subtitle: const Text('Receive weather alert notifications'),
                value: _weatherAlertsEnabled,
                onChanged: (value) => setState(() => _weatherAlertsEnabled = value),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Voice',
            children: [
              SwitchListTile(
                title: const Text('Voice Responses'),
                subtitle: const Text('Enable text-to-speech for WeatherGPT'),
                value: _voiceResponsesEnabled,
                onChanged: (value) => setState(() => _voiceResponsesEnabled = value),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Units',
            children: const [
              ListTile(
                leading: Icon(Icons.thermostat_outlined),
                title: Text('Temperature'),
                trailing: Text('°C'),
              ),
              ListTile(
                leading: Icon(Icons.speed_outlined),
                title: Text('Wind'),
                trailing: Text('km/h'),
              ),
            ],
          ),
          _SettingsSection(
            title: 'About',
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
                title: const Text('WeatherGPT'),
                subtitle: const Text(
                  'SIH Prototype\nAI-powered conversational weather assistant',
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

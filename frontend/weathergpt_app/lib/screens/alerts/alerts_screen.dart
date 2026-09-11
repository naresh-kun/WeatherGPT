/// WeatherGPT — Alerts Screen
/// Phase 4: real weather alerts from FastAPI backend.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/l10n/app_localizations.dart';
import 'package:weathergpt_app/main.dart';
import 'package:weathergpt_app/models/alert.dart';
import 'package:weathergpt_app/providers/weather_provider.dart';
import 'package:weathergpt_app/widgets/alerts/alert_widgets.dart';
import 'package:weathergpt_app/widgets/common/common_widgets.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    weatherProvider.addListener(_onWeatherChanged);
    locationProvider.addListener(_onLocationChanged);
    languageProvider.addListener(_onWeatherChanged);
  }

  @override
  void dispose() {
    weatherProvider.removeListener(_onWeatherChanged);
    locationProvider.removeListener(_onLocationChanged);
    languageProvider.removeListener(_onWeatherChanged);
    super.dispose();
  }

  void _onWeatherChanged() {
    if (mounted) setState(() {});
  }

  void _onLocationChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    final loc = locationProvider.selectedLocation;
    await weatherProvider.loadWeather(
      loc.lat,
      loc.lon,
      language: languageProvider.languageCode,
    );
  }

  void _showAlertDetail(BuildContext context, WeatherAlert alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXLarge),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            AlertCard(alert: alert),
            const SizedBox(height: AppDimensions.paddingMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = weatherProvider.state;
    final loc = locationProvider.selectedLocation;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.alertsTitle ?? 'Weather Alerts'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(context, state, loc.displayName, l10n),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WeatherState state, String locationName, AppLocalizations? l10n) {
    switch (state) {
      case WeatherState.initial:
      case WeatherState.loading:
        return LoadingWidget(message: l10n?.fetchingAlerts ?? 'Fetching alerts...');

      case WeatherState.error:
        return ErrorDisplayWidget(
          message: weatherProvider.errorMessage ??
              'Unable to fetch alerts right now.\nPlease check your connection and try again.',
          onRetry: _refresh,
        );

      case WeatherState.success:
        final alerts = weatherProvider.alerts;
        if (alerts.isEmpty) {
          return ListView(
            // Wrapping in ListView allows pull-to-refresh
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Text(
                  l10n?.alertsForLocation(locationName) ?? 'Alerts for $locationName',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Text(
                      l10n?.noActiveAlerts ?? 'No active weather alerts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.allClearFor(locationName) ?? 'All clear for $locationName',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          children: [
            Text(
              l10n?.activeAlertsSummary(alerts.length, locationName) ??
                  '${alerts.length} active ${alerts.length == 1 ? 'alert' : 'alerts'} for $locationName',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            ...alerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AlertCard(
                  alert: alert,
                  onTap: () => _showAlertDetail(context, alert),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
          ],
        );
    }
  }
}

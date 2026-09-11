/// WeatherGPT — Forecast Screen
/// Phase 4: real forecast data from FastAPI backend.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/l10n/app_localizations.dart';
import 'package:weathergpt_app/main.dart';
import 'package:weathergpt_app/providers/weather_provider.dart';
import 'package:weathergpt_app/widgets/common/common_widgets.dart';
import 'package:weathergpt_app/widgets/weather/weather_widgets.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = weatherProvider.state;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.forecastTitle ?? 'Forecast'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(state, l10n),
      ),
    );
  }

  Widget _buildBody(WeatherState state, AppLocalizations? l10n) {
    switch (state) {
      case WeatherState.initial:
      case WeatherState.loading:
        return LoadingWidget(message: l10n?.loadingForecast ?? 'Loading forecast...');

      case WeatherState.error:
        return ErrorDisplayWidget(
          message: weatherProvider.errorMessage ??
              (l10n?.unableToFetchWeather ??
                  'Unable to load forecast right now.\nPlease check your connection and try again.'),
          onRetry: _refresh,
        );

      case WeatherState.success:
        final forecast = weatherProvider.forecast!;
        final loc = locationProvider.selectedLocation;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location subtitle
              Text(
                loc.displayName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),

              // Hourly forecast
              SectionHeader(title: l10n?.hourlyForecast ?? 'Hourly Forecast'),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecast.hourly.length,
                  itemBuilder: (context, index) =>
                      HourlyForecastItem(forecast: forecast.hourly[index]),
                ),
              ),

              // Temperature chart
              const SizedBox(height: AppDimensions.paddingLarge),
              const SectionHeader(title: 'Temperature Trend'),
              CommonCard(
                child: forecast.hourly.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('No hourly data available')),
                      )
                    : TemperatureChart(hourlyData: forecast.hourly),
              ),

              // Daily forecast
              const SizedBox(height: AppDimensions.paddingLarge),
              SectionHeader(title: l10n?.sevenDayForecast ?? '7-Day Forecast'),
              if (forecast.daily.isEmpty)
                const CommonCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No daily forecast available')),
                  ),
                )
              else
                ...forecast.daily.map(
                  (day) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DailyForecastCard(forecast: day),
                  ),
                ),

              const SizedBox(height: AppDimensions.paddingLarge),
            ],
          ),
        );
    }
  }
}

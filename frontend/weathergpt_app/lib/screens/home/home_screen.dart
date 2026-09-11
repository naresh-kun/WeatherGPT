/// WeatherGPT — Home Screen
/// Main dashboard — Phase 4: real weather data from FastAPI backend.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';
import 'package:weathergpt_app/main.dart';
import 'package:weathergpt_app/navigation/app_routes.dart';
import 'package:weathergpt_app/navigation/main_shell.dart';
import 'package:weathergpt_app/providers/weather_provider.dart';
import 'package:weathergpt_app/screens/location/location_search_screen.dart';
import 'package:weathergpt_app/widgets/alerts/alert_widgets.dart';
import 'package:weathergpt_app/widgets/common/common_widgets.dart';
import 'package:weathergpt_app/widgets/weather/weather_widgets.dart';

import 'package:weathergpt_app/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onNavigateToChat,
    this.onNavigateToAlerts,
  });

  final void Function(String message)? onNavigateToChat;
  final VoidCallback? onNavigateToAlerts;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    weatherProvider.addListener(_onWeatherChanged);
    locationProvider.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    weatherProvider.removeListener(_onWeatherChanged);
    locationProvider.removeListener(_onLocationChanged);
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
    await weatherProvider.loadWeather(loc.lat, loc.lon, language: languageProvider.languageCode);
  }

  Future<void> _openLocationSearch() async {
    final selected = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            LocationSearchScreen(locationProvider: locationProvider),
      ),
    );
    // If user selected a new location, weather will reload automatically via
    // the locationProvider listener in main.dart.
    if (selected == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = locationProvider.selectedLocation;
    final state = weatherProvider.state;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.homeGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Header ──────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.paddingMedium,
                      AppDimensions.paddingSmall,
                      AppDimensions.paddingMedium,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Location tap → location search
                        Expanded(
                          child: GestureDetector(
                            onTap: _openLocationSearch,
                            child: Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    loc.displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white70, size: 18),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            // GPS button
                            IconButton(
                              icon: locationProvider.gpsLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.my_location,
                                      color: Colors.white),
                              tooltip: l10n?.useCurrentLocation ?? 'Use current location',
                              onPressed: locationProvider.gpsLoading
                                  ? null
                                  : () async {
                                      await locationProvider
                                          .useCurrentLocation();
                                    },
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined,
                                  color: Colors.white),
                              onPressed: () => openSettings(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Body ─────────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: _buildBody(state, l10n),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(WeatherState state, AppLocalizations? l10n) {
    switch (state) {
      case WeatherState.initial:
      case WeatherState.loading:
        return SizedBox(
          height: 400,
          child: LoadingWidget(message: l10n?.fetchingWeather ?? 'Fetching weather...'),
        );

      case WeatherState.error:
        return SizedBox(
          height: 400,
          child: ErrorDisplayWidget(
            message: weatherProvider.errorMessage ??
                (l10n?.unableToFetchWeather ??
                    'Unable to fetch weather right now.\nPlease check your connection and try again.'),
            onRetry: _refresh,
          ),
        );

      case WeatherState.success:
        return _buildWeatherContent(l10n);
    }
  }

  Widget _buildWeatherContent(AppLocalizations? l10n) {
    final weather = weatherProvider.currentWeather!;
    final forecast = weatherProvider.forecast!;
    final alerts = weatherProvider.alerts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current weather card
        WeatherCard(weather: weather),
        const SizedBox(height: AppDimensions.paddingMedium),
        WeatherMetricGrid(
          humidity: weather.humidity,
          windSpeed: weather.windSpeed,
          rainProbability: weather.rainProbability ?? 0,
          uvIndex: weather.uvIndex ?? 0,
        ),

        // Hourly forecast
        const SizedBox(height: AppDimensions.paddingLarge),
        SectionHeader(
          title: l10n?.hourlyForecast ?? 'Hourly Forecast',
          actionLabel: l10n?.fullForecast ?? 'Full forecast',
          onActionTap: () {
            Navigator.of(context).pushNamed(AppRoutes.forecast);
          },
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.hourly.length,
            itemBuilder: (context, index) =>
                HourlyForecastItem(forecast: forecast.hourly[index]),
          ),
        ),

        // 7-day preview
        const SizedBox(height: AppDimensions.paddingMedium),
        SectionHeader(
          title: l10n?.sevenDayPreview ?? '7-Day Preview',
          actionLabel: l10n?.viewAll ?? 'View all',
          onActionTap: () {
            Navigator.of(context).pushNamed(AppRoutes.forecast);
          },
        ),
        ...forecast.daily.take(5).map(
              (day) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DailyForecastCard(
                  forecast: day,
                  compact: true,
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.forecast);
                  },
                ),
              ),
            ),

        // WeatherGPT suggestions — kept as mock (Chat is Phase 5)
        const SizedBox(height: AppDimensions.paddingMedium),
        const SectionHeader(title: 'Ask WeatherGPT'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MockData.homeSuggestions.map((suggestion) {
            return SuggestionChip(
              label: suggestion,
              onTap: () {
                widget.onNavigateToChat?.call(suggestion);
              },
            );
          }).toList(),
        ),

        // Active alerts preview
        const SizedBox(height: AppDimensions.paddingLarge),
        SectionHeader(
          title: 'Active Warnings',
          actionLabel: 'View all',
          onActionTap: widget.onNavigateToAlerts,
        ),
        if (alerts.isEmpty)
          const CommonCard(
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green),
                SizedBox(width: 8),
                Text('No active weather alerts for this location.'),
              ],
            ),
          )
        else
          AlertCard(
            alert: alerts.first,
            compact: true,
            onTap: widget.onNavigateToAlerts,
          ),

        const SizedBox(height: AppDimensions.paddingLarge),
      ],
    );
  }
}

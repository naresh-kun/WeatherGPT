/// WeatherGPT — Home Screen
/// Main dashboard showing current weather and quick actions.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';
import 'package:weathergpt_app/navigation/app_routes.dart';
import 'package:weathergpt_app/navigation/main_shell.dart';
import 'package:weathergpt_app/widgets/alerts/alert_widgets.dart';
import 'package:weathergpt_app/widgets/common/common_widgets.dart';
import 'package:weathergpt_app/widgets/weather/weather_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onNavigateToChat,
    this.onNavigateToAlerts,
  });

  final void Function(String message)? onNavigateToChat;
  final VoidCallback? onNavigateToAlerts;

  @override
  Widget build(BuildContext context) {
    final weather = MockData.currentWeather;
    final location = MockData.currentLocation;
    final hourly = MockData.hourlyForecast;
    final daily = MockData.dailyForecast;
    final alertPreview = MockData.primaryAlertPreview;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.homeGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
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
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            location.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        onPressed: () => openSettings(context),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WeatherCard(weather: weather),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      WeatherMetricGrid(
                        humidity: weather.humidity,
                        windSpeed: weather.windSpeed,
                        rainProbability: weather.rainProbability ?? 0,
                        uvIndex: weather.uvIndex ?? 0,
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      SectionHeader(
                        title: 'Hourly Forecast',
                        actionLabel: 'Full forecast',
                        onActionTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.forecast);
                        },
                      ),
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: hourly.length,
                          itemBuilder: (context, index) =>
                              HourlyForecastItem(forecast: hourly[index]),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      SectionHeader(
                        title: '7-Day Preview',
                        actionLabel: 'View all',
                        onActionTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.forecast);
                        },
                      ),
                      ...daily.take(5).map(
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
                      const SizedBox(height: AppDimensions.paddingMedium),
                      const SectionHeader(title: 'Ask WeatherGPT'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: MockData.homeSuggestions.map((suggestion) {
                          return SuggestionChip(
                            label: suggestion,
                            onTap: () {
                              onNavigateToChat?.call(suggestion);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      SectionHeader(
                        title: 'Active Warnings',
                        actionLabel: 'View all',
                        onActionTap: onNavigateToAlerts,
                      ),
                      AlertCard(
                        alert: alertPreview,
                        compact: true,
                        onTap: onNavigateToAlerts,
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

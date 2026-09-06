/// WeatherGPT — Forecast Screen
/// Multi-day weather forecast display with temperature chart.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';
import 'package:weathergpt_app/widgets/common/common_widgets.dart';
import 'package:weathergpt_app/widgets/weather/weather_widgets.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final forecast = MockData.forecast;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forecast'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MockData.currentLocation.displayName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            const SectionHeader(title: 'Hourly Forecast'),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.hourly.length,
                itemBuilder: (context, index) =>
                    HourlyForecastItem(forecast: forecast.hourly[index]),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            const SectionHeader(title: 'Temperature Trend'),
            CommonCard(
              child: TemperatureChart(hourlyData: forecast.hourly),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            const SectionHeader(title: '7-Day Forecast'),
            ...forecast.daily.map(
              (day) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DailyForecastCard(forecast: day),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

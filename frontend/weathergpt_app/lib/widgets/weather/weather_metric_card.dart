import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/core/utils/weather_utils.dart';
import 'package:weathergpt_app/widgets/common/common_card.dart';

class WeatherMetricCard extends StatelessWidget {
  const WeatherMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class WeatherMetricGrid extends StatelessWidget {
  const WeatherMetricGrid({
    super.key,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.uvIndex,
  });

  final int humidity;
  final double windSpeed;
  final double rainProbability;
  final double uvIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Row(
        children: [
          Expanded(
            child: WeatherMetricCard(
              icon: Icons.water_drop_outlined,
              label: 'Humidity',
              value: '$humidity%',
              iconColor: AppColors.accent,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: WeatherMetricCard(
              icon: Icons.air,
              label: 'Wind',
              value: '${windSpeed.round()} km/h',
              iconColor: AppColors.primaryLight,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: WeatherMetricCard(
              icon: Icons.umbrella_outlined,
              label: 'Rain',
              value: WeatherUtils.formatPercent(rainProbability),
              iconColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: WeatherMetricCard(
              icon: Icons.wb_sunny_outlined,
              label: 'UV Index',
              value: uvIndex.round().toString(),
              iconColor: Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

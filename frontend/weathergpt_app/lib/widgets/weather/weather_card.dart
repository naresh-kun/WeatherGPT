import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/core/utils/weather_utils.dart';
import 'package:weathergpt_app/models/weather.dart';
import 'package:weathergpt_app/widgets/common/common_card.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key, required this.weather});

  final WeatherCurrent weather;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      color: Colors.white.withValues(alpha: 0.95),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WeatherUtils.formatTemperature(weather.temperature),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w200,
                            fontSize: 64,
                          ),
                    ),
                    Text(
                      weather.description,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Feels like ${WeatherUtils.formatTemperature(weather.feelsLike)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                WeatherUtils.iconForCondition(weather.icon),
                size: 72,
                color: WeatherUtils.iconColorForCondition(weather.icon),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _DetailChip(
                icon: Icons.water_drop_outlined,
                label: '${weather.humidity}%',
              ),
              _DetailChip(
                icon: Icons.air,
                label: '${weather.windSpeed.round()} km/h',
              ),
              if (weather.rainProbability != null)
                _DetailChip(
                  icon: Icons.umbrella_outlined,
                  label: WeatherUtils.formatPercent(weather.rainProbability!),
                ),
              if (weather.uvIndex != null)
                _DetailChip(
                  icon: Icons.wb_sunny_outlined,
                  label: 'UV ${weather.uvIndex!.round()}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

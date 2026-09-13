/// WeatherGPT — Forecast Chat Card (Phase 10)
/// Compact, structured hourly forecast card strip rendered alongside assistant responses.
library;

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/models/chat.dart';

class ForecastChatCard extends StatelessWidget {
  const ForecastChatCard({
    super.key,
    required this.forecast,
  });

  final ForecastSummary forecast;

  IconData _getConditionIcon(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('sun') || lower.contains('clear')) {
      return Icons.wb_sunny_rounded;
    } else if (lower.contains('rain') || lower.contains('drizzle') || lower.contains('shower')) {
      return Icons.water_drop_rounded;
    } else if (lower.contains('cloud') || lower.contains('overcast')) {
      return Icons.cloud_rounded;
    } else if (lower.contains('thunder') || lower.contains('storm')) {
      return Icons.thunderstorm_rounded;
    }
    return Icons.wb_cloudy_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (forecast.items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                forecast.headline,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: forecast.items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        _getConditionIcon(item.condition),
                        size: 18,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.tempC.round()}°C',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (item.rainChance > 0) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.umbrella,
                              size: 10,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${item.rainChance}%',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// WeatherGPT — Weather Chat Card (Phase 10)
/// Compact, weather-aware summary card rendered alongside assistant messages
/// using verified weather data from the backend.
library;

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/l10n/app_localizations.dart';
import 'package:weathergpt_app/models/chat.dart';

class WeatherChatCard extends StatelessWidget {
  const WeatherChatCard({
    super.key,
    required this.summary,
  });

  final WeatherSummary summary;

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
    } else if (lower.contains('snow') || lower.contains('ice')) {
      return Icons.ac_unit_rounded;
    } else if (lower.contains('wind') || lower.contains('breeze')) {
      return Icons.air_rounded;
    }
    return Icons.wb_cloudy_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTamil = l10n?.localeName == 'ta';

    final feelsLikeLabel = isTamil
        ? 'உணரப்படும் ${summary.feelsLikeC.round()}°C'
        : 'Feels ${summary.feelsLikeC.round()}°C';
    final humidityLabel = isTamil
        ? '${summary.humidityPct}% ஈரப்பதம்'
        : '${summary.humidityPct}% humidity';
    final windLabel = isTamil
        ? '${summary.windKph.round()} கிமீ/மணி'
        : '${summary.windKph.round()} km/h';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Location Header
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                summary.location,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Temperature & Feels like
          Row(
            children: [
              const Icon(
                Icons.thermostat_rounded,
                size: 16,
                color: Colors.deepOrange,
              ),
              const SizedBox(width: 4),
              Text(
                '${summary.temperatureC.round()}°C',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                feelsLikeLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Condition
          Row(
            children: [
              Icon(
                _getConditionIcon(summary.condition),
                size: 15,
                color: Colors.blueGrey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  summary.condition,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Humidity and Wind
          Row(
            children: [
              const Icon(
                Icons.water_drop_outlined,
                size: 13,
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 3),
              Text(
                humidityLabel,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.air,
                size: 13,
                color: Colors.teal,
              ),
              const SizedBox(width: 3),
              Text(
                windLabel,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

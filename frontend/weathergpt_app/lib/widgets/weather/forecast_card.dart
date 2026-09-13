import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/core/utils/weather_utils.dart';
import 'package:weathergpt_app/l10n/app_localizations.dart';
import 'package:weathergpt_app/models/weather.dart';
import 'package:weathergpt_app/widgets/common/common_card.dart';

class HourlyForecastItem extends StatelessWidget {
  const HourlyForecastItem({super.key, required this.forecast});

  final HourlyForecast forecast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      margin: const EdgeInsets.only(right: AppDimensions.paddingSmall),
      child: CommonCard(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 6,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              forecast.displayTime ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 6),
            Icon(
              WeatherUtils.iconForCondition(forecast.icon),
              color: WeatherUtils.iconColorForCondition(forecast.icon),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              WeatherUtils.formatTemperature(forecast.temperature),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            Text(
              WeatherUtils.formatPercent(forecast.precipitationProbability),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyForecastCard extends StatelessWidget {
  const DailyForecastCard({
    super.key,
    required this.forecast,
    this.compact = false,
    this.onTap,
  });

  final DailyForecast forecast;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTamil = l10n?.localeName == 'ta';
    final dayLabel = WeatherUtils.localizeDay(forecast.displayDay, isTamil: isTamil);
    final conditionLabel = WeatherUtils.localizeCondition(forecast.description, isTamil: isTamil);

    if (compact) {
      return CommonCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              child: Text(
                dayLabel,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              WeatherUtils.iconForCondition(forecast.icon),
              color: WeatherUtils.iconColorForCondition(forecast.icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                conditionLabel,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              WeatherUtils.formatPercent(forecast.precipitationProbability),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
            ),
            const SizedBox(width: 12),
            Text(
              '${forecast.tempMax.round()}°',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 4),
            Text(
              '${forecast.tempMin.round()}°',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return CommonCard(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(
              dayLabel,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            WeatherUtils.iconForCondition(forecast.icon),
            size: 36,
            color: WeatherUtils.iconColorForCondition(forecast.icon),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conditionLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${l10n?.rain ?? 'Rain'} ${WeatherUtils.formatPercent(forecast.precipitationProbability)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${forecast.tempMax.round()}°',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${forecast.tempMin.round()}°',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

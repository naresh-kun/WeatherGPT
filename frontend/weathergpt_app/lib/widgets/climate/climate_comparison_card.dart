/// WeatherGPT — Climate Comparison & Insight Cards
/// Clean summary widgets comparing recent values with long-term historical baselines.
library;

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/models/climate.dart';
import 'package:weathergpt_app/widgets/common/common_widgets.dart';

class ClimateComparisonCard extends StatelessWidget {
  const ClimateComparisonCard({
    super.key,
    required this.temperatureComparison,
    required this.rainfallComparison,
  });

  final ClimateComparison temperatureComparison;
  final ClimateComparison rainfallComparison;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historical Comparison vs 2000–2023 Baseline',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ComparisonTile(
                  title: 'Temperature',
                  currentValue: '${temperatureComparison.currentValue.toStringAsFixed(1)}°C',
                  baselineValue: 'avg ${temperatureComparison.historicalAverage.toStringAsFixed(1)}°C',
                  differenceText: '${temperatureComparison.difference >= 0 ? '+' : ''}${temperatureComparison.difference.toStringAsFixed(1)}°C',
                  interpretation: temperatureComparison.interpretation,
                  isPositiveWarm: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ComparisonTile(
                  title: 'Rainfall',
                  currentValue: '${rainfallComparison.currentValue.round()} mm',
                  baselineValue: 'avg ${rainfallComparison.historicalAverage.round()} mm',
                  differenceText: '${rainfallComparison.difference >= 0 ? '+' : ''}${rainfallComparison.difference.round()} mm (${rainfallComparison.differencePercent >= 0 ? '+' : ''}${rainfallComparison.differencePercent.toStringAsFixed(1)}%)',
                  interpretation: rainfallComparison.interpretation,
                  isPositiveWarm: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComparisonTile extends StatelessWidget {
  const _ComparisonTile({
    required this.title,
    required this.currentValue,
    required this.baselineValue,
    required this.differenceText,
    required this.interpretation,
    required this.isPositiveWarm,
  });

  final String title;
  final String currentValue;
  final String baselineValue;
  final String differenceText;
  final String interpretation;
  final bool isPositiveWarm;

  Color _badgeColor() {
    switch (interpretation) {
      case 'above_average':
        return isPositiveWarm ? Colors.orange.shade700 : AppColors.accent;
      case 'below_average':
        return isPositiveWarm ? Colors.blue.shade600 : Colors.amber.shade800;
      default:
        return Colors.teal.shade600;
    }
  }

  String _formatInterpretation() {
    switch (interpretation) {
      case 'above_average':
        return 'Above Avg';
      case 'below_average':
        return 'Below Avg';
      default:
        return 'Near Avg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _badgeColor();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatInterpretation(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentValue,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            differenceText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            baselineValue,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ClimateInsightCard extends StatelessWidget {
  const ClimateInsightCard({
    super.key,
    required this.insight,
    required this.season,
    required this.dataSource,
  });

  final String insight;
  final String season;
  final String dataSource;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Climate Intelligence Insight',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              if (season.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    season,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insight,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  dataSource,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

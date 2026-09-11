import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';
import 'package:weathergpt_app/models/advisory.dart';
import 'package:weathergpt_app/widgets/common/common_card.dart';

class AdvisoryCard extends StatelessWidget {
  const AdvisoryCard({
    super.key,
    required this.advisory,
    this.onTap,
  });

  final WeatherAdvisory advisory;
  final VoidCallback? onTap;

  Color _colorForCategory(AdvisoryCategory cat) {
    switch (cat) {
      case AdvisoryCategory.health:
        return Colors.orange.shade700;
      case AdvisoryCategory.outdoor:
        return Colors.blue.shade600;
      case AdvisoryCategory.travel:
        return Colors.purple.shade600;
      case AdvisoryCategory.general:
      default:
        return AppColors.primary;
    }
  }

  IconData _iconForCategory(AdvisoryCategory cat) {
    switch (cat) {
      case AdvisoryCategory.health:
        return Icons.health_and_safety_outlined;
      case AdvisoryCategory.outdoor:
        return Icons.directions_run;
      case AdvisoryCategory.travel:
        return Icons.flight_takeoff;
      case AdvisoryCategory.general:
      default:
        return Icons.info_outline;
    }
  }

  String _labelForCategory(AdvisoryCategory cat) {
    switch (cat) {
      case AdvisoryCategory.health:
        return 'Health';
      case AdvisoryCategory.outdoor:
        return 'Outdoor';
      case AdvisoryCategory.travel:
        return 'Travel';
      case AdvisoryCategory.farming:
        return 'Farming';
      case AdvisoryCategory.driving:
        return 'Driving';
      case AdvisoryCategory.general:
        return 'General';
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _colorForCategory(advisory.category);
    final catIcon = _iconForCategory(advisory.category);
    final catLabel = _labelForCategory(advisory.category);

    return CommonCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Icon(catIcon, color: catColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  advisory.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Text(
                  catLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: catColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            advisory.message,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (advisory.recommendation.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingMedium),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recommendation',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          advisory.recommendation,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AdvisoryCategoryCard extends StatelessWidget {
  const AdvisoryCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final AdvisoryCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final emoji = MockData.advisoryCategoryEmojis[category] ?? '📋';
    final label = MockData.advisoryCategoryLabels[category] ?? category.name;

    return CommonCard(
      onTap: onTap,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class AdvisoryDetailCard extends StatelessWidget {
  const AdvisoryDetailCard({super.key, required this.advisory});

  final WeatherAdvisory advisory;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            advisory.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            advisory.message,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _InfoSection(
            title: 'Recommendation',
            content: advisory.recommendation,
            icon: Icons.check_circle_outline,
            color: AppColors.primary,
          ),
          if (advisory.reason != null && advisory.reason!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            _InfoSection(
              title: 'Reason',
              content: advisory.reason!,
              icon: Icons.info_outline,
              color: AppColors.severityModerate,
            ),
          ],
          if (advisory.weatherFactors.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              'Weather factors considered',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            ...advisory.weatherFactors.map(
              (factor) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        factor,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

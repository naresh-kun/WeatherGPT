import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';
import 'package:weathergpt_app/models/advisory.dart';
import 'package:weathergpt_app/widgets/common/common_card.dart';

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
          const SizedBox(height: AppDimensions.paddingSmall),
          _InfoSection(
            title: 'Reason',
            content: advisory.reason,
            icon: Icons.info_outline,
            color: AppColors.severityModerate,
          ),
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

/// WeatherGPT — Advisory Screen
/// Phase 6: real rule-based weather advisories from FastAPI backend.
library;

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/main.dart';
import 'package:weathergpt_app/models/advisory.dart';
import 'package:weathergpt_app/providers/weather_provider.dart';
import 'package:weathergpt_app/widgets/advisory/advisory_widgets.dart';
import 'package:weathergpt_app/widgets/common/common_widgets.dart';

class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen> {
  AdvisoryCategory? _selectedCategory; // null = all

  @override
  void initState() {
    super.initState();
    weatherProvider.addListener(_onWeatherChanged);
    locationProvider.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    weatherProvider.removeListener(_onWeatherChanged);
    locationProvider.removeListener(_onLocationChanged);
    super.dispose();
  }

  void _onWeatherChanged() {
    if (mounted) setState(() {});
  }

  void _onLocationChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    final loc = locationProvider.selectedLocation;
    await weatherProvider.loadWeather(loc.lat, loc.lon);
  }

  void _showAdvisoryDetail(BuildContext context, WeatherAdvisory advisory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXLarge),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            AdvisoryCard(advisory: advisory),
            const SizedBox(height: AppDimensions.paddingMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = weatherProvider.state;
    final loc = locationProvider.selectedLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Advisory'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(context, state, loc.displayName),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WeatherState state, String locationName) {
    switch (state) {
      case WeatherState.initial:
      case WeatherState.loading:
        return const LoadingWidget(message: 'Fetching advisories...');

      case WeatherState.error:
        return ErrorDisplayWidget(
          message: weatherProvider.errorMessage ??
              'Unable to fetch advisories right now.\nPlease check your connection and try again.',
          onRetry: _refresh,
        );

      case WeatherState.success:
        final allAdvisories = weatherProvider.advisories;
        final advisories = _selectedCategory == null
            ? allAdvisories
            : allAdvisories
                .where((a) => a.category == _selectedCategory)
                .toList();

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Weather-based guidance for $locationName',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            _buildCategoryFilters(),
            const SizedBox(height: AppDimensions.paddingMedium),
            if (advisories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.green,
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      Text(
                        'No active advisories',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Conditions are all clear for $locationName',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Text(
                '${advisories.length} ${advisories.length == 1 ? 'advisory' : 'advisories'} available',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              ...advisories.map(
                (advisory) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AdvisoryCard(
                    advisory: advisory,
                    onTap: () => _showAdvisoryDetail(context, advisory),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.paddingLarge),
          ],
        );
    }
  }

  Widget _buildCategoryFilters() {
    const filterCategories = [
      null,
      AdvisoryCategory.health,
      AdvisoryCategory.outdoor,
      AdvisoryCategory.travel,
      AdvisoryCategory.general,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterCategories.map((category) {
          final isSelected = _selectedCategory == category;
          final label = category == null
              ? 'All'
              : switch (category) {
                  AdvisoryCategory.health => 'Health',
                  AdvisoryCategory.outdoor => 'Outdoor',
                  AdvisoryCategory.travel => 'Travel',
                  AdvisoryCategory.general => 'General',
                  _ => category.name,
                };

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

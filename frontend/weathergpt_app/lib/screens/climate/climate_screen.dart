/// WeatherGPT — Climate Screen (Phase 7)
/// Historical climate trends, baseline comparisons, anomalies, and insights.
/// Powered by deterministic backend analysis without LLM involvement.
library;

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/l10n/app_localizations.dart';
import 'package:weathergpt_app/main.dart';
import 'package:weathergpt_app/models/climate.dart';
import 'package:weathergpt_app/providers/climate_provider.dart';
import 'package:weathergpt_app/widgets/climate/climate_widgets.dart';
import 'package:weathergpt_app/widgets/common/common_widgets.dart';

class ClimateScreen extends StatefulWidget {
  const ClimateScreen({
    super.key,
    this.provider,
  });

  final ClimateProvider? provider;

  @override
  State<ClimateScreen> createState() => _ClimateScreenState();
}

class _ClimateScreenState extends State<ClimateScreen> {
  ClimateProvider get _provider => widget.provider ?? climateProvider;

  // Preset period options: [label, startYear, endYear]
  static const _periodPresets = [
    ('2000–2023', 2000, 2023),
    ('2010–2023', 2010, 2023),
    ('2000–2010', 2000, 2010),
    ('2018–2023', 2018, 2023),
  ];

  @override
  void initState() {
    super.initState();
    _provider.addListener(_onStateChanged);
    locationProvider.addListener(_onLocationChanged);
    languageProvider.addListener(_onStateChanged);
    if (_provider.state == ClimateState.initial) {
      _provider.syncWithLocation(
        locationProvider.selectedLocation,
        language: languageProvider.languageCode,
      );
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onStateChanged);
    locationProvider.removeListener(_onLocationChanged);
    languageProvider.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _onLocationChanged() {
    if (mounted) {
      setState(() {});
      _provider.syncWithLocation(
        locationProvider.selectedLocation,
        language: languageProvider.languageCode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.climateTitle ?? 'Climate Intelligence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n?.refreshClimate ?? 'Refresh Climate Data',
            onPressed: () => _provider.refresh(language: languageProvider.languageCode),
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations? l10n) {
    switch (_provider.state) {
      case ClimateState.initial:
      case ClimateState.loading:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                l10n?.analyzingClimate ?? 'Analyzing historical climate records...',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        );

      case ClimateState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.severitySevere,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n?.failedToLoadClimate ?? 'Failed to load climate data',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _provider.errorMessage ?? 'An unexpected error occurred.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _provider.retry(),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n?.retry ?? 'Retry'),
                ),
              ],
            ),
          ),
        );

      case ClimateState.success:
        final data = _provider.climateResponse;
        if (data == null) {
          return Center(
            child: Text(
              l10n?.noClimateRecords ?? 'No climate records available.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return _buildSuccessContent(data, l10n);
    }
  }

  Widget _buildSuccessContent(ClimateResponse data, AppLocalizations? l10n) {
    final availableLocs = _provider.availableLocations;
    final activeLoc = locationProvider.selectedLocation;

    return RefreshIndicator(
      onRefresh: () => _provider.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls Card (Location + Period Selector)
            CommonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Live Location row
                  Row(
                    children: [
                      const Icon(Icons.my_location, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n?.activeLocation ?? 'Active Location'}: ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          activeLoc.displayName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n?.locationLabel ?? 'Location:',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: availableLocs.contains(_provider.selectedLocation)
                            ? _provider.selectedLocation
                            : availableLocs.first,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 15,
                        ),
                        items: availableLocs.map((loc) {
                          return DropdownMenuItem<String>(
                            value: loc,
                            child: Text(loc),
                          );
                        }).toList(),
                        onChanged: (newLoc) {
                          if (newLoc != null) {
                            _provider.setLocation(newLoc);
                          }
                        },
                      ),
                    ],
                  ),
                  if (!_provider.isExactMatch) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Nearest climate station reference for ${activeLoc.shortDisplayName}.',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(height: 20),
                  Text(
                    l10n?.periodRange ?? 'Period Range',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _periodPresets.map((preset) {
                      final label = preset.$1;
                      final from = preset.$2;
                      final to = preset.$3;
                      final isSelected =
                          _provider.yearFrom == from && _provider.yearTo == to;

                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            _provider.setYearRange(from, to);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            // Rule-based Insight Card
            ClimateInsightCard(
              insight: data.insight,
              season: data.season,
              dataSource: data.dataSource,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            // Historical Comparison Card
            ClimateComparisonCard(
              temperatureComparison: data.temperatureComparison,
              rainfallComparison: data.rainfallComparison,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Temperature Trend Section
            Row(
              children: [
                SectionHeader(title: l10n?.temperatureTrend ?? 'Temperature Trend'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${data.temperatureAnomaly >= 0 ? '+' : ''}${data.temperatureAnomaly.toStringAsFixed(1)}°C ${l10n?.anomaly ?? 'anomaly'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CommonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.annualAvgTemp(data.temperatureTrend.period) ??
                        'Annual Average Temperature (${data.temperatureTrend.period})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  ClimateLineChart(trend: data.temperatureTrend),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Rainfall Trend Section
            Row(
              children: [
                SectionHeader(title: l10n?.annualRainfallTrend ?? 'Annual Rainfall Trend'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${data.rainfallAnomaly >= 0 ? '+' : ''}${data.rainfallAnomaly.round()} mm ${l10n?.anomaly ?? 'anomaly'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CommonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.annualPrecipitation(data.rainfallTrend.period) ??
                        'Annual Total Precipitation (${data.rainfallTrend.period})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  RainfallChart(trend: data.rainfallTrend),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
          ],
        ),
      ),
    );
  }
}

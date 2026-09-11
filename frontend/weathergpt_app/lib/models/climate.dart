/// WeatherGPT — Climate Models (Phase 7)
/// Dart representations of deterministic climate trends, comparisons, and insights.
/// Aligned with backend/weathergpt_api/app/schemas/climate.py.
library;

/// A single year's aggregated value in a climate trend series.
class ClimateTrendPoint {
  const ClimateTrendPoint({
    required this.year,
    required this.value,
  });

  final int year;
  final double value;

  factory ClimateTrendPoint.fromJson(Map<String, dynamic> json) {
    return ClimateTrendPoint(
      year: (json['year'] as num).toInt(),
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'year': year,
        'value': value,
      };
}

/// Aggregated climate trend for a specific metric over a period.
class ClimateTrend {
  const ClimateTrend({
    required this.location,
    required this.metric,
    required this.unit,
    required this.period,
    required this.values,
  });

  final String location;
  final String metric;
  final String unit;
  final String period;
  final List<ClimateTrendPoint> values;

  factory ClimateTrend.fromJson(Map<String, dynamic> json) {
    return ClimateTrend(
      location: json['location'] as String? ?? '',
      metric: json['metric'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      period: json['period'] as String? ?? '',
      values: (json['values'] as List<dynamic>?)
              ?.map((e) => ClimateTrendPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'location': location,
        'metric': metric,
        'unit': unit,
        'period': period,
        'values': values.map((e) => e.toJson()).toList(),
      };
}

/// Comparison of a recent period against a long-term historical baseline.
class ClimateComparison {
  const ClimateComparison({
    required this.metric,
    required this.currentValue,
    required this.historicalAverage,
    required this.difference,
    required this.differencePercent,
    required this.interpretation,
  });

  final String metric;
  final double currentValue;
  final double historicalAverage;
  final double difference;
  final double differencePercent;
  final String interpretation;

  bool get isAboveAverage => interpretation == 'above_average';
  bool get isBelowAverage => interpretation == 'below_average';
  bool get isNearAverage => interpretation == 'near_average';

  factory ClimateComparison.fromJson(Map<String, dynamic> json) {
    return ClimateComparison(
      metric: json['metric'] as String? ?? '',
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      historicalAverage: (json['historical_average'] as num?)?.toDouble() ?? 0.0,
      difference: (json['difference'] as num?)?.toDouble() ?? 0.0,
      differencePercent: (json['difference_percent'] as num?)?.toDouble() ?? 0.0,
      interpretation: json['interpretation'] as String? ?? 'near_average',
    );
  }

  Map<String, dynamic> toJson() => {
        'metric': metric,
        'current_value': currentValue,
        'historical_average': historicalAverage,
        'difference': difference,
        'difference_percent': differencePercent,
        'interpretation': interpretation,
      };
}

/// Full climate analysis response returned by GET /api/v1/climate.
class ClimateResponse {
  const ClimateResponse({
    required this.location,
    required this.yearFrom,
    required this.yearTo,
    required this.temperatureTrend,
    required this.rainfallTrend,
    required this.temperatureComparison,
    required this.rainfallComparison,
    required this.temperatureAnomaly,
    required this.rainfallAnomaly,
    required this.season,
    required this.insight,
    required this.dataSource,
    this.availableLocations = const [],
  });

  final String location;
  final int yearFrom;
  final int yearTo;
  final ClimateTrend temperatureTrend;
  final ClimateTrend rainfallTrend;
  final ClimateComparison temperatureComparison;
  final ClimateComparison rainfallComparison;
  final double temperatureAnomaly;
  final double rainfallAnomaly;
  final String season;
  final String insight;
  final String dataSource;
  final List<String> availableLocations;

  factory ClimateResponse.fromJson(Map<String, dynamic> json) {
    return ClimateResponse(
      location: json['location'] as String? ?? '',
      yearFrom: (json['year_from'] as num?)?.toInt() ?? 2000,
      yearTo: (json['year_to'] as num?)?.toInt() ?? 2023,
      temperatureTrend: ClimateTrend.fromJson(
        json['temperature_trend'] as Map<String, dynamic>? ?? {},
      ),
      rainfallTrend: ClimateTrend.fromJson(
        json['rainfall_trend'] as Map<String, dynamic>? ?? {},
      ),
      temperatureComparison: ClimateComparison.fromJson(
        json['temperature_comparison'] as Map<String, dynamic>? ?? {},
      ),
      rainfallComparison: ClimateComparison.fromJson(
        json['rainfall_comparison'] as Map<String, dynamic>? ?? {},
      ),
      temperatureAnomaly: (json['temperature_anomaly'] as num?)?.toDouble() ?? 0.0,
      rainfallAnomaly: (json['rainfall_anomaly'] as num?)?.toDouble() ?? 0.0,
      season: json['season'] as String? ?? '',
      insight: json['insight'] as String? ?? '',
      dataSource: json['data_source'] as String? ?? '',
      availableLocations: (json['available_locations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'location': location,
        'year_from': yearFrom,
        'year_to': yearTo,
        'temperature_trend': temperatureTrend.toJson(),
        'rainfall_trend': rainfallTrend.toJson(),
        'temperature_comparison': temperatureComparison.toJson(),
        'rainfall_comparison': rainfallComparison.toJson(),
        'temperature_anomaly': temperatureAnomaly,
        'rainfall_anomaly': rainfallAnomaly,
        'season': season,
        'insight': insight,
        'data_source': dataSource,
        'available_locations': availableLocations,
      };
}

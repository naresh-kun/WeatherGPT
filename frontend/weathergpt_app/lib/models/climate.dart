/// Climate models aligned with docs/api/DATA_MODELS.md.

class ClimateDataPoint {
  const ClimateDataPoint({
    required this.year,
    required this.value,
    this.anomaly,
  });

  final int year;
  final double value;
  final double? anomaly;
}

class ClimateTrend {
  const ClimateTrend({
    required this.parameter,
    required this.unit,
    required this.baselinePeriod,
    required this.dataPoints,
    required this.summary,
  });

  final String parameter;
  final String unit;
  final String baselinePeriod;
  final List<ClimateDataPoint> dataPoints;
  final String summary;
}

class ClimateDataset {
  const ClimateDataset({
    required this.rangeLabel,
    required this.temperatureTrend,
    required this.rainfallTrend,
    required this.summary,
  });

  final String rangeLabel;
  final ClimateTrend temperatureTrend;
  final ClimateTrend rainfallTrend;
  final String summary;
}

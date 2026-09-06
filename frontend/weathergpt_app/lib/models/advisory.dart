/// Advisory model aligned with docs/api/DATA_MODELS.md.

enum AdvisoryCategory { farming, travel, outdoor, driving }

class WeatherAdvisory {
  const WeatherAdvisory({
    required this.advisoryId,
    required this.category,
    required this.title,
    required this.message,
    required this.recommendation,
    required this.reason,
    required this.weatherFactors,
    this.validUntil,
  });

  final String advisoryId;
  final AdvisoryCategory category;
  final String title;
  final String message;
  final String recommendation;
  final String reason;
  final List<String> weatherFactors;
  final int? validUntil;
}

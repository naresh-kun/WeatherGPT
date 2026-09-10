/// Advisory model aligned with docs/api/DATA_MODELS.md.
library;

enum AdvisoryCategory {
  general,
  travel,
  health,
  outdoor,
  // Kept for backward compatibility with Phase 2 mock models
  farming,
  driving,
}

class WeatherAdvisory {
  const WeatherAdvisory({
    required this.advisoryId,
    required this.category,
    required this.title,
    required this.message,
    required this.recommendation,
    this.reason,
    this.weatherFactors = const [],
    this.validUntil,
  });

  final String advisoryId;
  final AdvisoryCategory category;
  final String title;
  final String message;
  final String recommendation;
  final String? reason;
  final List<String> weatherFactors;
  final int? validUntil;

  factory WeatherAdvisory.fromJson(Map<String, dynamic> json) {
    final catStr = (json['category'] as String?)?.toLowerCase() ?? 'general';
    AdvisoryCategory parsedCat;
    switch (catStr) {
      case 'travel':
        parsedCat = AdvisoryCategory.travel;
        break;
      case 'health':
        parsedCat = AdvisoryCategory.health;
        break;
      case 'outdoor':
        parsedCat = AdvisoryCategory.outdoor;
        break;
      case 'farming':
      case 'agriculture':
        parsedCat = AdvisoryCategory.farming;
        break;
      case 'driving':
        parsedCat = AdvisoryCategory.driving;
        break;
      case 'general':
      default:
        parsedCat = AdvisoryCategory.general;
        break;
    }

    return WeatherAdvisory(
      advisoryId: json['advisory_id'] as String? ?? '',
      category: parsedCat,
      title: json['title'] as String? ?? 'Advisory',
      message: json['message'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      reason: json['reason'] as String?,
      weatherFactors: (json['weather_factors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      validUntil: (json['valid_until'] as num?)?.toInt(),
    );
  }
}

class WeatherAdvisoriesResponse {
  const WeatherAdvisoriesResponse({
    required this.advisories,
    required this.total,
  });

  final List<WeatherAdvisory> advisories;
  final int total;

  factory WeatherAdvisoriesResponse.fromJson(Map<String, dynamic> json) {
    return WeatherAdvisoriesResponse(
      advisories: (json['advisories'] as List<dynamic>?)
              ?.map((e) => WeatherAdvisory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

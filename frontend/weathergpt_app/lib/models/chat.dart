/// Chat models aligned with docs/api/DATA_MODELS.md.
/// Phase 5: ChatResponse.fromJson added for real API integration.

enum ChatRole { user, assistant, system }

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.weatherSummary,
    this.forecastSummary,
  });

  final ChatRole role;
  final String content;
  final int timestamp;
  final WeatherSummary? weatherSummary;
  final ForecastSummary? forecastSummary;
}

class Conversation {
  const Conversation({
    required this.conversationId,
    required this.messages,
    required this.language,
  });

  final String conversationId;
  final List<ChatMessage> messages;
  final String language;
}

/// Structured current weather summary card data (Phase 10).
class WeatherSummary {
  final String location;
  final double temperatureC;
  final double feelsLikeC;
  final String condition;
  final int humidityPct;
  final double windKph;
  final String? icon;

  const WeatherSummary({
    required this.location,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.condition,
    required this.humidityPct,
    required this.windKph,
    this.icon,
  });

  factory WeatherSummary.fromJson(Map<String, dynamic> json) {
    return WeatherSummary(
      location: json['location'] as String? ?? '',
      temperatureC: (json['temperature_c'] as num?)?.toDouble() ?? 0.0,
      feelsLikeC: (json['feels_like_c'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] as String? ?? '',
      humidityPct: (json['humidity_pct'] as num?)?.toInt() ?? 0,
      windKph: (json['wind_kph'] as num?)?.toDouble() ?? 0.0,
      icon: json['icon'] as String?,
    );
  }
}

/// Single hourly slot for chat forecast card (Phase 10).
class HourlyForecastItem {
  final String time;
  final double tempC;
  final String condition;
  final String? icon;
  final int rainChance;

  const HourlyForecastItem({
    required this.time,
    required this.tempC,
    required this.condition,
    this.icon,
    required this.rainChance,
  });

  factory HourlyForecastItem.fromJson(Map<String, dynamic> json) {
    return HourlyForecastItem(
      time: json['time'] as String? ?? '',
      tempC: (json['temp_c'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] as String? ?? '',
      icon: json['icon'] as String?,
      rainChance: (json['rain_chance'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Structured forecast card data (Phase 10).
class ForecastSummary {
  final String headline;
  final List<HourlyForecastItem> items;

  const ForecastSummary({
    required this.headline,
    required this.items,
  });

  factory ForecastSummary.fromJson(Map<String, dynamic> json) {
    return ForecastSummary(
      headline: json['headline'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => HourlyForecastItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Request body sent to POST /api/v1/chat.
class ChatApiRequest {
  const ChatApiRequest({
    required this.message,
    required this.lat,
    required this.lon,
    this.conversationId,
    this.language = 'en',
  });

  final String message;
  final double lat;
  final double lon;
  final String? conversationId;
  final String language;

  Map<String, dynamic> toJson() => {
        'message': message,
        'location': {'lat': lat, 'lon': lon},
        'language': language,
        if (conversationId != null) 'conversation_id': conversationId,
      };
}

/// Response received from POST /api/v1/chat.
class ChatApiResponse {
  const ChatApiResponse({
    required this.message,
    required this.conversationId,
    required this.language,
    required this.suggestions,
    this.weatherSummary,
    this.forecastSummary,
  });

  final String message;
  final String conversationId;
  final String language;
  final List<String> suggestions;
  final WeatherSummary? weatherSummary;
  final ForecastSummary? forecastSummary;

  factory ChatApiResponse.fromJson(Map<String, dynamic> json) {
    return ChatApiResponse(
      message: json['message'] as String,
      conversationId: json['conversation_id'] as String,
      language: json['language'] as String? ?? 'en',
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      weatherSummary: json['weather_summary'] != null
          ? WeatherSummary.fromJson(json['weather_summary'] as Map<String, dynamic>)
          : null,
      forecastSummary: json['forecast_summary'] != null
          ? ForecastSummary.fromJson(json['forecast_summary'] as Map<String, dynamic>)
          : null,
    );
  }
}

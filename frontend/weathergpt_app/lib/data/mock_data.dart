/// Centralized mock data for Phase 2 UI.
/// Replace with repository/API calls in later phases.

import 'package:weathergpt_app/models/models.dart';

class MockData {
  MockData._();

  static const Location currentLocation = Location(
    lat: 9.9252,
    lon: 78.1198,
    city: 'Madurai',
    country: 'Tamil Nadu',
    timezone: 'Asia/Kolkata',
  );

  static const WeatherCurrent currentWeather = WeatherCurrent(
    location: currentLocation,
    temperature: 29,
    feelsLike: 31,
    humidity: 72,
    windSpeed: 14,
    windDirection: 220,
    description: 'Partly Cloudy',
    icon: 'partly_cloudy',
    uvIndex: 6,
    visibility: 10,
    rainProbability: 0.35,
    timestamp: 0,
  );

  static const List<HourlyForecast> hourlyForecast = [
    HourlyForecast(
      timestamp: 0,
      temperature: 29,
      feelsLike: 31,
      humidity: 72,
      windSpeed: 14,
      description: 'Partly Cloudy',
      icon: 'partly_cloudy',
      precipitationProbability: 0.15,
      displayTime: '10 PM',
    ),
    HourlyForecast(
      timestamp: 0,
      temperature: 28,
      feelsLike: 30,
      humidity: 75,
      windSpeed: 12,
      description: 'Cloudy',
      icon: 'cloudy',
      precipitationProbability: 0.20,
      displayTime: '11 PM',
    ),
    HourlyForecast(
      timestamp: 0,
      temperature: 27,
      feelsLike: 28,
      humidity: 78,
      windSpeed: 10,
      description: 'Cloudy',
      icon: 'cloudy',
      precipitationProbability: 0.25,
      displayTime: '12 AM',
    ),
    HourlyForecast(
      timestamp: 0,
      temperature: 27,
      feelsLike: 28,
      humidity: 80,
      windSpeed: 9,
      description: 'Overcast',
      icon: 'cloudy',
      precipitationProbability: 0.30,
      displayTime: '1 AM',
    ),
    HourlyForecast(
      timestamp: 0,
      temperature: 26,
      feelsLike: 27,
      humidity: 82,
      windSpeed: 8,
      description: 'Overcast',
      icon: 'cloudy',
      precipitationProbability: 0.35,
      displayTime: '2 AM',
    ),
    HourlyForecast(
      timestamp: 0,
      temperature: 26,
      feelsLike: 27,
      humidity: 83,
      windSpeed: 7,
      description: 'Light Rain',
      icon: 'rain',
      precipitationProbability: 0.45,
      displayTime: '3 AM',
    ),
    HourlyForecast(
      timestamp: 0,
      temperature: 25,
      feelsLike: 26,
      humidity: 85,
      windSpeed: 8,
      description: 'Light Rain',
      icon: 'rain',
      precipitationProbability: 0.50,
      displayTime: '4 AM',
    ),
    HourlyForecast(
      timestamp: 0,
      temperature: 27,
      feelsLike: 28,
      humidity: 78,
      windSpeed: 10,
      description: 'Partly Cloudy',
      icon: 'partly_cloudy',
      precipitationProbability: 0.20,
      displayTime: '6 AM',
    ),
  ];

  static const List<DailyForecast> dailyForecast = [
    DailyForecast(
      date: '2026-09-06',
      tempMin: 25,
      tempMax: 33,
      humidity: 72,
      windSpeed: 14,
      description: 'Partly Cloudy',
      icon: 'partly_cloudy',
      sunrise: 0,
      sunset: 0,
      precipitationProbability: 0.35,
      displayDay: 'Today',
    ),
    DailyForecast(
      date: '2026-09-07',
      tempMin: 24,
      tempMax: 31,
      humidity: 80,
      windSpeed: 18,
      description: 'Rain',
      icon: 'rain',
      sunrise: 0,
      sunset: 0,
      precipitationProbability: 0.75,
      displayDay: 'Mon',
    ),
    DailyForecast(
      date: '2026-09-08',
      tempMin: 23,
      tempMax: 30,
      humidity: 78,
      windSpeed: 16,
      description: 'Thunderstorm',
      icon: 'thunderstorm',
      sunrise: 0,
      sunset: 0,
      precipitationProbability: 0.85,
      displayDay: 'Tue',
    ),
    DailyForecast(
      date: '2026-09-09',
      tempMin: 24,
      tempMax: 32,
      humidity: 70,
      windSpeed: 12,
      description: 'Partly Cloudy',
      icon: 'partly_cloudy',
      sunrise: 0,
      sunset: 0,
      precipitationProbability: 0.30,
      displayDay: 'Wed',
    ),
    DailyForecast(
      date: '2026-09-10',
      tempMin: 25,
      tempMax: 34,
      humidity: 65,
      windSpeed: 10,
      description: 'Sunny',
      icon: 'sunny',
      sunrise: 0,
      sunset: 0,
      precipitationProbability: 0.10,
      displayDay: 'Thu',
    ),
    DailyForecast(
      date: '2026-09-11',
      tempMin: 26,
      tempMax: 35,
      humidity: 60,
      windSpeed: 8,
      description: 'Sunny',
      icon: 'sunny',
      sunrise: 0,
      sunset: 0,
      precipitationProbability: 0.05,
      displayDay: 'Fri',
    ),
    DailyForecast(
      date: '2026-09-12',
      tempMin: 25,
      tempMax: 33,
      humidity: 68,
      windSpeed: 11,
      description: 'Partly Cloudy',
      icon: 'partly_cloudy',
      sunrise: 0,
      sunset: 0,
      precipitationProbability: 0.25,
      displayDay: 'Sat',
    ),
  ];

  static WeatherForecast get forecast => WeatherForecast(
        location: currentLocation,
        hourly: hourlyForecast,
        daily: dailyForecast,
        units: 'metric',
      );

  static const List<String> chatSuggestions = [
    'Will it rain tomorrow?',
    'Is it good for outdoor activities?',
    "What's the temperature?",
    'Do I need an umbrella?',
  ];

  static const List<String> homeSuggestions = [
    'Will it rain tomorrow?',
    'Do I need an umbrella?',
    'Is tomorrow good for travelling?',
    'How hot will tomorrow be?',
  ];

  static const List<ChatMessage> initialChatMessages = [
    ChatMessage(
      role: ChatRole.user,
      content: 'Will it rain tomorrow in Madurai?',
      timestamp: 0,
    ),
    ChatMessage(
      role: ChatRole.assistant,
      content:
          'There is a high chance of rain tomorrow afternoon. You may want to carry an umbrella if you are going outdoors.',
      timestamp: 0,
    ),
    ChatMessage(
      role: ChatRole.user,
      content: 'How hot will it get?',
      timestamp: 0,
    ),
    ChatMessage(
      role: ChatRole.assistant,
      content:
          'Tomorrow\'s high is expected to reach 31°C with moderate humidity. It may feel warmer in the afternoon.',
      timestamp: 0,
    ),
  ];

  static const Map<String, String> mockChatResponses = {
    'will it rain': 'There is a 75% chance of rain tomorrow afternoon in Madurai. Consider carrying an umbrella.',
    'umbrella': 'Yes, an umbrella is recommended tomorrow due to high rain probability in the afternoon.',
    'outdoor': 'Tomorrow afternoon may not be ideal for outdoor activities due to expected rainfall.',
    'temperature': 'Current temperature is 29°C. Tomorrow\'s high is expected to be 31°C.',
    'travelling': 'Travel conditions tomorrow may be affected by afternoon rain. Plan accordingly.',
    'hot': 'Tomorrow\'s maximum temperature is expected to reach 31°C with moderate humidity.',
    'default':
        'Based on current conditions in Madurai, partly cloudy skies are expected with a chance of rain tomorrow afternoon. Feel free to ask about temperature, rain, or travel advice!',
  };

  static const List<WeatherAlert> alerts = [
    WeatherAlert(
      alertId: 'alert-001',
      alertType: 'rain',
      severity: AlertSeverity.severe,
      title: 'Heavy Rain',
      description: 'Heavy rainfall expected tomorrow afternoon.',
      area: 'Madurai District',
      startTime: 0,
      displayDate: 'Tomorrow, 2:00 PM',
    ),
    WeatherAlert(
      alertId: 'alert-002',
      alertType: 'heatwave',
      severity: AlertSeverity.moderate,
      title: 'Heat Advisory',
      description: 'High temperatures expected during the afternoon.',
      area: 'Madurai District',
      startTime: 0,
      displayDate: 'Today, 12:00 PM – 4:00 PM',
    ),
    WeatherAlert(
      alertId: 'alert-003',
      alertType: 'wind',
      severity: AlertSeverity.moderate,
      title: 'Strong Wind',
      description: 'Strong winds may affect outdoor activities.',
      area: 'Southern Tamil Nadu',
      startTime: 0,
      displayDate: 'Tomorrow, 10:00 AM',
    ),
    WeatherAlert(
      alertId: 'alert-004',
      alertType: 'thunderstorm',
      severity: AlertSeverity.minor,
      title: 'Thunderstorm Watch',
      description: 'Isolated thunderstorms possible in the evening hours.',
      area: 'Madurai & surrounding areas',
      startTime: 0,
      displayDate: 'Tuesday, 5:00 PM',
    ),
  ];

  static WeatherAlert get primaryAlertPreview => alerts.first;

  static const List<WeatherAdvisory> advisories = [
    WeatherAdvisory(
      advisoryId: 'adv-001',
      category: AdvisoryCategory.farming,
      title: 'Farming Advisory',
      message:
          'Tomorrow may not be ideal for spraying pesticides because rain probability is high and wind speeds may increase in the afternoon.',
      recommendation: 'Postpone pesticide spraying until Wednesday.',
      reason: 'High rain probability (75%) and increasing wind speeds expected.',
      weatherFactors: ['Rain probability: 75%', 'Wind speed: up to 18 km/h', 'Humidity: 80%'],
    ),
    WeatherAdvisory(
      advisoryId: 'adv-002',
      category: AdvisoryCategory.travel,
      title: 'Travel Advisory',
      message:
          'Afternoon rain may cause delays on major routes. Plan travel for morning hours when conditions are clearer.',
      recommendation: 'Schedule travel before 11 AM if possible.',
      reason: 'Heavy rainfall expected between 2 PM and 6 PM.',
      weatherFactors: ['Rain probability: 75%', 'Visibility may reduce', 'Road conditions may worsen'],
    ),
    WeatherAdvisory(
      advisoryId: 'adv-003',
      category: AdvisoryCategory.outdoor,
      title: 'Outdoor Activity Advisory',
      message:
          'Outdoor sports and events may be disrupted by afternoon thunderstorms. Morning hours offer better conditions.',
      recommendation: 'Reschedule outdoor activities to morning or Wednesday.',
      reason: 'Thunderstorm risk increases after noon.',
      weatherFactors: ['Thunderstorm probability: 60%', 'UV index: 6', 'Wind gusts possible'],
    ),
    WeatherAdvisory(
      advisoryId: 'adv-004',
      category: AdvisoryCategory.driving,
      title: 'Driving Advisory',
      message:
          'Wet roads and reduced visibility expected during afternoon rain. Drive with caution and maintain safe distances.',
      recommendation: 'Avoid non-essential travel during peak rain hours.',
      reason: 'Heavy rain and possible waterlogging on low-lying roads.',
      weatherFactors: ['Rain intensity: heavy', 'Visibility: reduced', 'Wind: moderate'],
    ),
  ];

  static const Map<AdvisoryCategory, String> advisoryCategoryLabels = {
    AdvisoryCategory.farming: 'Farming',
    AdvisoryCategory.travel: 'Travel',
    AdvisoryCategory.outdoor: 'Outdoor',
    AdvisoryCategory.driving: 'Driving',
  };

  static const Map<AdvisoryCategory, String> advisoryCategoryEmojis = {
    AdvisoryCategory.farming: '🌾',
    AdvisoryCategory.travel: '✈️',
    AdvisoryCategory.outdoor: '🏃',
    AdvisoryCategory.driving: '🚗',
  };

  static final Map<String, ClimateDataset> climateDatasets = {
    '5 Years': ClimateDataset(
      rangeLabel: '5 Years',
      temperatureTrend: ClimateTrend(
        parameter: 'temperature',
        unit: '°C',
        baselinePeriod: '2016-2020',
        summary: 'Average temperature has risen by 0.8°C over the last 5 years.',
        dataPoints: [
          ClimateDataPoint(year: 2021, value: 28.2, anomaly: 0.2),
          ClimateDataPoint(year: 2022, value: 28.5, anomaly: 0.5),
          ClimateDataPoint(year: 2023, value: 28.7, anomaly: 0.7),
          ClimateDataPoint(year: 2024, value: 28.9, anomaly: 0.9),
          ClimateDataPoint(year: 2025, value: 29.0, anomaly: 1.0),
        ],
      ),
      rainfallTrend: ClimateTrend(
        parameter: 'precipitation',
        unit: 'mm',
        baselinePeriod: '2016-2020',
        summary: 'Annual rainfall has varied with a slight decrease in recent years.',
        dataPoints: [
          ClimateDataPoint(year: 2021, value: 820, anomaly: -30),
          ClimateDataPoint(year: 2022, value: 890, anomaly: 40),
          ClimateDataPoint(year: 2023, value: 780, anomaly: -70),
          ClimateDataPoint(year: 2024, value: 850, anomaly: 0),
          ClimateDataPoint(year: 2025, value: 810, anomaly: -40),
        ],
      ),
      summary:
          'Average temperature has shown a gradual increase over the selected period, while rainfall has remained variable.',
    ),
    '10 Years': ClimateDataset(
      rangeLabel: '10 Years',
      temperatureTrend: ClimateTrend(
        parameter: 'temperature',
        unit: '°C',
        baselinePeriod: '2011-2020',
        summary: 'Temperature has increased by approximately 1.2°C over 10 years.',
        dataPoints: [
          ClimateDataPoint(year: 2016, value: 27.5, anomaly: -0.5),
          ClimateDataPoint(year: 2017, value: 27.8, anomaly: -0.2),
          ClimateDataPoint(year: 2018, value: 28.0, anomaly: 0.0),
          ClimateDataPoint(year: 2019, value: 28.3, anomaly: 0.3),
          ClimateDataPoint(year: 2020, value: 28.4, anomaly: 0.4),
          ClimateDataPoint(year: 2021, value: 28.2, anomaly: 0.2),
          ClimateDataPoint(year: 2022, value: 28.5, anomaly: 0.5),
          ClimateDataPoint(year: 2023, value: 28.7, anomaly: 0.7),
          ClimateDataPoint(year: 2024, value: 28.9, anomaly: 0.9),
          ClimateDataPoint(year: 2025, value: 29.0, anomaly: 1.0),
        ],
      ),
      rainfallTrend: ClimateTrend(
        parameter: 'precipitation',
        unit: 'mm',
        baselinePeriod: '2011-2020',
        summary: 'Rainfall shows cyclical variation with no consistent long-term trend.',
        dataPoints: [
          ClimateDataPoint(year: 2016, value: 900, anomaly: 50),
          ClimateDataPoint(year: 2017, value: 870, anomaly: 20),
          ClimateDataPoint(year: 2018, value: 840, anomaly: -10),
          ClimateDataPoint(year: 2019, value: 880, anomaly: 30),
          ClimateDataPoint(year: 2020, value: 850, anomaly: 0),
          ClimateDataPoint(year: 2021, value: 820, anomaly: -30),
          ClimateDataPoint(year: 2022, value: 890, anomaly: 40),
          ClimateDataPoint(year: 2023, value: 780, anomaly: -70),
          ClimateDataPoint(year: 2024, value: 850, anomaly: 0),
          ClimateDataPoint(year: 2025, value: 810, anomaly: -40),
        ],
      ),
      summary:
          'Average temperature has shown a gradual increase over the selected period. Rainfall patterns remain variable year to year.',
    ),
    '20 Years': ClimateDataset(
      rangeLabel: '20 Years',
      temperatureTrend: ClimateTrend(
        parameter: 'temperature',
        unit: '°C',
        baselinePeriod: '2001-2020',
        summary: 'Long-term warming trend of approximately 1.5°C over 20 years.',
        dataPoints: [
          ClimateDataPoint(year: 2006, value: 27.0, anomaly: -1.0),
          ClimateDataPoint(year: 2008, value: 27.2, anomaly: -0.8),
          ClimateDataPoint(year: 2010, value: 27.4, anomaly: -0.6),
          ClimateDataPoint(year: 2012, value: 27.6, anomaly: -0.4),
          ClimateDataPoint(year: 2014, value: 27.8, anomaly: -0.2),
          ClimateDataPoint(year: 2016, value: 27.5, anomaly: -0.5),
          ClimateDataPoint(year: 2018, value: 28.0, anomaly: 0.0),
          ClimateDataPoint(year: 2020, value: 28.4, anomaly: 0.4),
          ClimateDataPoint(year: 2022, value: 28.5, anomaly: 0.5),
          ClimateDataPoint(year: 2024, value: 28.9, anomaly: 0.9),
        ],
      ),
      rainfallTrend: ClimateTrend(
        parameter: 'precipitation',
        unit: 'mm',
        baselinePeriod: '2001-2020',
        summary: 'Rainfall has fluctuated with occasional drought and excess years.',
        dataPoints: [
          ClimateDataPoint(year: 2006, value: 920, anomaly: 70),
          ClimateDataPoint(year: 2008, value: 800, anomaly: -50),
          ClimateDataPoint(year: 2010, value: 880, anomaly: 30),
          ClimateDataPoint(year: 2012, value: 860, anomaly: 10),
          ClimateDataPoint(year: 2014, value: 830, anomaly: -20),
          ClimateDataPoint(year: 2016, value: 900, anomaly: 50),
          ClimateDataPoint(year: 2018, value: 840, anomaly: -10),
          ClimateDataPoint(year: 2020, value: 850, anomaly: 0),
          ClimateDataPoint(year: 2022, value: 890, anomaly: 40),
          ClimateDataPoint(year: 2024, value: 850, anomaly: 0),
        ],
      ),
      summary:
          'Average temperature has shown a gradual increase over the selected period, consistent with regional warming trends.',
    ),
  };

  static List<String> get climateRangeOptions => climateDatasets.keys.toList();

  static ClimateDataset climateForRange(String range) =>
      climateDatasets[range] ?? climateDatasets['5 Years']!;

  /// Simulates an AI response for local chat interaction.
  static String simulateChatResponse(String userMessage) {
    final lower = userMessage.toLowerCase();
    for (final entry in mockChatResponses.entries) {
      if (entry.key != 'default' && lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return mockChatResponses['default']!;
  }
}

/// WeatherGPT — API Service
/// HTTP client for communicating with the WeatherGPT FastAPI backend.
/// Not yet implemented — placeholder only.
library;

import 'package:weathergpt_app/core/config/app_config.dart';

class ApiService {
  final String baseUrl;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  // TODO: Implement HTTP methods (get, post) using dart:io or http package.
}

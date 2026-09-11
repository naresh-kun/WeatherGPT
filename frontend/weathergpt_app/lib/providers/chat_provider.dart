/// WeatherGPT — Chat Provider (Phase 5)
/// Reactive state management for the WeatherGPT chat feature.
/// Replaces mock responses with real API calls to POST /api/v1/chat.
library;

import 'package:flutter/foundation.dart';
import 'package:weathergpt_app/models/chat.dart';
import 'package:weathergpt_app/models/location.dart';
import 'package:weathergpt_app/services/api/api_service.dart';

enum ChatState { idle, loading, error }

/// Manages chat conversation state and sends real messages to the backend.
///
/// Architecture:
///   ChatProvider → ApiService.sendChatMessage → POST /api/v1/chat
///                                             → FastAPI → WeatherService → Gemini
///
/// [REAL — Phase 5]
class ChatProvider extends ChangeNotifier {
  final ApiService _api;

  ChatProvider({ApiService? api}) : _api = api ?? ApiService();

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  ChatState _state = ChatState.idle;
  ChatState get state => _state;

  bool get isLoading => _state == ChatState.loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// The last user message — used to support retry.
  String? _lastUserMessage;

  /// The location that was active when the last message was sent.
  Location? _lastLocation;

  /// Adds initial messages for a warm UX start (session-only; no persistence).
  void setInitialMessages(List<ChatMessage> msgs) {
    _messages
      ..clear()
      ..addAll(msgs);
    notifyListeners();
  }

  /// Send a new user message to the WeatherGPT backend.
  ///
  /// - [message]: The user's natural-language query (must be non-empty).
  /// - [location]: The currently selected location used to ground the answer.
  Future<void> sendMessage(String message, Location location) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return; // spec: do not send empty messages

    // Persist for retry
    _lastUserMessage = trimmed;
    _lastLocation = location;

    // Add user message immediately for responsive UI
    _messages.add(ChatMessage(
      role: ChatRole.user,
      content: trimmed,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));
    _state = ChatState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.sendChatMessage(
        message: trimmed,
        lat: location.lat,
        lon: location.lon,
      );

      _messages.add(ChatMessage(
        role: ChatRole.assistant,
        content: response.message,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
      _state = ChatState.idle;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = ChatState.error;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      _state = ChatState.error;
    }

    notifyListeners();
  }

  /// Retry the last failed message using the same location.
  Future<void> retry() async {
    if (_lastUserMessage == null || _lastLocation == null) return;

    // Remove the user message we added on the previous attempt
    // (it was already added; we don't want duplicates)
    if (_messages.isNotEmpty && _messages.last.role == ChatRole.user) {
      _messages.removeLast();
    }

    _state = ChatState.idle;
    _errorMessage = null;
    notifyListeners();

    await sendMessage(_lastUserMessage!, _lastLocation!);
  }

  /// Dismiss the current error without retrying.
  void dismissError() {
    _state = ChatState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}

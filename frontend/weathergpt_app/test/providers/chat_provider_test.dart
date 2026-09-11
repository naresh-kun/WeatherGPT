/// WeatherGPT — Chat Provider Tests (Phase 5)
///
/// Tests for ChatProvider covering:
/// - Sending a message → loading state → success state
/// - Messages list updated correctly
/// - Error state on API failure
/// - Retry behavior
/// - Empty message → not sent
/// - Location included in request
///
/// All HTTP calls are mocked. No live server required.
library;

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weathergpt_app/models/chat.dart';
import 'package:weathergpt_app/models/location.dart';
import 'package:weathergpt_app/providers/chat_provider.dart';
import 'package:weathergpt_app/services/api/api_service.dart';

// ---------------------------------------------------------------------------
// Test constants
// ---------------------------------------------------------------------------

const _testLocation = Location(
  lat: 9.9252,
  lon: 78.1198,
  city: 'Madurai',
  country: 'Tamil Nadu',
  timezone: 'Asia/Kolkata',
);

const _chatResponseJson = {
  'message': 'It is currently 31°C and partly cloudy with 68% humidity.',
  'conversation_id': 'conv-test-001',
  'language': 'en',
  'suggestions': <String>[],
};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MockClient _successClient(dynamic body) {
  return MockClient((request) async {
    return http.Response(
      json.encode(body),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
}

MockClient _errorClient(int status, [String detail = 'Service unavailable']) {
  return MockClient((_) async {
    return http.Response(
      json.encode({'detail': detail}),
      status,
      headers: {'content-type': 'application/json'},
    );
  });
}

MockClient _networkErrorClient() {
  return MockClient((_) async => throw Exception('Connection refused'));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ChatProvider.sendMessage', () {
    test('starts in idle state with no messages', () {
      final provider = ChatProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _successClient(_chatResponseJson),
        ),
      );

      expect(provider.state, ChatState.idle);
      expect(provider.messages, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('does NOT send empty or whitespace messages', () async {
      int callCount = 0;
      final client = MockClient((req) async {
        callCount++;
        return http.Response(json.encode(_chatResponseJson), 200,
            headers: {'content-type': 'application/json'});
      });

      final provider = ChatProvider(
        api: ApiService(baseUrl: 'http://test.local/api/v1', client: client),
      );

      await provider.sendMessage('', _testLocation);
      await provider.sendMessage('   ', _testLocation);

      expect(callCount, 0);
      expect(provider.messages, isEmpty);
    });

    test('adds user message immediately and enters loading state', () async {
      // Slow mock so we can observe loading
      final completer = Future<http.Response>.delayed(
        const Duration(milliseconds: 100),
        () => http.Response(
          json.encode(_chatResponseJson),
          200,
          headers: {'content-type': 'application/json'},
        ),
      );

      final provider = ChatProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: MockClient((_) => completer),
        ),
      );

      final states = <ChatState>[];
      provider.addListener(() => states.add(provider.state));

      final future = provider.sendMessage('Will it rain?', _testLocation);

      // Immediately after calling — should be loading
      expect(provider.isLoading, isTrue);
      expect(provider.messages.length, 1);
      expect(provider.messages.first.role, ChatRole.user);
      expect(provider.messages.first.content, 'Will it rain?');

      await future;

      // After completion — should be idle with 2 messages
      expect(provider.state, ChatState.idle);
      expect(provider.messages.length, 2);
      expect(states, contains(ChatState.loading));
      expect(states.last, ChatState.idle);
    });

    test('adds assistant message on successful response', () async {
      final provider = ChatProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _successClient(_chatResponseJson),
        ),
      );

      await provider.sendMessage('What is the weather?', _testLocation);

      expect(provider.messages.length, 2);
      expect(provider.messages[0].role, ChatRole.user);
      expect(provider.messages[1].role, ChatRole.assistant);
      expect(
        provider.messages[1].content,
        'It is currently 31°C and partly cloudy with 68% humidity.',
      );
    });

    test('includes location in the POST request body', () async {
      Map<String, dynamic>? capturedBody;

      final client = MockClient((request) async {
        capturedBody = json.decode(request.body) as Map<String, dynamic>;
        return http.Response(
          json.encode(_chatResponseJson),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final provider = ChatProvider(
        api: ApiService(baseUrl: 'http://test.local/api/v1', client: client),
      );

      await provider.sendMessage('Any rain?', _testLocation);

      expect(capturedBody, isNotNull);
      expect(capturedBody!['message'], 'Any rain?');
      expect(capturedBody!['location'], isA<Map>());
      expect(capturedBody!['location']['lat'], 9.9252);
      expect(capturedBody!['location']['lon'], 78.1198);
    });

    test('enters error state with Gemini busy message on Gemini 503', () async {
      final provider = ChatProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _errorClient(503, 'WeatherGPT is temporarily busy. Please try again.'),
        ),
      );

      await provider.sendMessage('How hot is it?', _testLocation);

      expect(provider.state, ChatState.error);
      expect(provider.errorMessage, 'WeatherGPT is temporarily busy. Please try again.');
      expect(provider.isLoading, isFalse);
    });

    test('enters error state with Weather service message on WeatherAPI 503', () async {
      final provider = ChatProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _errorClient(503, 'Weather service is temporarily unavailable.'),
        ),
      );

      await provider.sendMessage('How hot is it?', _testLocation);

      expect(provider.state, ChatState.error);
      expect(provider.errorMessage, 'Weather service is temporarily unavailable.');
    });

    test('enters error state with rate limit message on 429', () async {
      final provider = ChatProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _errorClient(429, 'WeatherGPT request limit reached. Please try again later.'),
        ),
      );

      await provider.sendMessage('How hot is it?', _testLocation);

      expect(provider.state, ChatState.error);
      expect(provider.errorMessage, 'WeatherGPT request limit reached. Please try again later.');
    });

    test('enters error state on network failure', () async {
      final provider = ChatProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _networkErrorClient(),
        ),
      );

      await provider.sendMessage('Is it cold?', _testLocation);

      expect(provider.state, ChatState.error);
      expect(provider.errorMessage, isNotNull);
    });
  });

  group('ChatProvider.retry', () {
    test('retry resends the last message and clears error on success', () async {
      int callCount = 0;
      final client = MockClient((req) async {
        callCount++;
        if (callCount == 1) {
          return http.Response(
            json.encode({'detail': 'error'}),
            503,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          json.encode(_chatResponseJson),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final provider = ChatProvider(
        api: ApiService(baseUrl: 'http://test.local/api/v1', client: client),
      );

      // First attempt → error
      await provider.sendMessage('Will it rain?', _testLocation);
      expect(provider.state, ChatState.error);

      // Retry → success
      await provider.retry();
      expect(provider.state, ChatState.idle);
      expect(provider.errorMessage, isNull);
      expect(provider.messages.last.role, ChatRole.assistant);
    });

    test('dismissError clears error state without sending', () async {
      final provider = ChatProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _errorClient(503),
        ),
      );

      await provider.sendMessage('Test', _testLocation);
      expect(provider.state, ChatState.error);

      provider.dismissError();
      expect(provider.state, ChatState.idle);
      expect(provider.errorMessage, isNull);
    });
  });

  group('ChatProvider.setInitialMessages', () {
    test('sets initial messages for warm start', () {
      final provider = ChatProvider(
        api: ApiService(
          baseUrl: 'http://test.local/api/v1',
          client: _successClient(_chatResponseJson),
        ),
      );

      provider.setInitialMessages([
        const ChatMessage(
            role: ChatRole.assistant,
            content: 'Hello!',
            timestamp: 0),
      ]);

      expect(provider.messages.length, 1);
      expect(provider.messages.first.content, 'Hello!');
    });
  });
}

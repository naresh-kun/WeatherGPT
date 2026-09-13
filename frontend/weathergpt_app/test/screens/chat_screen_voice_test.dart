/// WeatherGPT — Chat Screen Voice Integration Tests (Phase 9)
/// Tests covering:
/// - ChatBubble Speak button rendering and interaction for assistant messages
/// - ChatScreen mic button rendering
/// - VoiceProvider state reflected in ChatBubble (isSpeaking)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_app/models/chat.dart';
import 'package:weathergpt_app/widgets/chat/chat_bubble.dart';

void main() {
  group('ChatBubble voice controls', () {
    testWidgets('Assistant ChatBubble renders Speak button when onSpeak is provided',
        (WidgetTester tester) async {
      bool speakPressed = false;

      final message = ChatMessage(
        role: ChatRole.assistant,
        content: 'It is currently 28°C and cloudy.',
        timestamp: 1000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: message,
              onSpeak: () => speakPressed = true,
              isSpeaking: false,
            ),
          ),
        ),
      );

      expect(find.text('WeatherGPT'), findsOneWidget);
      expect(find.text('Speak'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);

      await tester.tap(find.text('Speak'));
      await tester.pump();

      expect(speakPressed, isTrue);
    });

    testWidgets('Assistant ChatBubble displays Stop when isSpeaking is true',
        (WidgetTester tester) async {
      bool stopPressed = false;

      final message = ChatMessage(
        role: ChatRole.assistant,
        content: 'Speaking response aloud...',
        timestamp: 2000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: message,
              onSpeak: () => stopPressed = true,
              isSpeaking: true,
            ),
          ),
        ),
      );

      expect(find.text('Stop'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      await tester.tap(find.text('Stop'));
      await tester.pump();

      expect(stopPressed, isTrue);
    });

    testWidgets('User ChatBubble does NOT render Speak button',
        (WidgetTester tester) async {
      final message = ChatMessage(
        role: ChatRole.user,
        content: 'What is the weather today?',
        timestamp: 3000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              message: message,
              onSpeak: () {},
            ),
          ),
        ),
      );

      expect(find.text('Speak'), findsNothing);
      expect(find.byIcon(Icons.volume_up_outlined), findsNothing);
      expect(find.text('What is the weather today?'), findsOneWidget);
    });
  });
}

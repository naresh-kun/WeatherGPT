/// Chat models aligned with docs/api/DATA_MODELS.md.
/// Phase 5: ChatResponse.fromJson added for real API integration.

enum ChatRole { user, assistant, system }

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  final ChatRole role;
  final String content;
  final int timestamp;
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
  });

  final String message;
  final String conversationId;
  final String language;
  final List<String> suggestions;

  factory ChatApiResponse.fromJson(Map<String, dynamic> json) {
    return ChatApiResponse(
      message: json['message'] as String,
      conversationId: json['conversation_id'] as String,
      language: json['language'] as String? ?? 'en',
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

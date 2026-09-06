/// Chat models aligned with docs/api/DATA_MODELS.md.

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

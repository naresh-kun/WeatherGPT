/// WeatherGPT — Chat Screen
/// Conversational weather query interface with local mock responses.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';
import 'package:weathergpt_app/models/chat.dart';
import 'package:weathergpt_app/widgets/chat/chat_widgets.dart';
import 'package:weathergpt_app/widgets/common/common_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.initialMessage,
    this.onInitialMessageConsumed,
  });

  final String? initialMessage;
  final VoidCallback? onInitialMessageConsumed;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = List.from(MockData.initialChatMessages);
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.initialMessage!;
        widget.onInitialMessageConsumed?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? text]) async {
    final message = (text ?? _controller.text).trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        role: ChatRole.user,
        content: message,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        role: ChatRole.assistant,
        content: MockData.simulateChatResponse(message),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    });
    _scrollToBottom();
  }

  void _onVoiceTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input will be available in a future phase.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WeatherGPT',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Your AI Weather Assistant',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('WeatherGPT is typing...'),
                      ],
                    ),
                  );
                }
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: MockData.chatSuggestions.map((suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: SuggestionChip(
                      label: suggestion,
                      onTap: () => _sendMessage(suggestion),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingMedium,
              AppDimensions.paddingSmall,
              AppDimensions.paddingMedium,
              AppDimensions.paddingMedium,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask about the weather...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic, color: AppColors.primary),
                    onPressed: _onVoiceTap,
                    tooltip: 'Voice input',
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(),
                      tooltip: 'Send',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

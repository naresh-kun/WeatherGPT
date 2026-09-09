/// WeatherGPT — Chat Screen
/// Conversational weather query interface powered by the real Gemini AI backend.
/// Phase 5: Replaces mock responses with real API calls via ChatProvider.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';
import 'package:weathergpt_app/main.dart' show chatProvider, locationProvider;
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

  @override
  void initState() {
    super.initState();

    // Set initial messages for warm UX start (Phase 2 mock messages)
    if (chatProvider.messages.isEmpty) {
      chatProvider.setInitialMessages(MockData.initialChatMessages);
    }

    // Listen to provider changes
    chatProvider.addListener(_onChatUpdate);
    locationProvider.addListener(_onChatUpdate);

    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.initialMessage!;
        widget.onInitialMessageConsumed?.call();
      });
    }
  }

  @override
  void dispose() {
    chatProvider.removeListener(_onChatUpdate);
    locationProvider.removeListener(_onChatUpdate);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onChatUpdate() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
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
    if (message.isEmpty) return; // spec: do not send empty messages

    _controller.clear();
    await chatProvider.sendMessage(message, locationProvider.selectedLocation);
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
    final messages = chatProvider.messages;
    final isLoading = chatProvider.isLoading;
    final error = chatProvider.errorMessage;

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
          // Error banner with retry
          if (error != null)
            _ErrorBanner(
              message: error,
              onRetry: () => chatProvider.retry(),
              onDismiss: () => chatProvider.dismissError(),
            ),

          // Message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Typing indicator
                if (isLoading && index == messages.length) {
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
                        Text('WeatherGPT is thinking...'),
                      ],
                    ),
                  );
                }
                return ChatBubble(message: messages[index]);
              },
            ),
          ),

          // Suggestion chips
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
                      onTap: isLoading ? null : () => _sendMessage(suggestion),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Input bar
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
                      onSubmitted: isLoading ? null : (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic, color: AppColors.primary),
                    onPressed: _onVoiceTap,
                    tooltip: 'Voice input',
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isLoading ? AppColors.divider : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: isLoading ? null : () => _sendMessage(),
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

// ---------------------------------------------------------------------------
// Error Banner Widget
// ---------------------------------------------------------------------------

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onRetry,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red.shade50,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: Colors.red)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: onDismiss,
            tooltip: 'Dismiss',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

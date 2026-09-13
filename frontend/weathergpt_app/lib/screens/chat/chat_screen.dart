/// WeatherGPT — Chat Screen
/// Conversational weather query interface powered by the real Gemini AI backend.
/// Phase 5: Replaces mock responses with real API calls via ChatProvider.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';
import 'package:weathergpt_app/l10n/app_localizations.dart';
import 'package:weathergpt_app/main.dart'
    show chatProvider, locationProvider, languageProvider, voiceProvider;
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
    languageProvider.addListener(_onChatUpdate);
    voiceProvider.addListener(_onChatUpdate);

    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.initialMessage!;
        widget.onInitialMessageConsumed?.call();
      });
    }
  }

  @override
  void dispose() {
    voiceProvider.stopSpeaking();
    voiceProvider.cancelListening();
    chatProvider.removeListener(_onChatUpdate);
    locationProvider.removeListener(_onChatUpdate);
    languageProvider.removeListener(_onChatUpdate);
    voiceProvider.removeListener(_onChatUpdate);
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
    // If voice is currently listening or speaking, stop them
    if (voiceProvider.isListening) {
      await voiceProvider.stopListening();
    }
    if (voiceProvider.isSpeaking) {
      await voiceProvider.stopSpeaking();
    }

    final message = (text ?? _controller.text).trim();
    if (message.isEmpty) return; // spec: do not send empty messages

    _controller.clear();
    await chatProvider.sendMessage(
      message,
      locationProvider.selectedLocation,
      language: languageProvider.languageCode,
    );
  }

  Future<void> _onVoiceTap() async {
    final l10n = AppLocalizations.of(context);
    if (voiceProvider.isListening) {
      await voiceProvider.stopListening();
      return;
    }

    final ok = await voiceProvider.startListening(
      languageCode: languageProvider.languageCode,
      onWordsUpdated: (words) {
        if (mounted) {
          _controller.text = words;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
      },
    );

    if (!ok && mounted && voiceProvider.voiceError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(voiceProvider.voiceError!),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: l10n?.dismiss ?? 'Dismiss',
            onPressed: () => voiceProvider.dismissError(),
          ),
        ),
      );
    }
  }

  Future<void> _cancelListening() async {
    await voiceProvider.cancelListening();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messages = chatProvider.messages;
    final isLoading = chatProvider.isLoading;
    final error = chatProvider.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.appTitle ?? 'WeatherGPT',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              l10n?.aiAssistantSubtitle ?? 'Your AI Weather Assistant',
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

          // Voice error banner
          if (voiceProvider.voiceError != null)
            _VoiceErrorBanner(
              message: voiceProvider.voiceError!,
              onDismiss: () => voiceProvider.dismissError(),
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
                  return Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(l10n?.weatherGptThinking ?? 'WeatherGPT is thinking...'),
                      ],
                    ),
                  );
                }
                final message = messages[index];
                final messageId = 'msg_${message.timestamp}_$index';
                return ChatBubble(
                  message: message,
                  isSpeaking: voiceProvider.isSpeaking && voiceProvider.activeSpeakingId == messageId,
                  onSpeak: message.role == ChatRole.assistant
                      ? () {
                          voiceProvider.speak(
                            message.content,
                            languageCode: languageProvider.languageCode,
                            messageId: messageId,
                          );
                        }
                      : null,
                );
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
            decoration: BoxDecoration(
              color: voiceProvider.isListening
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : AppColors.surface,
              border: const Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (voiceProvider.isListening)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.graphic_eq, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            l10n?.voiceListening ?? 'Listening...',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _cancelListening,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(
                              l10n?.voiceCancelListening ?? 'Cancel',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: voiceProvider.isListening
                                ? (l10n?.voiceListening ?? 'Listening...')
                                : (l10n?.askWeatherHint ?? 'Ask about the weather...'),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: isLoading ? null : (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          voiceProvider.isListening ? Icons.stop_circle : Icons.mic,
                          color: voiceProvider.isListening ? Colors.red : AppColors.primary,
                        ),
                        onPressed: _onVoiceTap,
                        tooltip: voiceProvider.isListening
                            ? (l10n?.voiceStopListening ?? 'Stop listening')
                            : (l10n?.voiceTapToSpeak ?? 'Voice input'),
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
    final l10n = AppLocalizations.of(context);
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
            child: Text(l10n?.retry ?? 'Retry', style: const TextStyle(color: Colors.red)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: onDismiss,
            tooltip: l10n?.dismiss ?? 'Dismiss',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Voice Error Banner Widget
// ---------------------------------------------------------------------------

class _VoiceErrorBanner extends StatelessWidget {
  const _VoiceErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.amber.shade50,
      child: Row(
        children: [
          const Icon(Icons.mic_off_outlined, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.amber.shade900, fontSize: 13),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.amber.shade900),
            onPressed: onDismiss,
            tooltip: l10n?.dismiss ?? 'Dismiss',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/l10n/app_localizations.dart';
import 'package:weathergpt_app/models/chat.dart';
import 'package:weathergpt_app/widgets/chat/weather_chat_card.dart';
import 'package:weathergpt_app/widgets/chat/forecast_chat_card.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.onSpeak,
    this.isSpeaking = false,
  });

  final ChatMessage message;
  final VoidCallback? onSpeak;
  final bool isSpeaking;

  bool get isUser => message.role == ChatRole.user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall + 4,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppDimensions.radiusLarge),
            topRight: const Radius.circular(AppDimensions.radiusLarge),
            bottomLeft: Radius.circular(isUser ? AppDimensions.radiusLarge : 4),
            bottomRight: Radius.circular(isUser ? 4 : AppDimensions.radiusLarge),
          ),
          boxShadow: isUser
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: isUser
              ? null
              : Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppColors.primary.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'WeatherGPT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary.withValues(alpha: 0.8),
                      ),
                    ),
                    if (onSpeak != null) ...[
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: onSpeak,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                                size: 14,
                                color: isSpeaking ? AppColors.primary : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                isSpeaking
                                    ? (l10n?.voiceStopSpeaking ?? 'Stop')
                                    : (l10n?.voiceSpeakResponse ?? 'Speak'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSpeaking ? AppColors.primary : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (message.forecastSummary != null)
                ForecastChatCard(forecast: message.forecastSummary!),
              if (message.weatherSummary != null && message.forecastSummary == null)
                WeatherChatCard(summary: message.weatherSummary!),
            ],
            Text(
              message.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: isUser ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

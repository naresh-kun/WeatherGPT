import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/models/chat.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  bool get isUser => message.role == ChatRole.user;

  @override
  Widget build(BuildContext context) {
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
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
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
                  ],
                ),
              ),
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

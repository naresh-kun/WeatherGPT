import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';

class SuggestionChip extends StatelessWidget {
  const SuggestionChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback? onTap; // nullable: null disables the chip

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.divider),
      labelStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
    );
  }
}

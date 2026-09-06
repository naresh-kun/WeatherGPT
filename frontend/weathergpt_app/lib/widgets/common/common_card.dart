import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';

class CommonCard extends StatelessWidget {
  const CommonCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: border != null
            ? BorderSide(color: border!.top.color, width: border!.top.width)
            : BorderSide.none,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppDimensions.paddingMedium),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: card,
      );
    }
    return card;
  }
}

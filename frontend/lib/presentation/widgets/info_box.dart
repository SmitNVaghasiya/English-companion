import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class InfoBox extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final Widget? prefixWidget;

  const InfoBox({
    super.key,
    required this.text,
    this.padding,
    this.width,
    this.textStyle,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.prefixWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 360 ? 12 : 8,
            vertical: 8,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(
          color: borderColor ?? AppColors.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child:
          prefixWidget != null
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  prefixWidget!,
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      text,
                      style:
                          textStyle ??
                          theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              )
              : Text(
                text,
                style:
                    textStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
    );
  }
}

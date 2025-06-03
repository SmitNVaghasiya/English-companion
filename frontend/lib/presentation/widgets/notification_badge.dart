import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A badge widget displaying a notification count over a child widget.
class NotificationBadge extends StatelessWidget {
  final int count;
  final double size;
  final Color color;
  final Offset position;
  final Widget child;

  const NotificationBadge({
    super.key,
    required this.count,
    this.size = 18,
    this.color = AppColors.errorRed,
    this.position = const Offset(-5, -5),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: position.dy,
          right: position.dx,
          child: Semantics(
            label: '$count notifications',
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              constraints: BoxConstraints(minWidth: size, minHeight: size),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: size * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

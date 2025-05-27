import 'package:flutter/material.dart';

class TypingDot extends StatelessWidget {
  final double size;
  final Color color;

  const TypingDot({super.key, this.size = 8.0, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    try {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    } catch (e) {
      debugPrint('Error rendering TypingDot: $e');
      return const SizedBox.shrink();
    }
  }
}

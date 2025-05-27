import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF14B8A6); // Teal accent
  static const Color lightBlack = Color(
    0xFF1E1E1E,
  ); // Light black for dark mode
  static const Color darkGray = Color(0xFF333333);
  static const Color lightGray = Color(0xFFEEEEEE);
  static const Color telegramBlue = Color(
    0xFF0088CC,
  ); // User message bubble color
  static const Color themeLightIcon = Colors.amber;
  static const Color themeDarkIcon = Colors.blueGrey;
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);

  static Color getColor(Color color, {Color fallback = Colors.grey}) {
    try {
      return color;
    } catch (e) {
      debugPrint('Error accessing color: $e');
      return fallback;
    }
  }
}

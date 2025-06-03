import 'package:flutter/material.dart';

class ProgressLevel {
  final String label;
  final Color color;
  final double minProgress;
  final double maxProgress;

  const ProgressLevel({
    required this.label,
    required this.color,
    required this.minProgress,
    required this.maxProgress,
  });

  bool isInRange(double progress) => 
      progress >= minProgress && progress <= maxProgress;

  static ProgressLevel fromProgress(double progress) {
    // Ensure progress is between 0 and 1
    final clampedProgress = progress.clamp(0.0, 1.0);

    if (clampedProgress < 0.2) return beginner;
    if (clampedProgress < 0.4) return elementary;
    if (clampedProgress < 0.6) return intermediate;
    if (clampedProgress < 0.8) return advanced;
    return expert;
  }

  // Predefined levels
  static const ProgressLevel beginner = ProgressLevel(
    label: 'Beginner',
    color: AppColors.beginner,
    minProgress: 0.0,
    maxProgress: 0.2,
  );

  static const ProgressLevel elementary = ProgressLevel(
    label: 'Elementary',
    color: AppColors.elementary,
    minProgress: 0.2,
    maxProgress: 0.4,
  );

  static const ProgressLevel intermediate = ProgressLevel(
    label: 'Intermediate',
    color: AppColors.intermediate,
    minProgress: 0.4,
    maxProgress: 0.6,
  );

  static const ProgressLevel advanced = ProgressLevel(
    label: 'Advanced',
    color: AppColors.advanced,
    minProgress: 0.6,
    maxProgress: 0.8,
  );

  static const ProgressLevel expert = ProgressLevel(
    label: 'Expert',
    color: AppColors.expert,
    minProgress: 0.8,
    maxProgress: 1.0,
  );
}

class AppColors {
  // Colors from first code (prioritized)
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

  // Colors from second code (non-conflicting)
  static const Color secondary = Color(0xFFFFC107);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color textLight = Color(0xFF000000);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);

  // Progress level colors
  static const Color beginner = Color(0xFFD32F2F);
  static const Color elementary = Color(0xFFFF9800);
  static const Color intermediate = Color(0xFFFFC107);
  static const Color advanced = Color(0xFF4CAF50);
  static const Color expert = Color(0xFF009688);

  // Skill-specific colors
  static const Color pronunciation = Color(0xFF9C27B0);
  static const Color vocabulary = Color(0xFF2196F3);
  static const Color grammar = Color(0xFF009688);
  static const Color fluency = Color(0xFFFF9800);
  static const Color comprehension = Color(0xFF4CAF50);
  static const Color confidence = Color(0xFFE91E63);

  static Color getColor(Color color, {Color fallback = Colors.grey}) {
    return color;
  }
}

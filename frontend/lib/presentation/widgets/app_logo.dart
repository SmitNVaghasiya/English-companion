import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 7),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.language,
              size: size * 0.5,
              color: AppColors.primaryColor,
            ),
            Positioned(
              bottom: size * 0.2,
              child: Text(
                'English Companion',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : const Color(0xFF1A2A44),
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.08,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

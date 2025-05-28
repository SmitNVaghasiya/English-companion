import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static const String fontFamily = 'Poppins';

  static ThemeData get lightTheme {
    try {
      return ThemeData(
        fontFamily: fontFamily,
        primarySwatch: MaterialColor(0xFF1A2A44, {
          50: Color(0xFFE6E9F0),
          100: Color(0xFFB0BACC),
          200: Color(0xFF7A8BA8),
          300: Color(0xFF445C84),
          400: Color(0xFF2E466A),
          500: Color(0xFF1A2A44),
          600: Color(0xFF17253E),
          700: Color(0xFF131F34),
          800: Color(0xFF0F192A),
          900: Color(0xFF0A121F),
        }),
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFF5F7FA),
          titleTextStyle: TextStyle(
            fontFamily: fontFamily,
            color: Color(0xFF1A2A44),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1A2A44)),
          elevation: 0,
        ),
        textTheme: _buildTextTheme(
          primaryColor: Color(0xFF1A2A44),
          secondaryColor: Color(0xFF64748B),
          tertiaryColor: Color(0xFF94A3B8),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: Colors.black12,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: TextStyle(
            fontFamily: fontFamily,
            color: Color(0xFF64748B),
          ),
          hintStyle: TextStyle(
            fontFamily: fontFamily,
            color: Color(0xFFB0BACC),
          ),
          prefixIconColor: Color(0xFF64748B),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: AppColors.primaryColor,
          textTheme: ButtonTextTheme.primary,
        ),
      );
    } catch (e) {
      debugPrint('Error initializing light theme: $e');
      return ThemeData.light();
    }
  }

  static ThemeData get darkTheme {
    try {
      return ThemeData(
        brightness: Brightness.dark,
        fontFamily: fontFamily,
        primarySwatch: MaterialColor(AppColors.primaryColor.value, {
          50: Color(0xFFE0F2F1),
          100: Color(0xFFB2DFDB),
          200: Color(0xFF80CBC4),
          300: Color(0xFF4DB6AC),
          400: Color(0xFF26A69A),
          500: AppColors.primaryColor,
          600: Color(0xFF009688),
          700: Color(0xFF00897B),
          800: Color(0xFF00796B),
          900: Color(0xFF00695C),
        }),
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightBlack,
          titleTextStyle: TextStyle(
            fontFamily: fontFamily,
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        textTheme: _buildTextTheme(
          primaryColor: Colors.white,
          secondaryColor: Colors.white70,
          tertiaryColor: Colors.white60,
        ),
        cardTheme: CardTheme(
          color: AppColors.lightBlack,
          shadowColor: Colors.black26,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: AppColors.lightBlack,
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2D2D2D), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2D2D2D), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: TextStyle(color: Colors.grey[400]),
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIconColor: Color(0xFFB0BACC),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: AppColors.primaryColor,
          textTheme: ButtonTextTheme.primary,
        ),
      );
    } catch (e) {
      debugPrint('Error initializing dark theme: $e');
      return ThemeData.dark();
    }
  }

  static TextTheme _buildTextTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Color tertiaryColor,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 57.0,
        height: 1.12,
        letterSpacing: -0.25,
        color: primaryColor,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 45.0,
        height: 1.15,
        color: primaryColor,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 36.0,
        height: 1.22,
        color: primaryColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 32.0,
        height: 1.25,
        color: primaryColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 28.0,
        height: 1.28,
        color: primaryColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 24.0,
        height: 1.33,
        color: primaryColor,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 22.0,
        height: 1.27,
        color: primaryColor,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 18.0,
        height: 1.33,
        color: primaryColor,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
        height: 1.5,
        color: primaryColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        color: primaryColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        color: secondaryColor,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        color: tertiaryColor,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: primaryColor,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: primaryColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: secondaryColor,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
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
          color: Color(0xFF1A2A44),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1A2A44)),
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF1A2A44)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.black12,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        labelStyle: TextStyle(color: Color(0xFF64748B)),
        hintStyle: TextStyle(color: Color(0xFFB0BACC)),
        prefixIconColor: Color(0xFF64748B),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
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
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[300]),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB0BACC)),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightBlack,
        shadowColor: Colors.black26,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  }
}

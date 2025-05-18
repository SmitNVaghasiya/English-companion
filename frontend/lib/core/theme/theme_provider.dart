import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'app_theme_mode.dart';

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  ThemeProvider() {
    _loadThemePreference();
  }

  AppThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;
  ThemeMode get currentThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? AppThemeMode.system.index;
    _themeMode = AppThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> _saveThemePreference(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == AppThemeMode.light
            ? AppThemeMode.dark
            : AppThemeMode.light;
    _saveThemePreference(_themeMode);
    notifyListeners();
  }
}

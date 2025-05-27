import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'app_theme_mode.dart';

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _isInitialized = false;

  ThemeProvider() {
    _initialize();
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
        return ThemeMode.system;
    }
  }

  Future<void> _initialize() async {
    try {
      if (_isInitialized) return;
      await _loadThemePreference();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing ThemeProvider: $e');
      _themeMode = AppThemeMode.system;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('themeMode') ?? AppThemeMode.system.index;
      _themeMode = AppThemeMode.values[themeIndex];
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      _themeMode = AppThemeMode.system;
      notifyListeners();
    }
  }

  Future<void> _saveThemePreference(AppThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', mode.index);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  void toggleTheme() {
    try {
      if (_themeMode == AppThemeMode.system) {
        // If in system mode, toggle to the opposite of the current system theme
        final isSystemDark =
            WidgetsBinding.instance.window.platformBrightness ==
            Brightness.dark;
        _themeMode = isSystemDark ? AppThemeMode.light : AppThemeMode.dark;
      } else {
        _themeMode =
            _themeMode == AppThemeMode.light
                ? AppThemeMode.dark
                : AppThemeMode.light;
      }
      _saveThemePreference(_themeMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling theme: $e');
    }
  }
}

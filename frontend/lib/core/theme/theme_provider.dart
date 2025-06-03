import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'app_theme_mode.dart';

/// Enhanced theme provider with improved state management and performance
class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'app_theme_mode';

  AppThemeMode _themeMode = AppThemeMode.system;
  bool _isInitialized = false;
  SharedPreferences? _prefs;

  // Cache for better performance
  late final ValueNotifier<bool> _isDarkModeNotifier;

  ThemeProvider() {
    _isDarkModeNotifier = ValueNotifier<bool>(_getEffectiveIsDark());
    _initialize();
  }

  /// Current theme mode
  AppThemeMode get themeMode => _themeMode;

  /// Light theme data
  ThemeData get lightTheme => AppTheme.lightTheme;

  /// Dark theme data
  ThemeData get darkTheme => AppTheme.darkTheme;

  /// Current effective theme mode for MaterialApp
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

  /// Whether the current effective theme is dark
  bool get isDarkMode => _getEffectiveIsDark();

  /// Value notifier for dark mode changes (for performance-critical widgets)
  ValueListenable<bool> get isDarkModeListenable => _isDarkModeNotifier;

  /// Whether the provider is fully initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the theme provider
  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadThemePreference();
      _isInitialized = true;

      // Listen to system theme changes
      _setupSystemThemeListener();

      debugPrint(
        'ThemeProvider: Initialized successfully with mode: $_themeMode',
      );
    } catch (e) {
      debugPrint('ThemeProvider: Error during initialization: $e');
      _handleInitializationError();
    }
  }

  /// Handle initialization errors gracefully
  void _handleInitializationError() {
    _themeMode = AppThemeMode.system;
    _isInitialized = true;
    _updateDarkModeNotifier();
    notifyListeners();
  }

  /// Load theme preference from storage
  Future<void> _loadThemePreference() async {
    try {
      final themeIndex =
          _prefs?.getInt(_themePreferenceKey) ?? AppThemeMode.system.index;

      // Validate the loaded index
      if (themeIndex >= 0 && themeIndex < AppThemeMode.values.length) {
        _themeMode = AppThemeMode.values[themeIndex];
      } else {
        _themeMode = AppThemeMode.system;
      }

      _updateDarkModeNotifier();
      notifyListeners();

      debugPrint('ThemeProvider: Loaded theme preference: $_themeMode');
    } catch (e) {
      debugPrint('ThemeProvider: Error loading theme preference: $e');
      _themeMode = AppThemeMode.system;
      _updateDarkModeNotifier();
      notifyListeners();
    }
  }

  /// Save theme preference to storage
  Future<void> _saveThemePreference(AppThemeMode mode) async {
    try {
      await _prefs?.setInt(_themePreferenceKey, mode.index);
      debugPrint('ThemeProvider: Saved theme preference: $mode');
    } catch (e) {
      debugPrint('ThemeProvider: Error saving theme preference: $e');
    }
  }

  /// Set up system theme change listener
  void _setupSystemThemeListener() {
    try {
      SchedulerBinding
          .instance
          .platformDispatcher
          .onPlatformBrightnessChanged = () {
        if (_themeMode == AppThemeMode.system) {
          _updateDarkModeNotifier();
          notifyListeners();
        }
      };
    } catch (e) {
      debugPrint('ThemeProvider: Error setting up system theme listener: $e');
    }
  }

  /// Get effective dark mode state
  bool _getEffectiveIsDark() {
    switch (_themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return SchedulerBinding
                .instance
                .platformDispatcher
                .platformBrightness ==
            Brightness.dark;
    }
  }

  /// Update the dark mode notifier
  void _updateDarkModeNotifier() {
    final newValue = _getEffectiveIsDark();
    if (_isDarkModeNotifier.value != newValue) {
      _isDarkModeNotifier.value = newValue;
    }
  }

  /// Toggle between light and dark themes
  void toggleTheme() {
    try {
      final newMode = _getNextThemeMode();
      setThemeMode(newMode);

      debugPrint('ThemeProvider: Toggled theme to: $newMode');
    } catch (e) {
      debugPrint('ThemeProvider: Error toggling theme: $e');
    }
  }

  /// Get the next theme mode in the toggle sequence
  AppThemeMode _getNextThemeMode() {
    switch (_themeMode) {
      case AppThemeMode.system:
        // Toggle to the opposite of current system theme
        final isSystemDark =
            SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
        return isSystemDark ? AppThemeMode.light : AppThemeMode.dark;
      case AppThemeMode.light:
        return AppThemeMode.dark;
      case AppThemeMode.dark:
        return AppThemeMode.light;
    }
  }

  /// Set specific theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;

    try {
      _themeMode = mode;
      _updateDarkModeNotifier();
      await _saveThemePreference(mode);
      notifyListeners();

      debugPrint('ThemeProvider: Set theme mode to: $mode');
    } catch (e) {
      debugPrint('ThemeProvider: Error setting theme mode: $e');
    }
  }

  /// Reset to system theme
  Future<void> resetToSystemTheme() async {
    await setThemeMode(AppThemeMode.system);
  }

  /// Get theme mode display name
  String getThemeModeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  /// Get current theme mode display name
  String get currentThemeModeDisplayName => getThemeModeDisplayName(_themeMode);

  /// Get theme icon for current mode
  IconData get currentThemeIcon {
    switch (_themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode_outlined;
      case AppThemeMode.dark:
        return Icons.dark_mode_outlined;
      case AppThemeMode.system:
        return isDarkMode
            ? Icons.dark_mode_outlined
            : Icons.light_mode_outlined;
    }
  }

  /// Get appropriate theme toggle icon
  IconData get toggleIcon {
    return isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined;
  }

  /// Get toggle tooltip text
  String get toggleTooltip {
    return isDarkMode ? 'Switch to light mode' : 'Switch to dark mode';
  }

  /// Force refresh theme (useful for debugging or edge cases)
  void refreshTheme() {
    try {
      _updateDarkModeNotifier();
      notifyListeners();
      debugPrint('ThemeProvider: Theme refreshed');
    } catch (e) {
      debugPrint('ThemeProvider: Error refreshing theme: $e');
    }
  }

  /// Get system UI overlay style for current theme
  SystemUiOverlayStyle get systemUiOverlayStyle {
    return AppTheme.getSystemUiOverlayStyle(isDarkMode);
  }

  @override
  void dispose() {
    try {
      _isDarkModeNotifier.dispose();
      // Clear system theme listener
      SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
          null;
    } catch (e) {
      debugPrint('ThemeProvider: Error during disposal: $e');
    }
    super.dispose();
  }

  /// Create a copy of the provider for testing
  @visibleForTesting
  ThemeProvider.test({
    required AppThemeMode initialMode,
    SharedPreferences? preferences,
  }) : _prefs = preferences {
    _themeMode = initialMode;
    _isDarkModeNotifier = ValueNotifier<bool>(_getEffectiveIsDark());
    _isInitialized = true;
  }
}

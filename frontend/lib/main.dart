import 'package:english_companion/presentation/screens/notification_settings_screen.dart';
import 'package:english_companion/presentation/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/progress_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/chat_screen.dart';
import 'presentation/screens/grammar_screen.dart';
import 'presentation/screens/progress_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await EnvConfig.initialize();
    debugPrint('Environment variables loaded successfully');
    debugPrint('BACKEND_URL: ${EnvConfig.backendUrl}');

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProgressProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('Error in main: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        try {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'English Companion',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.currentThemeMode,
            initialRoute: '/home',
            routes: {
              '/home': (context) => const HomeScreen(),
              '/chat': (context) => const ChatScreen(),
              '/learn': (context) => const GrammarScreen(),
              '/practice':
                  (context) => const ChatScreen(initialVoiceMode: true),
              '/progress': (context) => const ProgressScreen(),
              '/notifications': (context) => const NotificationsScreen(),
              '/notification-settings':
                  (context) => const NotificationSettingsScreen(),
              '/profile': (context) => const HomeScreen(),
              '/settings': (context) => const HomeScreen(),
              '/help': (context) => const HomeScreen(),
            },
          );
        } catch (e) {
          debugPrint('Error building MyApp: $e');
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('An error occurred. Please restart the app.'),
              ),
            ),
          );
        }
      },
    );
  }
}

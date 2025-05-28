import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/screens/home_screen.dart';

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
            home: const HomeScreen(),
            routes: {'/home': (context) => const HomeScreen()},
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

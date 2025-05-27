import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        try {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: MaterialApp(
              key: ValueKey(themeProvider.currentThemeMode),
              title: 'English Companion',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.currentThemeMode,
              home: const HomeScreen(),
            ),
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

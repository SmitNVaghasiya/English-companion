import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:english_companion/main.dart';
import 'package:english_companion/presentation/screens/chat_screen.dart';
import 'package:english_companion/core/theme/theme_provider.dart';
import 'package:english_companion/presentation/providers/chat_provider.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the chat screen is loaded
    expect(find.byType(ChatScreen), findsOneWidget);
  });
}

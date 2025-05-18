import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  static String? get backendUrl => dotenv.env['BACKEND_URL']?.trim();
}

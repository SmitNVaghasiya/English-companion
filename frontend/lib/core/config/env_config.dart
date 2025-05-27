import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('EnvConfig: Failed to load .env file: $e');
    }
  }

  static String? get backendUrl => dotenv.env['BACKEND_URL']?.trim();
}

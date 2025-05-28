import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('EnvConfig: Successfully loaded .env file');
    } catch (e) {
      debugPrint('EnvConfig: Failed to load .env file: $e');
      throw Exception('Failed to load environment configuration');
    }
  }

  static String? get backendUrl => dotenv.env['BACKEND_URL']?.trim();
}

import 'package:flutter/foundation.dart';

class MessageModel {
  final String role;
  final String content;
  final DateTime timestamp;

  MessageModel({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    try {
      final role = map['role'] as String? ?? 'assistant';
      final content = map['content'] as String? ?? '';
      final timestamp =
          map['timestamp'] is DateTime
              ? map['timestamp'] as DateTime
              : DateTime.tryParse(map['timestamp']?.toString() ?? '') ??
                  DateTime.now();

      return MessageModel(role: role, content: content, timestamp: timestamp);
    } catch (e) {
      debugPrint('Error parsing MessageModel: $e');
      return MessageModel(
        role: 'system',
        content: 'Failed to parse message.',
        timestamp: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toMap() {
    try {
      return {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error converting MessageModel to map: $e');
      return {};
    }
  }
}

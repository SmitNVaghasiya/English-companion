import 'package:flutter/foundation.dart';

class ChatResponse {
  final String status;
  final String role;
  final String content;
  final DateTime timestamp;

  ChatResponse({
    required this.status,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatResponse.fromMap(Map<String, dynamic> map) {
    try {
      final status = map['status'] as String? ?? 'error';
      final role = map['role'] as String? ?? 'assistant';
      final content = map['content'] as String? ?? '';
      final timestampStr = map['timestamp']?.toString();
      final timestamp = DateTime.tryParse(timestampStr ?? '') ?? DateTime.now();

      return ChatResponse(
        status: status,
        role: role,
        content: content,
        timestamp: timestamp,
      );
    } catch (e) {
      debugPrint('Error parsing ChatResponse: $e');
      return ChatResponse(
        status: 'error',
        role: 'system',
        content: 'Failed to parse response.',
        timestamp: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toMap() {
    try {
      return {
        'status': status,
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error converting ChatResponse to map: $e');
      return {};
    }
  }
}

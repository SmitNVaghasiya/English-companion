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
    return MessageModel(
      role: map['role'] as String? ?? 'assistant',
      content: map['content'] as String? ?? '',
      timestamp:
          map['timestamp'] is DateTime
              ? map['timestamp'] as DateTime
              : DateTime.tryParse(map['timestamp']?.toString() ?? '') ??
                  DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

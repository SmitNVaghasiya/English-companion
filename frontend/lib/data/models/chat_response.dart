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
    return ChatResponse(
      status: map['status'] as String? ?? 'error',
      role: map['role'] as String? ?? 'assistant',
      content: map['content'] as String? ?? '',
      timestamp:
          DateTime.tryParse(map['timestamp']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

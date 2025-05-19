import 'package:english_companion/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/message_model.dart';
import '../../data/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isConnecting = false;
  bool _isVoiceMode = false;
  String _connectionStatus = '';
  String? _connectionMessage;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isConnecting => _isConnecting;
  bool get isVoiceMode => _isVoiceMode;
  String get connectionStatus => _connectionStatus;
  String? get connectionMessage => _connectionMessage;

  void addMessage(MessageModel message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  Future<MessageModel?> sendQuery(MessageModel message) async {
    try {
      _isLoading = true;
      _isConnecting = true;
      notifyListeners();

      final messages = [
        {'role': message.role, 'content': message.content},
      ];

      final response = await _chatService.sendQuery(messages);

      _connectionStatus = 'Connected';
      _connectionMessage = 'Server is responding';

      return MessageModel(
        content: response.content,
        role: response.role,
        timestamp: response.timestamp,
      );
    } catch (e) {
      debugPrint('Error in sendQuery: $e');
      _connectionStatus = 'Connection failed';
      _connectionMessage = 'Error: ${e.toString()}';

      return MessageModel(
        content: 'Sorry, something went wrong. Please try again.',
        role: 'system',
        timestamp: DateTime.now(),
      );
    } finally {
      _isLoading = false;
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<MessageModel?> startVoiceChat() async {
    try {
      _isLoading = true;
      _isVoiceMode = true;
      notifyListeners();

      final response = await _chatService.sendVoiceQuery();

      _connectionStatus = 'Connected';
      _connectionMessage = 'Server is responding';

      return MessageModel(
        content: response.content,
        role: response.role,
        timestamp: response.timestamp,
      );
    } catch (e) {
      debugPrint('Error in startVoiceChat: $e');
      _connectionStatus = 'Connection failed';
      _connectionMessage = 'Error: ${e.toString()}';

      return MessageModel(
        content: 'Failed to process voice request. Please try again.',
        role: 'system',
        timestamp: DateTime.now(),
      );
    } finally {
      _isLoading = false;
      _isVoiceMode = false;
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setVoiceMode(bool voiceMode) {
    if (_isVoiceMode != voiceMode) {
      _isVoiceMode = voiceMode;
      notifyListeners();
    }
  }

  Future<void> testConnection() async {
    if (_isConnecting) return;

    _isConnecting = true;
    _connectionStatus = 'Connecting...';
    _connectionMessage = 'Checking server availability';
    notifyListeners();

    try {
      final result = await _chatService.testConnection();
      if (result['connected'] == true) {
        _connectionStatus = 'Connected';
        _connectionMessage = result['message'] ?? 'Server is responding';
      } else {
        _connectionStatus = 'Connection failed';
        _connectionMessage =
            result['message'] ?? 'Could not connect to the server';
      }
    } catch (e) {
      debugPrint('Connection test failed: $e');
      _connectionStatus = 'Connection failed';
      _connectionMessage = 'Error checking connection: ${e.toString()}';
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void clearConnectionStatus() {
    if (_connectionStatus != 'Connected') {
      _connectionStatus = 'Connecting...';
      _connectionMessage = 'Checking connection...';
      _isConnecting = true;
      notifyListeners();

      testConnection();
    } else {
      notifyListeners();
    }
  }

  void toggleTheme(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
  }
}

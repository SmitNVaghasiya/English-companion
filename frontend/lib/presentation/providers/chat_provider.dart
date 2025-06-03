import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/chat_utils.dart';
import '../../data/models/message_model.dart';
import '../../data/services/chat_service.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_strings.dart';

enum VoiceStatus { idle, recording, processing, speaking, error }

enum ConversationMode {
  formal,
  informal,
  dailyLife,
  custom,
  beginnersHelper,
  professionalConversation,
  everydaySituations,
}

class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isConnecting;
  final bool isVoiceMode;
  final bool isMuted;
  final String connectionStatus;
  final String? connectionMessage;
  final VoiceStatus voiceStatus;
  final String? voiceStatusMessage;
  final ConversationMode? conversationMode;

  ChatState({
    required this.messages,
    required this.isLoading,
    required this.isConnecting,
    required this.isVoiceMode,
    required this.isMuted,
    required this.connectionStatus,
    required this.connectionMessage,
    required this.voiceStatus,
    required this.voiceStatusMessage,
    this.conversationMode,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isConnecting,
    bool? isVoiceMode,
    bool? isMuted,
    String? connectionStatus,
    String? connectionMessage,
    VoiceStatus? voiceStatus,
    String? voiceStatusMessage,
    ConversationMode? conversationMode,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isConnecting: isConnecting ?? this.isConnecting,
      isVoiceMode: isVoiceMode ?? this.isVoiceMode,
      isMuted: isMuted ?? this.isMuted,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      connectionMessage: connectionMessage ?? this.connectionMessage,
      voiceStatus: voiceStatus ?? this.voiceStatus,
      voiceStatusMessage: voiceStatusMessage ?? this.voiceStatusMessage,
      conversationMode: conversationMode ?? this.conversationMode,
    );
  }
}

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  ChatState _state = ChatState(
    messages: [],
    isLoading: false,
    isConnecting: false,
    isVoiceMode: false,
    isMuted: false,
    connectionStatus: AppStrings.connecting,
    connectionMessage: null,
    voiceStatus: VoiceStatus.idle,
    voiceStatusMessage: null,
    conversationMode: null,
  );

  ChatState get state => _state;

  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 2);
  static const Duration _requestTimeout = Duration(seconds: 20);
  static const String _messagesKey = 'chat_messages';

  ChatProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    try {
      await _clearMessagesOnStart();
      _setConnectionStatus(
        null,
        AppStrings.connecting,
        'Initializing...',
        false,
      );
    } catch (e) {
      debugPrint('ChatProvider: Error initializing: $e');
      _setConnectionStatus(
        null,
        AppStrings.connectionFailed,
        'Initialization failed: $e',
        true,
      );
    }
  }

  Future<void> _clearMessagesOnStart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_messagesKey);
      _state = _state.copyWith(messages: []);
      notifyListeners();
    } catch (e) {
      debugPrint('ChatProvider: Error clearing messages: $e');
    }
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(
        _state.messages.map((m) => m.toMap()).toList(),
      );
      await prefs.setString(_messagesKey, messagesJson);
    } catch (e) {
      debugPrint('ChatProvider: Error saving messages: $e');
    }
  }

  void setConversationMode(ConversationMode mode) {
    _state = _state.copyWith(conversationMode: mode);
    _updateInitialMessageForMode(mode);
    notifyListeners();
  }

  void _updateInitialMessageForMode(ConversationMode mode) {
    String initialMessage;
    switch (mode) {
      case ConversationMode.formal:
        initialMessage =
            "Greetings! I am your English Companion for formal conversations. How may I assist you in a professional setting today?";
        break;
      case ConversationMode.informal:
        initialMessage =
            "Hey there! I'm your English Companion for casual chats. What's up? Let's talk like friends!";
        break;
      case ConversationMode.dailyLife:
        initialMessage = AppStrings.dailyLifeGreeting;
        break;
      case ConversationMode.custom:
        initialMessage =
            "Hi! I'm ready to talk about any topic you choose. What would you like to discuss today?";
        break;
      case ConversationMode.beginnersHelper:
        initialMessage = AppStrings.beginnersHelperGreeting;
        break;
      case ConversationMode.professionalConversation:
        initialMessage = AppStrings.professionalConversationGreeting;
        break;
      case ConversationMode.everydaySituations:
        initialMessage = AppStrings.everydaySituationsGreeting;
        break;
    }
    final greetingMessage = MessageModel(
      role: 'assistant',
      content: initialMessage,
      timestamp: DateTime.now(),
    );
    addMessage(greetingMessage);
  }

  void addMessage(MessageModel message) {
    try {
      if (!_state.messages.any(
        (msg) =>
            msg.content == message.content &&
            msg.role == message.role &&
            msg.timestamp == message.timestamp,
      )) {
        _state = _state.copyWith(messages: [..._state.messages, message]);
        _saveMessages();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ChatProvider: Error adding message: $e');
    }
  }

  void clearMessages() {
    try {
      _state = _state.copyWith(messages: []);
      _saveMessages();
      notifyListeners();
    } catch (e) {
      debugPrint('ChatProvider: Error clearing messages: $e');
    }
  }

  void _setConnectionStatus(
    BuildContext? context,
    String status,
    String? message,
    bool isError,
  ) {
    try {
      _state = _state.copyWith(
        connectionStatus: status,
        connectionMessage: message,
      );
      if (isError && context != null) {
        ChatUtils.showSnackBar(
          context,
          message ?? 'Connection error',
          isError: true,
          onRetry: () => testConnection(context),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('ChatProvider: Error setting connection status: $e');
    }
  }

  void toggleMute() {
    try {
      _state = _state.copyWith(isMuted: !_state.isMuted);
      debugPrint(
        'ChatProvider: Mute state toggled: isMuted = ${_state.isMuted}',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('ChatProvider: Error toggling mute: $e');
    }
  }

  Future<MessageModel?> _processQueryWithoutDuplicates(
    MessageModel message,
  ) async {
    try {
      final messages = _state.messages.map((msg) => msg.toMap()).toList();
      messages.add({
        'role': message.role,
        'content': message.content,
        'timestamp': message.timestamp.toIso8601String(),
      });

      for (int attempt = 1; attempt <= _maxRetries; attempt++) {
        try {
          final result = await _chatService
              .sendQuery(messages)
              .timeout(
                _requestTimeout,
                onTimeout: () => throw Exception('Request timed out'),
              );

          if (result.isSuccess && result.value != null) {
            _setConnectionStatus(
              null,
              AppStrings.connected,
              'Server is responding',
              false,
            );
            final response = result.value!;
            final responseMessage = MessageModel(
              content: response.content,
              role: response.role,
              timestamp: DateTime.parse(response.timestamp),
            );
            addMessage(responseMessage);
            return responseMessage;
          } else {
            final errorMessage =
                result.error?.message ?? 'Unknown error occurred';
            throw Exception(errorMessage);
          }
        } catch (e) {
          if (attempt == _maxRetries) {
            final errorMessage = _handleError(e);
            _setConnectionStatus(
              null,
              AppStrings.connectionFailed,
              errorMessage,
              true,
            );
            final errorMsg = MessageModel(
              content: errorMessage,
              role: 'system',
              timestamp: DateTime.now(),
            );
            addMessage(errorMsg);
            return errorMsg;
          }
          await Future.delayed(_initialRetryDelay * attempt);
        }
      }
    } finally {
      _state = _state.copyWith(isLoading: false, isConnecting: false);
      notifyListeners();
    }
    return null;
  }

  Future<MessageModel?> sendQuery(MessageModel message) async {
    if (_state.isLoading) return null;
    _state = _state.copyWith(isLoading: true, isConnecting: true);
    notifyListeners();

    try {
      return await _processQueryWithoutDuplicates(message);
    } catch (e) {
      debugPrint('ChatProvider: Error sending query: $e');
      return null;
    }
  }

  void _updateVoiceStatus(VoiceStatus status, {String? message}) {
    _state = _state.copyWith(voiceStatus: status, voiceStatusMessage: message);
    debugPrint('ChatProvider: Voice status updated: $status - $message');
    notifyListeners();
  }

  void _handleRecordingError(String error, {BuildContext? context}) {
    debugPrint('ChatProvider: Recording error: $error');
    _updateVoiceStatus(
      VoiceStatus.error,
      message: 'Unable to record audio. Please check microphone permissions.',
    );
  }

  Future<void> toggleVoiceRecording(BuildContext context) async {
    final currentContext = context;

    if (_state.isLoading) {
      debugPrint(
        'ChatProvider: Toggle voice recording ignored: Operation in progress',
      );
      return;
    }

    try {
      _state = _state.copyWith(isLoading: true);
      notifyListeners();

      if (_chatService.isRecording) {
        debugPrint('ChatProvider: Stopping voice recording...');
        _updateVoiceStatus(
          VoiceStatus.processing,
          message: 'Processing your message...',
        );

        final chatHistory =
            _state.messages
                .map((msg) => {'role': msg.role, 'content': msg.content})
                .toList();

        final result = await _chatService.stopVoiceRecording(chatHistory);
        _state = _state.copyWith(isLoading: false);
        notifyListeners();

        if (result.isSuccess) {
          final voiceResponse = result.value!;
          debugPrint('ChatProvider: Voice recording processed successfully');

          if (voiceResponse.transcribedText.isNotEmpty) {
            final userMessage = MessageModel(
              content: voiceResponse.transcribedText,
              role: 'user',
              timestamp: DateTime.now().subtract(const Duration(seconds: 1)),
            );
            debugPrint(
              'ChatProvider: Adding transcribed user message to UI: ${userMessage.content}',
            );
            addMessage(userMessage);
          } else {
            debugPrint(
              'ChatProvider: No transcribed text received from server',
            );
            if (currentContext.mounted) {
              ChatUtils.showSnackBar(
                currentContext,
                'Could not understand audio. Please speak clearly and try again.',
                isError: true,
              );
            }
            _updateVoiceStatus(VoiceStatus.idle);
            return;
          }

          await Future.delayed(const Duration(milliseconds: 100));
          if (voiceResponse.content.isNotEmpty) {
            final responseMessage = MessageModel(
              content: voiceResponse.content,
              role: voiceResponse.role,
              timestamp:
                  DateTime.tryParse(voiceResponse.timestamp) ?? DateTime.now(),
            );
            debugPrint(
              'ChatProvider: Adding assistant response to UI: ${responseMessage.content}',
            );
            addMessage(responseMessage);

            if (_state.isVoiceMode && !_state.isMuted) {
              _updateVoiceStatus(
                VoiceStatus.speaking,
                message: 'System is speaking...',
              );
              debugPrint(
                'ChatProvider: Speaking server response: ${responseMessage.content}',
              );
              await Future.delayed(const Duration(milliseconds: 300));
              final success = await _chatService.speak(responseMessage.content);
              if (!success) {
                _updateVoiceStatus(
                  VoiceStatus.error,
                  message: 'Failed to play response audio',
                );
              } else {
                _updateVoiceStatus(VoiceStatus.idle);
              }
            } else {
              _updateVoiceStatus(VoiceStatus.idle);
            }
          } else {
            debugPrint('ChatProvider: No content received in server response');
            _updateVoiceStatus(VoiceStatus.idle);
          }
        } else {
          final errorMessage =
              result.error?.message ?? 'Could not process audio';
          debugPrint(
            'ChatProvider: Error in voice recording result: $errorMessage',
          );
          final errorMsg = _handleError(Exception(errorMessage));

          if (currentContext.mounted) {
            ChatUtils.showSnackBar(currentContext, errorMsg, isError: true);
          }

          final systemMsg = MessageModel(
            content: errorMsg,
            role: 'system',
            timestamp: DateTime.now(),
          );
          addMessage(systemMsg);

          if (_state.isVoiceMode && !_state.isMuted) {
            _updateVoiceStatus(
              VoiceStatus.error,
              message: 'Error processing audio',
            );
            debugPrint('ChatProvider: Speaking error message: $errorMessage');
            await Future.delayed(const Duration(milliseconds: 300));
            await _chatService.speak(errorMessage);
          } else {
            _updateVoiceStatus(VoiceStatus.idle);
          }
        }
      } else {
        debugPrint('ChatProvider: Starting voice recording...');
        _updateVoiceStatus(VoiceStatus.recording, message: 'Listening...');

        try {
          final startResult = await _chatService.startVoiceRecording();

          if (startResult.isSuccess) {
            debugPrint('ChatProvider: Start recording successful');
            _state = _state.copyWith(isLoading: false);
            _updateVoiceStatus(VoiceStatus.recording, message: 'Listening...');
            notifyListeners();

            if (currentContext.mounted) {
              ChatUtils.showSnackBar(
                currentContext,
                'Recording started. Tap mic again when finished speaking.',
                isError: false,
              );
            }
          } else {
            throw Exception(
              startResult.error?.message ?? 'Failed to start recording',
            );
          }
        } catch (e) {
          debugPrint('ChatProvider: Failed to start recording: $e');
          if (currentContext.mounted) {
            _handleRecordingError(
              'Failed to start recording: $e',
              context: currentContext,
            );
          } else {
            _handleRecordingError('Failed to start recording: $e');
          }
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('ChatProvider: Error in toggleVoiceRecording: $e');
      final errorMessage = _handleError(e);
      if (currentContext.mounted) {
        ChatUtils.showSnackBar(currentContext, errorMessage, isError: true);
      }

      if (_state.isVoiceMode && !_chatService.isRecording) {
        debugPrint(
          'ChatProvider: Attempting to recover from failed recording state',
        );
        _updateVoiceStatus(VoiceStatus.idle);
      } else {
        _updateVoiceStatus(
          VoiceStatus.error,
          message: 'Error: ${e.toString()}',
        );
      }
    } finally {
      if (_state.isLoading) {
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
      }
    }
  }

  String _handleError(Object e) {
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('permission')) {
      return AppStrings.permissionDenied;
    } else if (errorStr.contains('timed out') || errorStr.contains('timeout')) {
      return AppStrings.serverNotResponding;
    } else if (errorStr.contains('network') ||
        errorStr.contains('socket') ||
        errorStr.contains('connection')) {
      return AppStrings.networkError;
    } else if (errorStr.contains('could not understand audio')) {
      return 'Could not understand the audio. Please speak clearly and try again.';
    } else {
      return 'Sorry, something went wrong. Please try again. ${e.toString().split(':').last.trim()}';
    }
  }

  Future<void> testConnection(BuildContext context) async {
    if (_state.isConnecting) return;
    _state = _state.copyWith(isConnecting: true);
    notifyListeners();

    try {
      if (!context.mounted) return;

      await ChatUtils.testConnectionAndUpdateStatus(
        chatService: _chatService,
        context: context,
        onUpdate: (status, message, isError) {
          if (context.mounted) {
            _setConnectionStatus(context, status, message, isError);
          }
        },
        onRetry: () {
          if (context.mounted) {
            testConnection(context);
          }
        },
      );
    } catch (e) {
      debugPrint('ChatProvider: Error testing connection: $e');
      if (context.mounted) {
        _setConnectionStatus(
          context,
          'Error',
          'Failed to test connection',
          true,
        );
      }
    } finally {
      _state = _state.copyWith(isConnecting: false);
      notifyListeners();
    }
  }

  void clearConnectionStatus(BuildContext context) {
    if (_state.connectionStatus != AppStrings.connected) {
      _setConnectionStatus(
        context,
        AppStrings.connecting,
        'Checking connection...',
        false,
      );
      testConnection(context);
    }
  }

  void toggleTheme(BuildContext context) {
    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      themeProvider.toggleTheme();
    } catch (e) {
      debugPrint('ChatProvider: Error toggling theme: $e');
    }
  }

  Future<void> stopAllAudio() async {
    try {
      await _chatService.stop();
      debugPrint('ChatProvider: Stopped all audio playback and recording');
    } catch (e) {
      debugPrint('ChatProvider: Error stopping audio: $e');
      rethrow;
    }
  }

  Future<bool> speak(String text) async {
    if (text.isEmpty) return false;

    try {
      _updateVoiceStatus(
        VoiceStatus.speaking,
        message: 'System is speaking...',
      );

      final success = await _chatService.speak(text);

      if (!success) {
        _updateVoiceStatus(VoiceStatus.error, message: 'Failed to play audio');
      } else {
        _updateVoiceStatus(VoiceStatus.idle);
      }

      return success;
    } catch (e) {
      debugPrint('ChatProvider: Error in speak: $e');
      _updateVoiceStatus(VoiceStatus.error, message: 'Error playing audio');
      return false;
    }
  }

  Future<void> toggleVoiceMode(BuildContext context) async {
    try {
      if (_chatService.isRecording) {
        await _chatService.stopVoiceRecording(
          _state.messages
              .map((msg) => {'role': msg.role, 'content': msg.content})
              .toList(),
        );
      }
      await stopAllAudio();

      _state = _state.copyWith(
        isVoiceMode: !_state.isVoiceMode,
        isMuted: !_state.isVoiceMode ? false : _state.isMuted,
      );

      if (_state.isVoiceMode) {
        clearMessages();

        Future.delayed(const Duration(milliseconds: 100), () {
          if (!_state.isVoiceMode) return;

          final greetingMessage = MessageModel(
            role: 'assistant',
            content: AppStrings.initialMessage,
            timestamp: DateTime.now(),
          );
          addMessage(greetingMessage);
          debugPrint(
            'ChatProvider: Triggering initial greeting: ${greetingMessage.content}',
          );
          if (!_state.isMuted) {
            speak(greetingMessage.content);
          }
        });
      }
      notifyListeners();
    } catch (e) {
      debugPrint('ChatProvider: Error toggling voice mode: $e');
      if (context.mounted) {
        ChatUtils.showSnackBar(
          context,
          'Error toggling voice mode: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  @override
  void dispose() {
    stopAllAudio().catchError((e) {
      debugPrint('Error in dispose: $e');
    });
    _chatService.dispose();
    super.dispose();
  }
}

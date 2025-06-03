import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/config/api_config.dart';
import 'dart:developer' as developer;

/// Service for handling chat operations, including text queries, voice recording,
/// text-to-speech, and server connectivity.
class ChatService {
  static const _defaultTimeout = Duration(seconds: 20);
  static const _recordingExtension = 'm4a';
  static const _audioResponseExtension = 'mp3';
  static const _minAudioSizeBytes = 100;

  final AudioRecorder _recorder = AudioRecorder();
  final FlutterTts _tts = FlutterTts();
  String? _baseUrl;
  bool _isRecording = false;
  String? _currentAudioPath;

  ChatService() {
    _initialize();
  }

  bool get isRecording => _isRecording;

  /// Initializes the service, setting up base URL and TTS.
  Future<void> _initialize() async {
    await _handleErrorAsync(() async {
      _baseUrl = await ApiConfig.baseUrl;
      await _initializeTts();
    }, 'initializing ChatService', rethrowError: true);
  }

  /// Configures TTS with default settings.
  Future<void> _initializeTts() async {
    await _handleErrorAsync(() async {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    }, 'initializing TTS', rethrowError: true);
  }

  /// Sends a text query to the server.
  Future<Result<ChatResponse>> sendQuery(List<Map<String, dynamic>> messages) async {
    if (_baseUrl == null) {
      return Result.error(ChatServiceException('Server connection not initialized'));
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.chatEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'messages': messages}),
      ).timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return Result.success(ChatResponse(
            role: data['role'] ?? 'assistant',
            content: data['content'] ?? '',
            timestamp: data['timestamp'] ?? DateTime.now().toIso8601String(),
          ));
        } catch (e) {
          return Result.error(ChatServiceException('Invalid response format from server'));
        }
      }
      return Result.error(ChatServiceException('Failed to send message: ${response.statusCode}'));
    } catch (e) {
      return Result.error(ChatServiceException('Network error: ${e.toString()}'));
    }
  }

  /// Tests server connectivity.
  Future<bool> testConnection() async {
    if (_baseUrl == null) {
      return false;
    }
    return _handleErrorAsync(
      () => ApiConfig.testConnectionWithUrl(_baseUrl!),
      'testing connection',
      defaultError: false,
    );
  }

  /// Starts voice recording.
  Future<Result<String>> startVoiceRecording() async {
    try {
      if (_isRecording) {
        return Result.error(ChatServiceException('Recording already in progress'));
      }

      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        return Result.error(ChatServiceException('Microphone permission denied'));
      }

      final dir = await getTemporaryDirectory();
      _currentAudioPath = '${dir.path}/recording.$_recordingExtension';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _currentAudioPath!,
      );
      _isRecording = true;
      return Result.success('Recording started');
    } catch (e) {
      return Result.error(ChatServiceException('Failed to start recording: ${e.toString()}'));
    }
  }

  /// Stops voice recording and sends it to the server.
  Future<Result<VoiceChatResponse>> stopVoiceRecording(List<Map<String, dynamic>> chatHistory) async {
    if (!_isRecording || _currentAudioPath == null) {
      return Result.error(ChatServiceException('No active recording session'));
    }
    if (_baseUrl == null) {
      return Result.error(ChatServiceException('Server connection not initialized'));
    }

    try {
      await _recorder.stop();
      _isRecording = false;

      final file = File(_currentAudioPath!);
      if (!await file.exists()) {
        return Result.error(ChatServiceException('Audio file not found'));
      }

      final fileSize = await file.length();
      if (fileSize < _minAudioSizeBytes) {
        return Result.error(ChatServiceException('Audio recording is too short or empty'));
      }

      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl${ApiConfig.voiceChatEndpoint}'));
      request.fields['history'] = jsonEncode(chatHistory);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send().timeout(_defaultTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      await _cleanupAudioFile(file);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Result.success(VoiceChatResponse(
          transcribedText: data['transcribed_text'] ?? '',
          content: data['content'] ?? '',
          role: data['role'] ?? 'assistant',
          timestamp: data['timestamp'] ?? DateTime.now().toIso8601String(),
        ));
      }
      return Result.error(ChatServiceException('Failed to process voice recording: ${response.statusCode}'));
    } catch (e) {
      return Result.error(ChatServiceException('Error processing voice recording: ${e.toString()}'));
    } finally {
      _isRecording = false;
      _currentAudioPath = null;
    }
  }

  /// Speaks the given text using TTS.
  /// Returns `true` if speaking was successful, `false` otherwise.
  Future<bool> speak(String text) async {
    if (text.isEmpty) return false;
    final result = await _handleErrorAsync(
      () => _tts.speak(text),
      'text-to-speech',
      defaultError: 0, // 0 indicates failure in flutter_tts
    );
    return result == 1; // Convert flutter_tts result (1 = success) to bool
  }

  /// Stops all audio operations.
  Future<void> stop() async {
    await _handleErrorAsync(() async {
      await _tts.stop();
      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;
        if (_currentAudioPath != null) {
          await _cleanupAudioFile(File(_currentAudioPath!));
          _currentAudioPath = null;
        }
      }
    }, 'stopping audio');
  }

  /// Downloads an audio response from a URL.
  Future<Result<File>> getAudioResponse(String audioUrl) async {
    try {
      final response = await http.get(Uri.parse(audioUrl)).timeout(_defaultTimeout);
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/response_audio.$_audioResponseExtension');
        await file.writeAsBytes(response.bodyBytes);
        return Result.success(file);
      }
      return Result.error(ChatServiceException('Failed to get audio response: ${response.statusCode}'));
    } catch (e) {
      return Result.error(ChatServiceException('Network error: ${e.toString()}'));
    }
  }

  /// Cleans up resources.
  void dispose() {
    _handleError(() {
      _recorder.dispose();
      _tts.stop();
      _currentAudioPath = null;
      _isRecording = false;
    }, 'disposing ChatService');
  }

  /// Deletes temporary audio file if it exists.
  Future<void> _cleanupAudioFile(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Centralized error handling for synchronous operations.
  T _handleError<T>(
    T Function() operation,
    String operationName, {
    T? defaultError,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      developer.log(
        'Error $operationName: $e',
        name: 'ChatService',
        stackTrace: stackTrace,
      );
      return defaultError ?? (throw e);
    }
  }

  /// Centralized error handling for asynchronous operations.
  Future<T> _handleErrorAsync<T>(
    Future<T> Function() operation,
    String operationName, {
    T? defaultError,
    bool rethrowError = false,
    void Function()? onFinally,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      developer.log(
        'Error $operationName: $e',
        name: 'ChatService',
        stackTrace: stackTrace,
      );
      if (rethrowError) rethrow;
      return defaultError ?? (throw e);
    } finally {
      onFinally?.call();
    }
  }
}

/// Represents the result of a service operation.
class Result<T> {
  final T? value;
  final ChatServiceException? error;

  Result.success(this.value) : error = null;
  Result.error(this.error) : value = null;

  bool get isSuccess => error == null;
}

/// Exception for ChatService errors.
class ChatServiceException implements Exception {
  final String message;
  ChatServiceException(this.message);

  @override
  String toString() => message;
}

/// Response from a text chat query.
class ChatResponse {
  final String role;
  final String content;
  final String timestamp;

  ChatResponse({required this.role, required this.content, required this.timestamp});
}

/// Response from a voice chat query.
class VoiceChatResponse extends ChatResponse {
  final String transcribedText;

  VoiceChatResponse({
    required this.transcribedText,
    required super.content,
    required super.role,
    required super.timestamp,
  });
}
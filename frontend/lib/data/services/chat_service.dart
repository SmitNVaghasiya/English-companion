import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/config/api_config.dart';

class ChatService {
  String? _baseUrl;
  bool _isRecording = false;
  String? _currentSessionId;
  final AudioRecorder _recorder = AudioRecorder();
  final FlutterTts _tts = FlutterTts();
  String? _currentAudioPath;

  ChatService() {
    _initialize();
  }

  bool get isRecording => _isRecording;

  Future<void> _initialize() async {
    try {
      _baseUrl = await ApiConfig.baseUrl;
      await _initializeTts();
    } catch (e) {
      debugPrint('ChatService: Initialization failed: $e');
      _baseUrl = null;
      rethrow;
    }
  }

  Future<void> _initializeTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('ChatService: TTS initialization failed: $e');
      throw Exception('Failed to initialize TTS');
    }
  }

  Future<Map<String, dynamic>> sendQuery(
    List<Map<String, dynamic>> messages,
  ) async {
    if (_baseUrl == null) {
      debugPrint('ChatService: Base URL not initialized');
      return {
        'status': 'error',
        'content': 'Server connection not initialized. Please try again later.',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.chatEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'messages': messages}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'success',
          'role': data['role'] ?? 'assistant',
          'content': data['content'] ?? '',
          'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
        };
      } else {
        return {
          'status': 'error',
          'content': 'Failed to send message: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('ChatService: Error sending query: $e');
      return {'status': 'error', 'content': 'Network error: $e'};
    }
  }

  Future<bool> testConnection() async {
    try {
      if (_baseUrl == null) {
        debugPrint('ChatService: Base URL not initialized');
        return false;
      }
      final isConnected = await ApiConfig.testConnectionWithUrl(_baseUrl!);
      if (!isConnected) {
        debugPrint(
          'ChatService: Connection test failed: Could not connect to server at $_baseUrl',
        );
      }
      return isConnected;
    } catch (e) {
      debugPrint('ChatService: Connection test failed with error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> startVoiceRecording() async {
    try {
      if (_isRecording) {
        return {'status': 'error', 'message': 'Recording already in progress'};
      }

      final dir = await getTemporaryDirectory();
      _currentAudioPath = '${dir.path}/recording.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _currentAudioPath!,
      );
      _isRecording = true;
      return {'status': 'recording', 'message': 'Recording started'};
    } catch (e) {
      debugPrint('ChatService: Error starting voice recording: $e');
      return {
        'status': 'error',
        'message': 'Failed to start voice recording: $e',
      };
    }
  }

  Future<Map<String, dynamic>> stopVoiceRecording(
    List<Map<String, dynamic>> chatHistory,
  ) async {
    if (!_isRecording || _currentAudioPath == null) {
      debugPrint('ChatService: No active recording session');
      return {'status': 'error', 'message': 'No active recording session'};
    }

    if (_baseUrl == null) {
      debugPrint('ChatService: Base URL not initialized');
      return {
        'status': 'error',
        'message': 'Server connection not initialized. Please try again later.',
      };
    }

    try {
      debugPrint('ChatService: Stopping recorder...');
      await _recorder.stop();
      _isRecording = false;
      debugPrint('ChatService: Recorder stopped successfully');

      final file = File(_currentAudioPath!);
      if (!await file.exists()) {
        debugPrint('ChatService: Audio file not found at ${file.path}');
        return {'status': 'error', 'message': 'Audio file not found'};
      }

      final fileSize = await file.length();
      debugPrint('ChatService: Audio file size: ${fileSize} bytes');
      if (fileSize < 100) {
        debugPrint(
          'ChatService: Audio file is too small, likely empty or corrupted',
        );
        return {
          'status': 'error',
          'message': 'Audio recording is too short or empty',
        };
      }

      final endpoint = '$_baseUrl${ApiConfig.voiceChatEndpoint}';
      debugPrint('ChatService: Sending audio to endpoint: $endpoint');

      final request = http.MultipartRequest('POST', Uri.parse(endpoint));

      // Add chat history
      request.fields['history'] = jsonEncode(chatHistory);
      debugPrint('ChatService: Added history to request: $chatHistory');

      // Add audio file
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      debugPrint('ChatService: Added file to request with name: file');

      debugPrint('ChatService: Sending request...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out after 30 seconds');
        },
      );
      debugPrint(
        'ChatService: Got response with status: ${streamedResponse.statusCode}',
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        debugPrint('ChatService: Successfully processed voice recording');
        final responseData = jsonDecode(response.body);
        return {
          'status': 'success',
          'transcribed_text': responseData['transcribed_text'] ?? '',
          'content': responseData['content'] ?? '',
          'role': responseData['role'] ?? 'assistant',
          'timestamp':
              responseData['timestamp'] ?? DateTime.now().toIso8601String(),
        };
      } else {
        debugPrint(
          'ChatService: Server returned error status: ${response.statusCode}',
        );
        debugPrint('ChatService: Response body: ${response.body}');
        return {
          'status': 'error',
          'message':
              'Failed to process voice recording: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      debugPrint('ChatService: Error stopping voice recording: $e');
      return {'status': 'error', 'message': 'Network error: $e'};
    } finally {
      _isRecording = false;
      _currentAudioPath = null;
    }
  }

  Future<bool> speak(String text) async {
    if (text.isEmpty) return false;

    try {
      await _tts.speak(text);
      return true;
    } catch (e) {
      debugPrint('ChatService: Error in text-to-speech: $e');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;
      }
      debugPrint('ChatService: Audio playback and recording stopped');
    } catch (e) {
      debugPrint('ChatService: Error stopping audio: $e');
    }
  }

  Future<File> getAudioResponse(String audioUrl) async {
    try {
      final response = await http.get(Uri.parse(audioUrl));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/response_audio.mp3');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Failed to get audio response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ChatService: Error getting audio response: $e');
      throw Exception('Network error: $e');
    }
  }

  void dispose() {
    _recorder.dispose();
    _tts.stop();
  }
}

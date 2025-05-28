import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/config/api_config.dart';

class ChatService {
  String? _baseUrl;
  bool _isRecording = false;
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
        'content': 'Server connection not initialized.',
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
      }
      return {
        'status': 'error',
        'content': 'Failed to send message: ${response.statusCode}',
      };
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
      return await ApiConfig.testConnectionWithUrl(_baseUrl!);
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

      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        return {'status': 'error', 'message': 'Microphone permission denied'};
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
        'message': 'Server connection not initialized.',
      };
    }

    try {
      await _recorder.stop();
      _isRecording = false;

      final file = File(_currentAudioPath!);
      if (!await file.exists()) {
        return {'status': 'error', 'message': 'Audio file not found'};
      }

      final fileSize = await file.length();
      if (fileSize < 100) {
        return {
          'status': 'error',
          'message': 'Audio recording is too short or empty',
        };
      }

      final endpoint = '$_baseUrl${ApiConfig.voiceChatEndpoint}';
      final request = http.MultipartRequest('POST', Uri.parse(endpoint));
      request.fields['history'] = jsonEncode(chatHistory);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException('Request timed out after 20 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'status': 'success',
          'transcribed_text': responseData['transcribed_text'] ?? '',
          'content': responseData['content'] ?? '',
          'role': responseData['role'] ?? 'assistant',
          'timestamp':
              responseData['timestamp'] ?? DateTime.now().toIso8601String(),
        };
      }
      return {
        'status': 'error',
        'message':
            'Failed to process voice recording: ${response.statusCode} - ${response.body}',
      };
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
      }
      throw Exception('Failed to get audio response: ${response.statusCode}');
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

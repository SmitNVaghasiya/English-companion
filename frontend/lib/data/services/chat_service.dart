import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_endpoints.dart';
import '../../core/config/env_config.dart';
import '../../core/utils/connection_utils.dart';
import '../models/chat_response.dart';
import 'api_service.dart';

class ChatService {
  late ApiService _apiService;
  late String _baseUrl = '';
  bool _isInitialized = false;
  final AudioRecorder _recorder = AudioRecorder();

  ChatService();

  Future<Map<String, dynamic>> testConnection() async {
    try {
      debugPrint('ChatService: Starting connection test...');
      await _initialize();
      debugPrint('ChatService: After _initialize(), _baseUrl = $_baseUrl');

      if (!await ConnectionUtils.hasInternetConnection()) {
        final message =
            'No internet connection. Please check your network and try again.';
        debugPrint('ChatService: $message');
        return {'connected': false, 'message': message};
      }

      if (_baseUrl.isEmpty) {
        return {'connected': false, 'message': 'Server URL is not configured.'};
      }

      final cleanBaseUrl =
          _baseUrl.endsWith('/')
              ? _baseUrl.substring(0, _baseUrl.length - 1)
              : _baseUrl;
      final healthUrl = '$cleanBaseUrl${AppEndpoints.health}';
      debugPrint('ChatService: Testing connection to: $healthUrl');

      try {
        final response = await _apiService
            .get(AppEndpoints.health)
            .timeout(const Duration(seconds: 5));

        debugPrint('ChatService: Health response: $response');
        if (response['status'] == 'ok') {
          return {
            'connected': true,
            'message': 'Successfully connected to the server',
          };
        }

        return {
          'connected': false,
          'message':
              'Server responded with an unexpected status: ${response['status']}',
        };
      } catch (e) {
        debugPrint('ChatService: Connection test failed: $e');
        if (e is TimeoutException) {
          return {
            'connected': false,
            'message':
                'Connection timed out. The server at $cleanBaseUrl is not responding.',
          };
        } else if (e is SocketException) {
          return {
            'connected': false,
            'message':
                'Could not connect to the server at $cleanBaseUrl. Please check the URL and network.',
          };
        }
        return {
          'connected': false,
          'message':
              'Failed to connect to the server: ${e.toString().replaceAll('Exception:', '').trim()}',
        };
      }
    } catch (e) {
      debugPrint('ChatService: Error in testConnection: $e');
      return {
        'connected': false,
        'message':
            'Failed to connect to the server: ${e.toString().replaceAll('Exception:', '').trim()}',
      };
    }
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      final envUrl = EnvConfig.backendUrl;
      if (envUrl != null && envUrl.isNotEmpty) {
        String cleanUrl = envUrl.trim();
        if (!cleanUrl.endsWith('/')) {
          cleanUrl = '$cleanUrl/';
        }

        debugPrint('ChatService: Testing environment URL: $cleanUrl');
        final isReachable = await ConnectionUtils.testConnectionToUrl(cleanUrl);
        debugPrint(
          'ChatService: Environment URL $cleanUrl reachable: $isReachable',
        );

        if (isReachable) {
          _baseUrl = cleanUrl;
          _apiService = ApiService(_baseUrl);
          debugPrint('ChatService: Using environment server URL: $_baseUrl');
          _isInitialized = true;
          return;
        } else {
          debugPrint(
            'ChatService: Environment URL $cleanUrl is not reachable.',
          );
        }
      } else {
        debugPrint('ChatService: No environment URL found in .env file.');
      }

      debugPrint('ChatService: Trying auto-discovery for server URL');
      try {
        final serverUrl = await ConnectionUtils.findServerUrl();
        if (serverUrl != null) {
          _baseUrl = serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
          _apiService = ApiService(_baseUrl);
          debugPrint('ChatService: Using discovered server URL: $_baseUrl');
          _isInitialized = true;
          return;
        }
      } catch (e) {
        debugPrint('ChatService: Error during server discovery: $e');
      }

      debugPrint('ChatService: Trying localhost as fallback');
      const localUrl = 'http://localhost:8000/';
      final isLocalReachable = await ConnectionUtils.testConnectionToUrl(
        localUrl,
      );
      debugPrint('ChatService: Localhost reachable: $isLocalReachable');

      if (isLocalReachable) {
        _baseUrl = localUrl;
        _apiService = ApiService(_baseUrl);
        debugPrint('ChatService: Using localhost as server URL');
      } else {
        if (envUrl != null && envUrl.isNotEmpty) {
          _baseUrl = envUrl.endsWith('/') ? envUrl : '$envUrl/';
        } else {
          _baseUrl = localUrl;
        }
        _apiService = ApiService(_baseUrl);
        debugPrint('ChatService: Using fallback server URL: $_baseUrl');
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('ChatService: Error during initialization: $e');
      _baseUrl = 'http://localhost:8000/';
      _apiService = ApiService(_baseUrl);
      _isInitialized = true;
      rethrow;
    }
  }

  String get backendUrl {
    // Ensure no double slashes in the URL
    final cleanBaseUrl =
        _baseUrl.endsWith('/')
            ? _baseUrl.substring(0, _baseUrl.length - 1)
            : _baseUrl;
    return cleanBaseUrl;
  }

  Future<ChatResponse> sendQuery(List<Map<String, dynamic>> messages) async {
    try {
      await _initialize();

      if (!await ConnectionUtils.hasInternetConnection()) {
        debugPrint('ChatService: No internet connection available');
        return ChatResponse(
          status: 'error',
          role: 'system',
          content:
              'No internet connection. Please check your network and try again.',
          timestamp: DateTime.now(),
        );
      }

      if (messages.isEmpty) {
        debugPrint('ChatService: No messages to send');
        return ChatResponse(
          status: 'error',
          role: 'system',
          content: 'No message content provided',
          timestamp: DateTime.now(),
        );
      }

      debugPrint(
        'ChatService: Sending message to server: ${messages.last['content']}',
      );

      final apiMessages =
          messages
              .map(
                (msg) => {
                  'role': msg['role'] == 'user' ? 'user' : 'assistant',
                  'content': msg['content'] ?? '',
                  'timestamp':
                      msg['timestamp']?.toString() ??
                      DateTime.now().toIso8601String(),
                },
              )
              .toList();

      final response = await _apiService.post(AppEndpoints.chat, {
        'messages': apiMessages,
      });

      debugPrint('ChatService: Received response: $response');
      return ChatResponse.fromMap({
        'status': 'success',
        'role': response['role'] ?? 'assistant',
        'content': response['content'] ?? 'No response content',
        'timestamp': response['timestamp'] ?? DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('ChatService: Error in sendQuery: $e');
      return ChatResponse(
        status: 'error',
        role: 'system',
        content:
            e is SocketException
                ? 'Could not connect to the server. Please check your connection.'
                : e.toString().contains('timed out')
                ? 'Request timed out. Please try again.'
                : 'An unexpected error occurred: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  Future<ChatResponse> sendVoiceQuery() async {
    String? audioPath; // Declare audioPath at method scope
    try {
      await _initialize();

      if (!await ConnectionUtils.hasInternetConnection()) {
        debugPrint('ChatService: No internet connection available');
        return ChatResponse(
          status: 'error',
          role: 'system',
          content:
              'No internet connection. Please check your network and try again.',
          timestamp: DateTime.now(),
        );
      }

      // Check microphone permission
      debugPrint('ChatService: Checking microphone permission');
      if (!await _recorder.hasPermission()) {
        debugPrint('ChatService: Microphone permission denied');
        return ChatResponse(
          status: 'error',
          role: 'system',
          content: 'Microphone permission is required for voice chat.',
          timestamp: DateTime.now(),
        );
      }
      debugPrint('ChatService: Microphone permission granted');

      // Record audio
      debugPrint('ChatService: Starting audio recording');
      final directory = await getTemporaryDirectory();
      audioPath = '${directory.path}/voice_input.wav';
      debugPrint('ChatService: Audio will be saved to: $audioPath');
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav, // Use WAV for server compatibility
          sampleRate: 16000,
        ),
        path: audioPath,
      );
      debugPrint('ChatService: Recording started');

      // Record for a longer duration (10 seconds) to ensure enough time to speak
      await Future.delayed(const Duration(seconds: 10));
      debugPrint('ChatService: Stopping audio recording');
      await _recorder.stop();
      debugPrint('ChatService: Recording stopped');

      // Check if the file exists
      final audioFile = File(audioPath);
      if (await audioFile.exists()) {
        debugPrint('ChatService: Audio file exists at: $audioPath');
        final fileSize = await audioFile.length();
        debugPrint('ChatService: Audio file size: $fileSize bytes');
      } else {
        debugPrint('ChatService: Audio file does not exist');
        return ChatResponse(
          status: 'error',
          role: 'system',
          content: 'Failed to record audio. Please try again.',
          timestamp: DateTime.now(),
        );
      }

      // Send audio to server
      final voiceChatUrl = '${backendUrl}${AppEndpoints.voiceChat}';
      debugPrint('ChatService: Preparing to send request to $voiceChatUrl');
      final request = http.MultipartRequest('POST', Uri.parse(voiceChatUrl));
      request.files.add(await http.MultipartFile.fromPath('file', audioPath));
      debugPrint('ChatService: Sending request...');
      final response = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('ChatService: Request timed out');
          throw TimeoutException('Request timed out');
        },
      );
      debugPrint(
        'ChatService: Request sent, status code: ${response.statusCode}',
      );
      final responseBody = await response.stream.bytesToString();
      debugPrint('ChatService: Received response: $responseBody');

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(responseBody);
        return ChatResponse.fromMap({
          'status': 'success',
          'role': responseJson['role'] ?? 'assistant',
          'content': responseJson['content'] ?? 'No response content',
          'timestamp':
              responseJson['timestamp'] ?? DateTime.now().toIso8601String(),
        });
      } else {
        debugPrint('ChatService: Server error: ${response.statusCode}');
        return ChatResponse(
          status: 'error',
          role: 'system',
          content: 'Server error: ${response.statusCode} - $responseBody',
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('ChatService: Error in sendVoiceQuery: $e');
      return ChatResponse(
        status: 'error',
        role: 'system',
        content:
            e is SocketException
                ? 'Could not connect to the server. Please check your connection.'
                : e.toString().contains('timed out')
                ? 'Request timed out. Please try again.'
                : 'Failed to process voice request: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    } finally {
      // Clean up the audio file if it was created
      if (audioPath != null) {
        final audioFile = File(audioPath);
        if (await audioFile.exists()) {
          await audioFile.delete();
          debugPrint('ChatService: Cleaned up audio file');
        }
      }
    }
  }
}

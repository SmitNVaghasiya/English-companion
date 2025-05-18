import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_endpoints.dart';
import '../../core/config/env_config.dart';
import '../../core/utils/connection_utils.dart';
import '../models/chat_response.dart';
import 'api_service.dart';

class ChatService {
  late ApiService _apiService;
  late String _baseUrl = '';
  bool _isInitialized = false;

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
      // First try environment URL if available
      final envUrl = EnvConfig.backendUrl;
      if (envUrl != null && envUrl.isNotEmpty) {
        String cleanUrl = envUrl.trim();
        if (!cleanUrl.endsWith('/')) {
          cleanUrl = '$cleanUrl/';
        }

        debugPrint('ChatService: Testing environment URL: $cleanUrl');
        if (await ConnectionUtils.testConnectionToUrl(cleanUrl)) {
          _baseUrl = cleanUrl;
          _apiService = ApiService(_baseUrl);
          debugPrint('ChatService: Using environment server URL: $_baseUrl');
          _isInitialized = true;
          return; // Skip auto-discovery if environment URL works
        } else {
          debugPrint('ChatService: Environment URL $cleanUrl is not reachable.');
        }
      } else {
        debugPrint('ChatService: No environment URL found in .env file.');
      }

      // If we get here, environment URL failed or wasn't set, try auto-discovery
      debugPrint('ChatService: Trying auto-discovery for server URL');
      final serverUrl = await ConnectionUtils.findServerUrl();
      if (serverUrl != null) {
        _baseUrl = serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
        _apiService = ApiService(_baseUrl);
        debugPrint('ChatService: Using discovered server URL: $_baseUrl');
        _isInitialized = true;
        return;
      }

      // If we get here, no server was found, use a default URL
      debugPrint('ChatService: Could not find a valid server URL, using default');
      _baseUrl = 'http://localhost:8000/';
      _apiService = ApiService(_baseUrl);
      _isInitialized = true;
      
    } catch (e) {
      debugPrint('ChatService: Error during initialization, using fallback: $e');
      // Even if there's an error, initialize with a default URL
      _baseUrl = 'http://localhost:8000/';
      _apiService = ApiService(_baseUrl);
      _isInitialized = true;
    }
  }

  String get backendUrl =>
      _baseUrl.endsWith('/')
          ? _baseUrl.substring(0, _baseUrl.length - 1)
          : _baseUrl;

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
}

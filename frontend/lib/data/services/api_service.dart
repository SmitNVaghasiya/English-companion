import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final int _maxRetries = 3;
  final Duration _initialRetryDelay = Duration(seconds: 1);
  final Duration _httpTimeout = Duration(seconds: 30);

  ApiService(String baseUrl)
    : baseUrl =
          baseUrl.endsWith('/')
              ? baseUrl.substring(0, baseUrl.length - 1)
              : baseUrl;

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = '$baseUrl$cleanEndpoint';
    debugPrint('ApiService: Posting to URL: $url');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(body),
            )
            .timeout(_httpTimeout);

        debugPrint('ApiService: Response status: ${response.statusCode}');
        debugPrint('ApiService: Response body: ${response.body}');

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode >= 400 && response.statusCode < 500) {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['detail'] ?? 'Bad request');
        } else if (response.statusCode >= 500) {
          throw Exception('Server error. Please try again later.');
        } else {
          throw Exception('Unexpected error occurred');
        }
      } catch (e) {
        debugPrint('ApiService: Attempt $attempt failed: $e');
        if (attempt == _maxRetries) {
          debugPrint('ApiService: Max retries reached. Throwing error: $e');
          rethrow;
        }
        await Future.delayed(_initialRetryDelay * (1 << (attempt - 1)));
      }
    }
    throw Exception('Unexpected error in request handling');
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = '$baseUrl$cleanEndpoint';
    debugPrint('ApiService: Getting from URL: $url');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
            .timeout(Duration(seconds: 30));
        debugPrint('ApiService: Response status: ${response.statusCode}');
        debugPrint('ApiService: Response body: ${response.body}');

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
        throw Exception('Failed to fetch data: ${response.statusCode}');
      } catch (e) {
        debugPrint('ApiService: Attempt $attempt failed: $e');
        if (attempt == _maxRetries) {
          debugPrint('ApiService: Max retries reached. Throwing error: $e');
          throw Exception('Network error: $e');
        }
        await Future.delayed(_initialRetryDelay * (1 << (attempt - 1)));
      }
    }
    throw Exception('Unexpected error in request handling');
  }
}

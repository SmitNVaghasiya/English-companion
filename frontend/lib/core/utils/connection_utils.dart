import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ConnectionUtils {
  // List of possible server IPs to try for auto-discovery
  static const List<String> possibleServerIps = [
    '192.168.137.113', // WiFi IP
    '172.28.128.1', // WSL/Docker interface
    '192.168.31.81', // Other possible IP
    'localhost', // Localhost as fallback
  ];

  // Default server port
  static const int serverPort = 8000;

  // Timeout for connection attempts
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const Duration healthCheckTimeout = Duration(seconds: 3);

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Additional check to confirm internet access
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw SocketException('Connection timeout'),
      );

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('ConnectionUtils: hasInternetConnection error: $e');
      return false;
    }
  }

  // Test connection to a specific URL
  static Future<bool> testConnectionToUrl(String url) async {
    http.Client? client;
    try {
      // Ensure URL ends with a slash
      String testUrl = url.endsWith('/') ? '${url}health' : '$url/health';
      testUrl = testUrl.replaceAll('//health', '/health'); // Fix double slashes

      debugPrint('Testing connection to: $testUrl');

      client = http.Client();
      final uri = Uri.parse(testUrl);

      // Print additional debug info
      debugPrint('URI: $uri');
      debugPrint('Scheme: ${uri.scheme}');
      debugPrint('Host: ${uri.host}');
      debugPrint('Port: ${uri.port}');
      debugPrint('Path: ${uri.path}');

      // First try a simple socket connection to check basic connectivity
      try {
        debugPrint('Attempting socket connection to ${uri.host}:${uri.port}');
        final socket = await Socket.connect(
          uri.host,
          uri.port,
          timeout: const Duration(seconds: 3),
        );
        socket.destroy();
        debugPrint('Socket connection successful');
      } catch (e) {
        debugPrint('Socket connection failed: $e');
      }

      final stopwatch = Stopwatch()..start();
      final request = http.Request('GET', uri);

      // Add headers to help with debugging
      request.headers['Accept'] = 'application/json';
      request.headers['Connection'] = 'close';

      final response = await client
          .send(request)
          .timeout(
            healthCheckTimeout,
            onTimeout: () {
              client?.close();
              throw TimeoutException(
                'Connection to $url timed out after ${healthCheckTimeout.inSeconds} seconds',
              );
            },
          );

      final responseBody = await response.stream.bytesToString();
      stopwatch.stop();

      debugPrint(
        'Response status: ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)',
      );
      debugPrint('Response headers: ${response.headers}');
      debugPrint('Response body: $responseBody');

      return response.statusCode == 200;
    } on TimeoutException catch (e) {
      debugPrint('ConnectionUtils: Timeout testing $url: $e');
      return false;
    } on SocketException catch (e) {
      debugPrint('ConnectionUtils: Socket error testing $url: $e');
      debugPrint('OS Error: ${e.osError}');
      debugPrint('Address: ${e.address}');
      debugPrint('Port: ${e.port}');
      return false;
    } on FormatException catch (e) {
      debugPrint('ConnectionUtils: Format error testing $url: $e');
      debugPrint('Source: ${e.source}');
      debugPrint('Offset: ${e.offset}');
      return false;
    } catch (e, stackTrace) {
      debugPrint('ConnectionUtils: Error testing $url: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    } finally {
      client?.close();
    }
  }

  // Find a working server URL from the list of possible IPs
  static Future<String?> findServerUrl() async {
    if (!await hasInternetConnection()) {
      debugPrint('ConnectionUtils: No internet connection available');
      return null;
    }

    // Try both HTTP and HTTPS for each IP
    for (var ip in possibleServerIps) {
      // Try HTTP first
      final httpUrl = 'http://$ip:$serverPort';
      debugPrint('ConnectionUtils: Trying HTTP connection to $httpUrl');

      try {
        final isReachable = await testConnectionToUrl(httpUrl);
        if (isReachable) {
          debugPrint('ConnectionUtils: Found working HTTP server at $httpUrl');
          return httpUrl.endsWith('/') ? httpUrl : '$httpUrl/';
        }
      } catch (e) {
        debugPrint('ConnectionUtils: Error testing HTTP $httpUrl: $e');
      }

      // Then try HTTPS
      final httpsUrl = 'https://$ip:$serverPort';
      debugPrint('ConnectionUtils: Trying HTTPS connection to $httpsUrl');

      try {
        final isReachable = await testConnectionToUrl(httpsUrl);
        if (isReachable) {
          debugPrint(
            'ConnectionUtils: Found working HTTPS server at $httpsUrl',
          );
          return httpsUrl.endsWith('/') ? httpsUrl : '$httpsUrl/';
        }
      } catch (e) {
        debugPrint('ConnectionUtils: Error testing HTTPS $httpsUrl: $e');
      }
    }

    // If no server found, try localhost with both HTTP and HTTPS
    debugPrint('ConnectionUtils: Trying localhost as last resort');
    final localUrls = [
      'http://localhost:$serverPort',
      'https://localhost:$serverPort',
      'http://127.0.0.1:$serverPort',
      'https://127.0.0.1:$serverPort',
    ];

    for (final url in localUrls) {
      try {
        debugPrint('ConnectionUtils: Trying local URL: $url');
        final isReachable = await testConnectionToUrl(url);
        if (isReachable) {
          debugPrint('ConnectionUtils: Found working server at $url');
          return url.endsWith('/') ? url : '$url/';
        }
      } catch (e) {
        debugPrint('ConnectionUtils: Error testing local URL $url: $e');
      }
    }

    debugPrint('ConnectionUtils: No working server found');
    return null;
  }
}

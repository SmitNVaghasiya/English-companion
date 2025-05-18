import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ConnectionUtils {
  // List of possible server IPs to try for auto-discovery
  static const List<String> possibleServerIps = [
    '192.168.31.81',
    '172.28.240.1',
    'localhost',
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
    try {
      // Ensure URL ends with a slash
      String testUrl = url.endsWith('/') ? '${url}health' : '$url/health';
      
      final response = await http
          .get(Uri.parse(testUrl))
          .timeout(healthCheckTimeout);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ConnectionUtils: testConnectionToUrl error for $url: $e');
      return false;
    }
  }

  // Find a working server URL from the list of possible IPs
  static Future<String?> findServerUrl() async {
    if (!await hasInternetConnection()) {
      debugPrint('ConnectionUtils: No internet connection available');
      return null;
    }

    for (var ip in possibleServerIps) {
      final url = 'http://$ip:$serverPort';
      debugPrint('ConnectionUtils: Trying to connect to $url');
      
      try {
        final isReachable = await testConnectionToUrl(url);
        if (isReachable) {
          debugPrint('ConnectionUtils: Found working server at $url');
          return url;
        }
      } catch (e) {
        debugPrint('ConnectionUtils: Error testing $url: $e');
      }
    }
    
    debugPrint('ConnectionUtils: No working server found');
    return null;
  }
}
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionUtils {
  static const int serverPort = 8000;
  static const Duration connectionTimeout = Duration(seconds: 3);
  static const Duration healthCheckTimeout = Duration(seconds: 2);
  static const String _serverUrlKey = 'server_url';
  static Timer? _discoveryTimer;

  static Future<void> startServerDiscovery() async {
    try {
      if (_discoveryTimer?.isActive ?? false) {
        debugPrint('ConnectionUtils: Server discovery already running');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      _discoveryTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
        try {
          final serverUrl = await findServerUrl();
          if (serverUrl != null) {
            await prefs.setString(_serverUrlKey, serverUrl);
            debugPrint('ConnectionUtils: Updated server URL: $serverUrl');
          }
        } catch (e) {
          debugPrint('ConnectionUtils: Error in periodic discovery: $e');
        }
      });
    } catch (e) {
      debugPrint('ConnectionUtils: Error starting server discovery: $e');
    }
  }

  static void stopServerDiscovery() {
    try {
      _discoveryTimer?.cancel();
      _discoveryTimer = null;
      debugPrint('ConnectionUtils: Stopped server discovery');
    } catch (e) {
      debugPrint('ConnectionUtils: Error stopping server discovery: $e');
    }
  }

  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResults.any((result) => 
          result != ConnectivityResult.none && result != ConnectivityResult.other);
      if (!hasConnection) return false;
      
      // Check if there's actual internet connectivity
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

  static Future<bool> testConnectionToUrl(String url) async {
    http.Client? client;
    try {
      String normalizedUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
      String testUrl = '$normalizedUrl/health';
      debugPrint('Testing connection to: $testUrl');

      // Test socket connection
      final uri = Uri.parse(testUrl);
      final socket = await Socket.connect(
        uri.host,
        uri.port,
        timeout: Duration(seconds: 2),
      );
      socket.destroy();
      await socket.close();

      // Test HTTP request
      client = http.Client();
      final response = await client
          .get(
            Uri.parse(testUrl),
            headers: {'Accept': 'application/json', 'Connection': 'close'},
          )
          .timeout(healthCheckTimeout);

      debugPrint('HTTP ${response.statusCode} from $testUrl');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ConnectionUtils: Error testing $url: $e');
      return false;
    } finally {
      client?.close();
    }
  }

  static Future<String?> findServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUrl = prefs.getString(_serverUrlKey);
      if (cachedUrl != null && await testConnectionToUrl(cachedUrl)) {
        debugPrint('ConnectionUtils: Using cached server URL: $cachedUrl');
        return cachedUrl;
      }

      if (!await hasInternetConnection()) {
        debugPrint('ConnectionUtils: No internet connection available');
        return null;
      }

      // Since we're using mDNS in ApiConfig, we don't need to manually search IPs here
      return null;
    } catch (e) {
      debugPrint('ConnectionUtils: Error in findServerUrl: $e');
      return null;
    }
  }
}

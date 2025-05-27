import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionUtils {
  static const List<String> possibleServerIps = [
    '192.168.137.1',
    '10.224.13.128',
    '172.30.176.1',
    '172.19.80.1',
    '192.168.137.113',
    '172.28.128.1',
    '192.168.31.81',
  ];

  static const int serverPort = 8000;
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const Duration healthCheckTimeout = Duration(seconds: 3);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const String _serverUrlKey = 'server_url';
  static Timer? _discoveryTimer;

  static Future<void> startServerDiscovery() async {
    try {
      if (_discoveryTimer != null && _discoveryTimer!.isActive) {
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
      final connectivityResult = await Connectivity().checkConnectivity();
      if ([ConnectivityResult.none].contains(connectivityResult)) return false;

      final result = await InternetAddress.lookup('google.com').timeout(
        Duration(seconds: 2),
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

      // First test socket connection
      try {
        final uri = Uri.parse(testUrl);
        debugPrint('Attempting socket connection to ${uri.host}:${uri.port}');
        final socket = await Socket.connect(
          uri.host,
          uri.port,
          timeout: Duration(seconds: 3),
        );
        socket.destroy();
        await socket.close();
        debugPrint('✅ Socket connection successful to ${uri.host}:${uri.port}');
      } on SocketException catch (e) {
        debugPrint('❌ Socket connection failed: $e');
        return false;
      } catch (e) {
        debugPrint('❌ Unexpected socket error: $e');
        return false;
      }

      // If socket connection succeeds, try HTTP request
      client = http.Client();
      final stopwatch = Stopwatch()..start();

      try {
        final response = await client
            .get(
              Uri.parse(testUrl),
              headers: {'Accept': 'application/json', 'Connection': 'close'},
            )
            .timeout(healthCheckTimeout);

        stopwatch.stop();
        debugPrint(
          '✅ HTTP ${response.statusCode} from $testUrl (${stopwatch.elapsedMilliseconds}ms)',
        );
        debugPrint('Response headers: ${response.headers}');
        debugPrint('Response body: ${response.body}');

        return response.statusCode == 200;
      } on TimeoutException {
        debugPrint(
          '❌ Request to $testUrl timed out after ${healthCheckTimeout.inSeconds}s',
        );
        return false;
      } on http.ClientException catch (e) {
        debugPrint('❌ HTTP Client error: $e');
        return false;
      } catch (e, stackTrace) {
        debugPrint('❌ Unexpected HTTP error: $e');
        debugPrint('Stack trace: $stackTrace');
        return false;
      }
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

      for (var ip in possibleServerIps) {
        final httpUrl = 'http://$ip:$serverPort';
        final httpsUrl = 'https://$ip:$serverPort';

        for (var url in [httpUrl, httpsUrl]) {
          try {
            if (await testConnectionToUrl(url)) {
              final finalUrl = url.endsWith('/') ? url : '$url/';
              await prefs.setString(_serverUrlKey, finalUrl);
              debugPrint('ConnectionUtils: Found working server at $finalUrl');
              return finalUrl;
            }
          } catch (e) {
            debugPrint('ConnectionUtils: Error testing $url: $e');
          }
        }
      }

      final localUrls = [
        'http://localhost:$serverPort',
        'https://localhost:$serverPort',
        'http://127.0.0.1:$serverPort',
        'https://127.0.0.1:$serverPort',
      ];

      for (final url in localUrls) {
        try {
          if (await testConnectionToUrl(url)) {
            final finalUrl = url.endsWith('/') ? url : '$url/';
            await prefs.setString(_serverUrlKey, finalUrl);
            debugPrint('ConnectionUtils: Found working server at $finalUrl');
            return finalUrl;
          }
        } catch (e) {
          debugPrint('ConnectionUtils: Error testing local URL $url: $e');
        }
      }

      debugPrint('ConnectionUtils: No working server found');
      return null;
    } catch (e) {
      debugPrint('ConnectionUtils: Error in findServerUrl: $e');
      return null;
    }
  }
}

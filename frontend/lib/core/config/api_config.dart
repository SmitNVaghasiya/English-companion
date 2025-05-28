import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static String? _baseUrl;
  static const String _serviceType = '_englishcompanion._tcp';
  static const String _cacheKey = 'cached_base_url';

  // API endpoints
  static const String chatEndpoint = '/api/chat';
  static const String voiceChatEndpoint = '/api/voice_chat';
  static const String healthEndpoint = '/api/health';

  // Timeouts
  static const int connectionTimeoutSeconds = 5;
  static const int responseTimeoutSeconds = 20;

  // List of possible server URLs to try in order of preference
  static final List<String> _possibleBaseUrls = [
    'http://192.168.31.81:8000', // Current WiFi IP
    'http://172.23.128.1:8000',   // Common home network IP
    'http://192.168.1.100:8000',  // Common home network IP
    'http://localhost:8000',      // Local development
    'http://127.0.0.1:8000',      // Alternative localhost
    'http://10.0.2.2:8000',       // Android emulator localhost
    'http://192.168.137.1:8000',  // College network
  ];

  static Future<String> get baseUrl async {
    if (_baseUrl != null) {
      debugPrint('ApiConfig: Using cached base URL: $_baseUrl');
      return _baseUrl!;
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedUrl = prefs.getString(_cacheKey);

    // Try the cached URL first if it exists
    if (cachedUrl != null && await _isServerReachable(cachedUrl)) {
      _baseUrl = cachedUrl;
      debugPrint('ApiConfig: Using cached working URL: $_baseUrl');
      return _baseUrl!;
    }

    // Try all possible URLs
    for (final url in _possibleBaseUrls) {
      try {
        if (await _isServerReachable(url)) {
          _baseUrl = url;
          await prefs.setString(_cacheKey, url);
          debugPrint('ApiConfig: Found working URL: $url');
          return url;
        }
      } catch (e) {
        debugPrint('Error checking URL $url: $e');
      }
    }

    // Try mDNS discovery as last resort
    try {
      final discoveredUrl = await _discoverServer();
      if (discoveredUrl != null) {
        _baseUrl = discoveredUrl;
        await prefs.setString(_cacheKey, discoveredUrl);
        debugPrint('ApiConfig: Using mDNS discovered URL: $_baseUrl');
        return _baseUrl!;
      }
    } catch (e) {
      debugPrint('mDNS discovery failed: $e');
    }

    // If no working URL found, use the first one as default and let it fail with proper error
    _baseUrl = _possibleBaseUrls.first;
    debugPrint('ApiConfig: No working URL found, using default: $_baseUrl');
    return _baseUrl!;
  }

  static Future<bool> _isServerReachable(String url) async {
    try {
      final response = await http
          .get(Uri.parse('$url$healthEndpoint'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Server at $url is not reachable: $e');
      return false;
    }
  }

  static Future<bool> testConnection() async {
    try {
      final url = await baseUrl;
      debugPrint('Testing connection to: $url');
      return await testConnectionWithUrl(url);
    } catch (e) {
      debugPrint('ApiConfig: Connection test failed: $e');
      // Clear the cached URL to force rediscovery on next attempt
      await resetBaseUrl();
      return false;
    }
  }

  static Future<bool> testConnectionWithUrl(String url) async {
    try {
      debugPrint('Attempting to connect to: $url$healthEndpoint');
      final stopwatch = Stopwatch()..start();

      final response = await http
          .get(
            Uri.parse('$url$healthEndpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: connectionTimeoutSeconds));

      stopwatch.stop();
      final isSuccess = response.statusCode == 200;

      debugPrint('''
ApiConfig: Connection test to $url
Status: ${response.statusCode}
Response time: ${stopwatch.elapsedMilliseconds}ms
Response body: ${response.body}
Success: $isSuccess
''');

      if (!isSuccess) {
        // If the connection failed, clear the cached URL
        await resetBaseUrl();
      }

      return isSuccess;
    } catch (e) {
      debugPrint('ApiConfig: Test connection to $url failed: $e');
      await resetBaseUrl();
      return false;
    }
  }

  /// Resets the base URL cache and removes it from shared preferences
  static Future<void> resetBaseUrl() async {
    _baseUrl = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    debugPrint('ApiConfig: Base URL cache reset');
  }

  /// Alias for resetBaseUrl for backward compatibility
  static Future<void> clearCachedUrl() async {
    await resetBaseUrl();
  }

  static Future<String?> _discoverServer() async {
    try {
      final mdnsClient = MDnsClient(
        rawDatagramSocketFactory: (
          dynamic host,
          int port, {
          bool reuseAddress = true,
          bool reusePort = true,
          int ttl = 1,
        }) {
          return RawDatagramSocket.bind(
            host,
            port,
            reuseAddress: reuseAddress,
            ttl: ttl,
          );
        },
      );
      await mdnsClient.start();

      await for (final ResourceRecord ptr in mdnsClient.lookup(
        ResourceRecordQuery.serverPointer(_serviceType),
      )) {
        if (ptr is PtrResourceRecord) {
          debugPrint('ApiConfig: Found PTR record: ${ptr.domainName}');
          await for (final ResourceRecord srv in mdnsClient.lookup(
            ResourceRecordQuery.service(ptr.domainName),
          )) {
            if (srv is SrvResourceRecord) {
              debugPrint(
                'ApiConfig: Found SRV record: ${srv.target}:${srv.port}',
              );
              await for (final ResourceRecord ipRecord in mdnsClient.lookup(
                ResourceRecordQuery.addressIPv4(srv.target),
              )) {
                if (ipRecord is IPAddressResourceRecord) {
                  final url =
                      'http://${ipRecord.address.address}:${srv.port}/api';
                  debugPrint('ApiConfig: Discovered server at $url via mDNS');
                  if (await testConnectionWithUrl(url)) {
                    mdnsClient.stop();
                    return url;
                  }
                }
              }
            }
          }
        }
      }
      mdnsClient.stop();
      debugPrint('ApiConfig: No server found via mDNS');
      return null;
    } catch (e) {
      debugPrint('ApiConfig: mDNS discovery failed: $e');
      return null;
    }
  }
}

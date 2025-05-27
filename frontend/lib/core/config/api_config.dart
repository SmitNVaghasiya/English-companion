import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';
import 'env_config.dart';

class ApiConfig {
  static String? _baseUrl;
  static const String _serviceType = '_englishcompanion._tcp';

  static Future<String> get baseUrl async {
    if (_baseUrl != null) {
      debugPrint('ApiConfig: Using cached base URL: $_baseUrl');
      return _baseUrl!;
    }

    // Try environment configuration first
    String? configUrl = EnvConfig.backendUrl;
    if (configUrl != null && configUrl.isNotEmpty) {
      if (!configUrl.endsWith('/api')) {
        configUrl = '$configUrl/api';
      }
      debugPrint('ApiConfig: Testing environment config URL: $configUrl');
      if (await testConnectionWithUrl(configUrl)) {
        _baseUrl = configUrl;
        debugPrint('ApiConfig: Using environment config URL: $_baseUrl');
        return _baseUrl!;
      } else {
        debugPrint('ApiConfig: Environment URL ($configUrl) is not reachable');
      }
    }

    // Try mDNS discovery
    _baseUrl = await _discoverServer();
    if (_baseUrl != null) {
      debugPrint('ApiConfig: Using mDNS discovered URL: $_baseUrl');
      return _baseUrl!;
    }

    // Fallback to local network IP (for mobile device testing)
    _baseUrl = 'http://192.168.31.81:8000/api';
    debugPrint('ApiConfig: Falling back to local network IP: $_baseUrl');
    if (await testConnectionWithUrl(_baseUrl!)) {
      return _baseUrl!;
    }

    throw Exception(
      'Could not discover server. Please ensure the server is running and on the same network.',
    );
  }

  // API endpoints
  static const String chatEndpoint = '/chat';
  static const String voiceChatEndpoint = '/voice_chat';
  static const String healthEndpoint = '/health';

  // Timeouts
  static const int connectionTimeoutSeconds = 10;
  static const int responseTimeoutSeconds = 30;

  static Future<bool> testConnection() async {
    try {
      final url = await baseUrl;
      return await testConnectionWithUrl(url);
    } catch (e) {
      debugPrint('ApiConfig: Connection test failed: $e');
      return false;
    }
  }

  static Future<bool> testConnectionWithUrl(String url) async {
    try {
      final response = await http
          .get(
            Uri.parse('$url$healthEndpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      debugPrint(
        'ApiConfig: Test connection to $url - Status: ${response.statusCode}',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiConfig: Test connection to $url failed: $e');
      return false;
    }
  }

  static void resetBaseUrl() {
    _baseUrl = null;
    debugPrint('ApiConfig: Base URL cache reset');
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
                  } else {
                    debugPrint(
                      'ApiConfig: Discovered server at $url is not reachable',
                    );
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

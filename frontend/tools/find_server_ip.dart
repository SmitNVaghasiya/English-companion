import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void main() async {
  debugPrint(
    'Finding available network interfaces and testing server connectivity...\n',
  );

  // Get all network interfaces
  final interfaces = await NetworkInterface.list();

  if (interfaces.isEmpty) {
    debugPrint('No network interfaces found!');
    return;
  }

  // Collect all IPv4 addresses
  final ipAddresses = <String>[];

  for (var interface in interfaces) {
    for (var addr in interface.addresses) {
      if (addr.type == InternetAddressType.IPv4) {
        ipAddresses.add(addr.address);
      }
    }
  }

  if (ipAddresses.isEmpty) {
    debugPrint('No IPv4 addresses found!');
    return;
  }

  debugPrint('Found ${ipAddresses.length} IPv4 addresses:');
  for (var ip in ipAddresses) {
    debugPrint('- $ip');
  }

  debugPrint('\nTesting connectivity to common server ports...');

  // Common ports to test (8000 is the default for most backends)
  final ports = [8000, 8080, 3000, 5000, 80, 443];

  // Common server endpoints to test
  final endpoints = ['', '/', '/health', '/api/health'];

  bool foundServer = false;

  // Test each IP with each port and endpoint
  for (var ip in ipAddresses) {
    for (var port in ports) {
      for (var endpoint in endpoints) {
        final url = 'http://$ip:$port$endpoint';

        try {
          debugPrint('Testing: $url');
          final response = await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 2));

          if (response.statusCode == 200) {
            debugPrint('✅ Found server at: $url');
            debugPrint('Response: ${response.body}');
            foundServer = true;

            // If this is not the root endpoint, suggest the base URL
            if (endpoint.isNotEmpty) {
              final baseUrl = 'http://$ip:$port';
              debugPrint('\n✅ Server is running at: $baseUrl');
              debugPrint('Update your .env file with:');
              debugPrint('BACKEND_URL=$baseUrl');
            }

            return;
          }
        } catch (e) {
          // Ignore timeouts and other errors
        }
      }
    }
  }

  if (!foundServer) {
    debugPrint(
      '\n❌ Could not find a running server on any of the tested ports.',
    );
    debugPrint(
      'Make sure your backend server is running and accessible from this machine.',
    );
  }
}

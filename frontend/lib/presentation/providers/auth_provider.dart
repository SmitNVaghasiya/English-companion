import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/env_config.dart';

/// Represents a user object returned from the authentication API
class UserOut {
  final String id;
  final String? username;
  final String email;
  final String? createdAt;
  final String? accessToken;

  UserOut({
    required this.id,
    this.username,
    required this.email,
    this.createdAt,
    this.accessToken,
  });

  factory UserOut.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final email = json['email'] as String?;
    if (id == null || email == null) {
      throw const FormatException('Invalid JSON: id and email are required');
    }
    return UserOut(
      id: id,
      username: json['username'] as String?,
      email: email,
      createdAt: json['created_at'] as String?,
      accessToken: json['access_token'] as String?,
    );
  }
}

/// Provides authentication state management using the Provider pattern
class AuthProvider with ChangeNotifier {
  String? _token;
  String _userId = '';
  String? _username;
  String? _email;
  bool _isLoading = false;

  // Secure storage for persisting authentication data
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Base URL from environment config, with fallback for development
  final String _baseUrl = EnvConfig.backendUrl ?? 'http://localhost:8000';

  // Getters for accessing authentication state
  String? get token => _token;
  String get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  /// Constructor that initializes the provider by loading persisted token
  AuthProvider() {
    loadToken();
  }

  /// Loads persisted authentication token and user details from secure storage
  Future<void> loadToken() async {
    try {
      _token = await _storage.read(key: 'auth_token');
      final userId = await _storage.read(key: 'user_id');
      if (userId != null) _userId = userId;
      _username = await _storage.read(key: 'username');
      _email = await _storage.read(key: 'email');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading token: $e');
    }
  }

  /// Saves authentication token and user details to secure storage
  Future<void> _saveToken({
    String? token,
    String? userId,
    String? username,
    String? email,
  }) async {
    try {
      if (token != null) await _storage.write(key: 'auth_token', value: token);
      if (userId != null) await _storage.write(key: 'user_id', value: userId);
      if (username != null) {
        await _storage.write(key: 'username', value: username);
      }
      if (email != null) await _storage.write(key: 'email', value: email);
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  /// Sets the loading state and notifies listeners
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Updates user details and persists them
  Future<void> updateUserDetails({
    required String token,
    required String userId,
    required String username,
    required String email,
  }) async {
    try {
      _token = token;
      _userId = userId;
      _username = username;
      _email = email;
      await _saveToken(
        token: token,
        userId: userId,
        username: username,
        email: email,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user details: $e');
      rethrow;
    }
  }

  /// Sends an OTP to the provided email for registration
  Future<void> sendOtp(String email) async {
    try {
      setLoading(true);
      final url = '$_baseUrl/auth/send-otp';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Unknown error';
        throw Exception('Failed to send OTP: $errorDetail');
      }
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Verifies the OTP for the provided email
  Future<void> verifyOtp(String email, String otp) async {
    try {
      setLoading(true);
      final url = '$_baseUrl/auth/verify-otp';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode != 200) {
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Unknown error';
        throw Exception('Failed to verify OTP: $errorDetail');
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Logs in the user with username or email and password
  Future<void> login(String usernameOrEmail, String password) async {
    try {
      setLoading(true);
      final url = '$_baseUrl/auth/login';
      final body = {'username': usernameOrEmail, 'password': password}.entries
          .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Failed to login: ${errorData['detail'] ?? response.body}',
        );
      }

      final data = jsonDecode(response.body);
      _token = data['access_token'];
      final userData = await _fetchUserDetails(data['access_token']);
      _userId = userData['id'];
      _username = userData['username'];
      _email = userData['email'];
      await _saveToken(
        token: _token!,
        userId: _userId,
        username: _username,
        email: _email,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error during login: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Fetches user details from the server using the access token
  Future<Map<String, dynamic>> _fetchUserDetails(String token) async {
    try {
      final url = '$_baseUrl/auth/me';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch user details');
      }

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      rethrow;
    }
  }

  /// Logs out the user and clears persisted data
  Future<void> logout() async {
    try {
      _token = null;
      _userId = '';
      _username = null;
      _email = null;
      await _storage.deleteAll();
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }
}

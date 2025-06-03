import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io' show SocketException;
import '../../data/services/chat_service.dart';
import '../../core/constants/app_strings.dart';
import '../../core/config/api_config.dart';

/// Utility class for chat-related functionality, providing methods for UI feedback,
/// error handling, and scroll management.
class ChatUtils {
  // Constants for SnackBar styling
  static const _snackBarDuration = Duration(seconds: 3);
  static const _snackBarBorderRadius = 8.0;
  static const _scrollAnimationDuration = Duration(milliseconds: 200);
  static const _defaultTimeout = Duration(seconds: 3);

  // Debounce timer for scrolling
  static Timer? _scrollDebounce;

  /// Shows a SnackBar with a message, optionally with a retry button for errors.
  /// Uses theme-based colors for consistency.
  static Future<void> testConnectionAndUpdateStatus({
    required ChatService chatService,
    required BuildContext context,
    required Function(String, String, bool) onUpdate,
    required VoidCallback onRetry,
  }) async {
    try {
      onUpdate('Connecting...', 'Testing connection to server...', false);
      
      final isConnected = await chatService.testConnection();
      
      if (isConnected) {
        onUpdate('Connected', 'Successfully connected to the server', false);
      } else {
        onUpdate('Disconnected', 'Could not connect to the server', true);
      }
    } catch (e) {
      debugPrint('Connection test failed: $e');
      onUpdate(
        'Error', 
        'Failed to connect to the server: ${e.toString()}', 
        true
      );
    }
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    VoidCallback? onRetry,
  }) {
    _handleError(() {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              if (isError && onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    AppStrings.retry,
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
            ],
          ),
          backgroundColor:
              isError ? theme.colorScheme.error : theme.colorScheme.primary,
          duration: _snackBarDuration,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_snackBarBorderRadius),
          ),
        ),
      );
    }, 'showing SnackBar');
  }

  /// Converts an exception into a user-friendly error message.
  static String getErrorMessage(Object error, String backendUrl) {
    return _handleError(
      () {
        if (error is TimeoutException) {
          return 'Request timed out. Check server connection at $backendUrl.';
        } else if (error is SocketException) {
          return 'Connection refused. The server at $backendUrl may be down.';
        } else if (error is http.ClientException) {
          return 'Unable to connect to the server at $backendUrl. Check your internet.';
        }
        return 'An unexpected error occurred: $error';
      },
      'parsing error message',
      defaultValue: 'An unexpected error occurred.',
    );
  }

  /// Scrolls to the bottom of a list with debouncing to prevent excessive animations.
  static void scrollToBottom(ScrollController controller) {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 100), () {
      _handleError(() {
        if (controller.hasClients) {
          controller.animateTo(
            controller.position.maxScrollExtent,
            duration: _scrollAnimationDuration,
            curve: Curves.easeOut,
          );
        }
      }, 'scrolling to bottom');
    });
  }

  /// Tests server connection and updates UI status.
  static Future<void> testConnection({
    required ChatService chatService,
    required BuildContext context,
    required ValueChanged<ConnectionStatus> onUpdate,
    VoidCallback? onRetry,
    Duration timeout = _defaultTimeout,
  }) async {
    await _handleErrorAsync(
      () async {
        onUpdate(
          ConnectionStatus.connecting('Checking server availability...'),
        );

        bool isConnected = await _testServer(chatService, timeout);

        if (!isConnected) {
          onUpdate(ConnectionStatus.connecting('Trying to find the server...'));
          ApiConfig.resetBaseUrl();
          try {
            await _testServer(chatService, timeout);
          } on SocketException {
            onUpdate(
              ConnectionStatus.failed(
                'Connection refused. The server may be down.',
                onRetry,
              ),
            );
          } on http.ClientException {
            onUpdate(
              ConnectionStatus.failed(
                'Unable to connect to the server. Check your internet.',
                onRetry,
              ),
            );
          } catch (e) {
            onUpdate(
              ConnectionStatus.failed(
                'An unexpected error occurred: $e',
                onRetry,
              ),
            );
          }
        }

        if (isConnected) {
          onUpdate(ConnectionStatus.connected('Connected successfully!'));
        } else {
          onUpdate(
            ConnectionStatus.failed(
              'Could not connect to the server. Please check your network and try again.',
              onRetry,
            ),
          );
        }
      },
      'testing connection',
      onError: (e) {
        final errorMessage = _getConnectionErrorMessage(e);
        onUpdate(ConnectionStatus.failed(errorMessage, onRetry));
      },
    );
  }

  /// Tests server connection with a timeout.
  static Future<bool> _testServer(
    ChatService chatService,
    Duration timeout,
  ) async {
    return await chatService.testConnection().timeout(
      timeout,
      onTimeout: () => false,
    );
  }

  /// Maps connection errors to user-friendly messages.
  static String _getConnectionErrorMessage(Object error) {
    if (error.toString().contains('connection refused')) {
      return 'Connection refused. The server may be down.';
    } else if (error is TimeoutException ||
        error.toString().contains('timed out')) {
      return AppStrings.serverNotResponding;
    }
    return AppStrings.networkError;
  }

  /// Centralized error handling for synchronous operations.
  static T _handleError<T>(
    T Function() operation,
    String operationName, {
    T? defaultValue,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      developer.log(
        'Error $operationName: $e',
        name: 'ChatUtils',
        stackTrace: stackTrace,
      );
      return defaultValue ?? (throw e);
    }
  }

  /// Centralized error handling for asynchronous operations.
  static Future<void> _handleErrorAsync(
    Future<void> Function() operation,
    String operationName, {
    void Function(Object)? onError,
  }) async {
    try {
      await operation();
    } catch (e, stackTrace) {
      developer.log(
        'Error $operationName: $e',
        name: 'ChatUtils',
        stackTrace: stackTrace,
      );
      onError?.call(e);
    }
  }
}

/// Represents the connection status for UI updates.
class ConnectionStatus {
  final String status;
  final String? message;
  final bool isError;
  final VoidCallback? onRetry;

  ConnectionStatus._(this.status, this.message, this.isError, this.onRetry);

  factory ConnectionStatus.connecting(String message) =>
      ConnectionStatus._(AppStrings.connecting, message, false, null);

  factory ConnectionStatus.connected(String message) =>
      ConnectionStatus._(AppStrings.connected, message, false, null);

  factory ConnectionStatus.failed(String message, VoidCallback? onRetry) =>
      ConnectionStatus._(AppStrings.connectionFailed, message, true, onRetry);
}

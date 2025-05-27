import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../data/services/chat_service.dart';
import '../../core/constants/app_strings.dart';
import '../../core/config/api_config.dart';

class ChatUtils {
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    VoidCallback? onRetry,
  }) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (isError && onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: const Text(
                    AppStrings.retry,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          backgroundColor:
              isError ? const Color(0xFFEF4444) : const Color(0xFF14B8A6),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      developer.log('Error showing SnackBar: $e', name: 'ChatUtils');
    }
  }

  static String getErrorMessage(Object e, String backendUrl) {
    try {
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('timed out')) {
        return 'Request timed out. Check server connection at $backendUrl.';
      } else if (e.toString().contains('Network error') ||
          e.toString().contains('Failed to connect') ||
          e.toString().contains('No internet connection') ||
          e.toString().contains('Network is unreachable')) {
        return 'Unable to connect to the server at $backendUrl. Check your internet.';
      } else if (e.toString().contains('Connection refused')) {
        return 'Connection refused. The server at $backendUrl may be down.';
      } else {
        return 'An unexpected error occurred: $e';
      }
    } catch (error) {
      developer.log('Error in getErrorMessage: $error', name: 'ChatUtils');
      return 'An unexpected error occurred.';
    }
  }

  static void scrollToBottom(ScrollController controller) {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.hasClients) {
          controller.animateTo(
            controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      developer.log('Error scrolling to bottom: $e', name: 'ChatUtils');
    }
  }

  static Future<void> testConnectionAndUpdateStatus({
    required ChatService chatService,
    required BuildContext context,
    required Function(String, String?, bool) onUpdate,
    VoidCallback? onRetry,
  }) async {
    try {
      onUpdate(AppStrings.connecting, 'Checking server availability...', false);

      bool isConnected = false;

      try {
        isConnected = await chatService.testConnection().timeout(
          const Duration(seconds: 3),
          onTimeout: () => false,
        );
      } catch (e) {
        developer.log(
          'Initial connection attempt failed: $e',
          name: 'ChatUtils',
        );
      }

      if (!isConnected) {
        onUpdate(AppStrings.connecting, 'Trying to find the server...', false);

        ApiConfig.resetBaseUrl();

        try {
          final workingUrl = await ApiConfig.baseUrl;
          developer.log(
            'Found working server at: $workingUrl',
            name: 'ChatUtils',
          );

          isConnected = await chatService.testConnection().timeout(
            const Duration(seconds: 5),
            onTimeout: () => false,
          );
        } catch (e) {
          developer.log('Failed to find working server: $e', name: 'ChatUtils');
        }
      }

      developer.log(
        'ChatUtils: Test connection result: $isConnected',
        name: 'ChatUtils',
      );

      if (isConnected) {
        onUpdate(AppStrings.connected, 'Connected successfully!', false);
      } else {
        onUpdate(
          AppStrings.connectionFailed,
          'Could not connect to the server. Please check your network and try again.',
          true,
        );
      }
    } catch (e) {
      developer.log('ChatUtils: Test connection error: $e', name: 'ChatUtils');
      String errorMessage = 'Failed to connect to the server.';

      if (e.toString().contains('Network is unreachable')) {
        errorMessage = AppStrings.networkError;
      } else if (e.toString().contains('Connection refused')) {
        errorMessage = 'Connection refused. The server may be down.';
      } else if (e.toString().contains('timed out')) {
        errorMessage = AppStrings.serverNotResponding;
      }

      onUpdate(AppStrings.connectionFailed, errorMessage, true);
    }
  }
}

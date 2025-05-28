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
          duration: const Duration(seconds: 3),
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
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('timeout')) {
        return 'Request timed out. Check server connection at $backendUrl.';
      } else if (errorStr.contains('network') ||
          errorStr.contains('failed to connect') ||
          errorStr.contains('no internet') ||
          errorStr.contains('unreachable')) {
        return 'Unable to connect to the server at $backendUrl. Check your internet.';
      } else if (errorStr.contains('connection refused')) {
        return 'Connection refused. The server at $backendUrl may be down.';
      }
      return 'An unexpected error occurred: $e';
    } catch (error) {
      developer.log('Error in getErrorMessage: $error', name: 'ChatUtils');
      return 'An unexpected error occurred.';
    }
  }

  static void scrollToBottom(ScrollController controller) {
    try {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
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

      bool isConnected = await chatService.testConnection().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );

      if (!isConnected) {
        onUpdate(AppStrings.connecting, 'Trying to find the server...', false);
        ApiConfig.resetBaseUrl();
        final workingUrl = await ApiConfig.baseUrl;
        isConnected = await chatService.testConnection().timeout(
          const Duration(seconds: 3),
          onTimeout: () => false,
        );
      }

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
      String errorMessage = AppStrings.networkError;
      if (e.toString().contains('connection refused')) {
        errorMessage = 'Connection refused. The server may be down.';
      } else if (e.toString().contains('timed out')) {
        errorMessage = AppStrings.serverNotResponding;
      }
      onUpdate(AppStrings.connectionFailed, errorMessage, true);
    }
  }
}

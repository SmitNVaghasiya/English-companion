import 'package:flutter/material.dart';
import '../../data/services/chat_service.dart';

class ChatUtils {
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
            if (isError)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: Text('Retry', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
        backgroundColor: isError ? Color(0xFFEF4444) : Color(0xFF14B8A6),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static String getErrorMessage(Object e, String backendUrl) {
    if (e.toString().contains('TimeoutException')) {
      return 'Request timed out. Check server connection at $backendUrl.';
    } else if (e.toString().contains('Network error') ||
        e.toString().contains('Failed to connect') ||
        e.toString().contains('No internet connection')) {
      return 'Unable to connect to the server at $backendUrl. Check your internet.';
    } else {
      return 'An unexpected error occurred: $e';
    }
  }

  static void scrollToBottom(ScrollController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  static Future<void> testConnectionAndUpdateStatus({
    required ChatService chatService,
    required Function(String, String?, bool) onUpdate,
  }) async {
    // Only show connecting status if we're not already in a failed state
    if (!onUpdate.toString().contains('Connection failed')) {
      onUpdate('Connecting...', 'Checking server availability', false);
    }

    try {
      final result = await chatService.testConnection().timeout(
        const Duration(seconds: 5), // Reduced from 10s to 5s for better UX
        onTimeout: () => {
          'connected': false,
          'message': 'Connection timed out',
        },
      );

      debugPrint('ChatUtils: Test connection result: $result');

      if (result['connected'] == true) {
        onUpdate(
          'Connected',
          result['message'] ?? 'Server is responding',
          false,
        );
      } else {
        // Only update to failed state if we're not already connected
        if (!onUpdate.toString().contains('Connected')) {
          onUpdate(
            'Connection failed',
            result['message'] ?? 'Server not available',
            true,
          );
        }
      }
    } catch (e) {
      debugPrint('ChatUtils: Test connection error: $e');
      // Only update to failed state if we're not already connected
      if (!onUpdate.toString().contains('Connected')) {
        onUpdate(
          'Connection failed',
          'Failed to connect: ${e.toString().replaceAll('Exception:', '').trim()}',
          true,
        );
      }
    }
  }
}

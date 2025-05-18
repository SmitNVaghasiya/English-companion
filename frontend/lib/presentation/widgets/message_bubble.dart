import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.role == 'user';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final timestamp =
        message.timestamp != null
            ? DateFormat('HH:mm').format(message.timestamp)
            : '';

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) const SizedBox(width: 4),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              child: IntrinsicWidth(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.telegramBlue
                        : (isDark ? AppColors.lightBlack : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!isUser && isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 15,
                            color: isUser
                                ? Colors.white
                                : (isDark ? Colors.grey[100] : Colors.black87),
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (timestamp.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          timestamp,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.2,
                            letterSpacing: 0.2,
                            color: isUser
                                ? Colors.white.withOpacity(0.85)
                                : (isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (!isUser) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

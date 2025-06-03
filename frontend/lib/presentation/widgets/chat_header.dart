import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import 'info_box.dart';

class ChatHeader extends StatelessWidget {
  final String title;
  final String description;
  final ConversationMode mode;
  final bool isVoiceMode;
  final VoidCallback? onBackPressed;

  const ChatHeader({
    super.key,
    required this.title,
    required this.description,
    required this.mode,
    this.isVoiceMode = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            if (onBackPressed != null)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackPressed,
                tooltip: 'Back',
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getModeText(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isVoiceMode ? Icons.mic : Icons.chat_bubble_outline,
                size: 20,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InfoBox(
          text: description,
          backgroundColor:
              isDark
                  ? AppColors.primaryColor.withValues(alpha: 0.15)
                  : AppColors.primaryColor.withValues(alpha: 0.08),
          borderColor: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _getModeText() {
    switch (mode) {
      case ConversationMode.dailyLife:
        return 'Daily Life Conversation${isVoiceMode ? ' - Voice Mode' : ' - Text Mode'}';
      case ConversationMode.beginnersHelper:
        return 'Beginners Helper${isVoiceMode ? ' - Voice Mode' : ' - Text Mode'}';
      case ConversationMode.professionalConversation:
        return 'Professional Conversation${isVoiceMode ? ' - Voice Mode' : ' - Text Mode'}';
      case ConversationMode.everydaySituations:
        return 'Everyday Situations${isVoiceMode ? ' - Voice Mode' : ' - Text Mode'}';
      case ConversationMode.custom:
        return 'Custom Conversation${isVoiceMode ? ' - Voice Mode' : ' - Text Mode'}';
      case ConversationMode.formal:
        return 'Formal Conversation${isVoiceMode ? ' - Voice Mode' : ' - Text Mode'}';
      case ConversationMode.informal:
        return 'Informal Conversation${isVoiceMode ? ' - Voice Mode' : ' - Text Mode'}';
    }
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final bool isVoiceMode;
  final VoidCallback onSend;
  final VoidCallback onVoice;
  final VoidCallback onClear;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.isVoiceMode,
    required this.onSend,
    required this.onVoice,
    required this.onClear,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateTextState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTextState);
    super.dispose();
  }

  void _updateTextState() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isDark ? AppColors.lightBlack : Colors.grey[100],
          boxShadow: [
            if (isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            else
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                enabled: !widget.isLoading && !widget.isVoiceMode,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.askAnything,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                    fontSize: 15,
                    height: 1.5,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (value) {
                  if (!widget.isLoading && value.trim().isNotEmpty) {
                    widget.onSend();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkGray : AppColors.lightGray,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed:
                        widget.isLoading
                            ? null
                            : (_hasText ? widget.onSend : widget.onVoice),
                    icon:
                        widget.isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark
                                      ? Colors.grey[400]!
                                      : Colors.grey[700]!,
                                ),
                              ),
                            )
                            : Icon(
                              _hasText ? Icons.send : Icons.mic,
                              color:
                                  _hasText || !_hasText
                                      ? AppColors.primaryColor
                                      : isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                              size: 20,
                            ),
                    splashRadius: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

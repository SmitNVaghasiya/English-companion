import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../providers/chat_provider.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final bool isVoiceMode;
  final VoidCallback onSend;
  final VoidCallback onClear;
  final bool isPlaying;
  final bool isRecording;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.isVoiceMode,
    required this.onSend,
    required this.onClear,
    this.isPlaying = false,
    this.isRecording = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with SingleTickerProviderStateMixin {
  bool _hasText = false;
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;
  VoiceStatus? _lastVoiceStatus;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateTextState);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _waveAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTextState);
    _animationController.dispose();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lastVoiceStatus =
        Provider.of<ChatProvider>(context, listen: false).state.voiceStatus;
  }

  @override
  void didUpdateWidget(ChatInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVoiceMode != oldWidget.isVoiceMode ||
        widget.isRecording != oldWidget.isRecording) {
      if (widget.isVoiceMode != oldWidget.isVoiceMode) {
        if (widget.isVoiceMode) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      }

      if (widget.isRecording != oldWidget.isRecording) {
        if (widget.isRecording) {
          _animationController.repeat(reverse: true);
        } else {
          _animationController.stop();
          _animationController.forward();
        }
      }
    }

    final provider = Provider.of<ChatProvider>(context, listen: false);
    final newStatus = provider.state.voiceStatus;

    if (_lastVoiceStatus != newStatus) {
      if (newStatus == VoiceStatus.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  provider.state.voiceStatusMessage ??
                      'An error occurred with audio',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      }
      _lastVoiceStatus = newStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<ChatProvider>(context);

    final voiceStatus = provider.state.voiceStatus;
    String statusMessage = '';

    switch (voiceStatus) {
      case VoiceStatus.recording:
        statusMessage =
            provider.state.isMuted
                ? 'Muted - Tap to unmute'
                : 'Listening... Speak now';
        break;
      case VoiceStatus.speaking:
        statusMessage = 'System is speaking...';
        break;
      case VoiceStatus.processing:
        statusMessage = 'Processing your message...';
        break;
      case VoiceStatus.error:
        statusMessage =
            provider.state.voiceStatusMessage ?? 'Audio error occurred';
        break;
      case VoiceStatus.idle:
        statusMessage =
            widget.isVoiceMode
                ? 'Tap the mic to start speaking'
                : 'Type a message or tap the mic';
        break;
    }

    String lastUserMessage = '';
    String lastAssistantMessage = '';

    if (provider.state.messages.isNotEmpty) {
      for (int i = provider.state.messages.length - 1; i >= 0; i--) {
        if (provider.state.messages[i].role == 'user') {
          lastUserMessage = provider.state.messages[i].content;
          break;
        }
      }

      for (int i = provider.state.messages.length - 1; i >= 0; i--) {
        if (provider.state.messages[i].role == 'assistant') {
          lastAssistantMessage = provider.state.messages[i].content;
          break;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        constraints: const BoxConstraints(minHeight: 56.0),
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
                  child: child,
                );
              },
              child:
                  widget.isVoiceMode
                      ? const SizedBox.shrink()
                      : Row(
                        key: const ValueKey('text_input_row'),
                        children: [
                          Expanded(
                            child: TextField(
                              key: const ValueKey('text_field'),
                              controller: widget.controller,
                              focusNode: widget.focusNode,
                              enabled: !widget.isLoading,
                              minLines: 1,
                              maxLines: 1,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[800],
                              ),
                              decoration: InputDecoration(
                                hintText: AppStrings.askAnything,
                                hintStyle: TextStyle(
                                  color: Colors.grey[500]!,
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
                                if (!widget.isLoading &&
                                    value.trim().isNotEmpty) {
                                  widget.onSend();
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: _buildActionButton(
                              context: context,
                              icon:
                                  widget.isLoading
                                      ? Icons.hourglass_empty
                                      : _hasText
                                      ? Icons.send
                                      : Icons.mic,
                              isDark: isDark,
                              onPressed:
                                  widget.isLoading
                                      ? () {}
                                      : _hasText
                                      ? widget.onSend
                                      : () => provider.toggleVoiceMode(context),
                              isActive: _hasText || !widget.isLoading,
                            ),
                          ),
                        ],
                      ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                    ),
                    child: child,
                  ),
                );
              },
              child: widget.isVoiceMode
                  ? Container(
                      key: const ValueKey('voice_container'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (statusMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.primaryColor.withOpacity(0.1)
                                      : AppColors.primaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primaryColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (widget.isRecording &&
                                        !provider.state.isMuted)
                                      FadeTransition(
                                        opacity: _waveAnimation,
                                        child: Row(
                                          children: List.generate(
                                            5,
                                            (index) => Container(
                                              width: 8,
                                              height: 8 + (index * 4),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      statusMessage,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.grey[200]
                                            : Colors.grey[800],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (lastUserMessage.isNotEmpty ||
                                lastAssistantMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[800]!.withOpacity(0.3)
                                        : Colors.grey[200]!.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (lastUserMessage.isNotEmpty) ...[
                                        Text(
                                          'You:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.grey[400]
                                                : Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          lastUserMessage,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark
                                                ? Colors.grey[300]
                                                : Colors.grey[800],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                      if (lastAssistantMessage.isNotEmpty) ...[
                                        Text(
                                          'Assistant:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          lastAssistantMessage,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                isDark
                                                    ? Colors.grey[300]
                                                    : Colors.grey[800],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  context: context,
                                  icon:
                                      provider.state.isMuted
                                          ? Icons.mic_off
                                          : Icons.mic,
                                  isDark: isDark,
                                  onPressed: () {
                                    provider.toggleMute();
                                    provider.toggleVoiceRecording(context);
                                  },
                                  isActive: widget.isRecording,
                                ),
                                _buildActionButton(
                                  context: context,
                                  icon:
                                      widget.isPlaying
                                          ? Icons.pause
                                          : Icons.volume_up,
                                  isDark: isDark,
                                  onPressed: () {
                                    if (widget.isPlaying) {
                                      provider.stopAllAudio();
                                    } else if (lastAssistantMessage
                                        .isNotEmpty) {
                                      provider.speak(lastAssistantMessage);
                                    }
                                  },
                                  isActive: widget.isPlaying,
                                ),
                                _buildActionButton(
                                  context: context,
                                  icon: Icons.close,
                                  isDark: isDark,
                                  onPressed: () {
                                    provider.stopAllAudio();
                                    widget.onClear();
                                  },
                                  isActive: false,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                      : const SizedBox(
                      key: ValueKey('empty_container'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required bool isDark,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.darkGray : AppColors.lightGray,
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          onPressed: onPressed,
          icon:
              widget.isLoading
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.grey[400]! : Colors.grey[700]!,
                      ),
                    ),
                  )
                  : Icon(
                    icon,
                    color:
                        isActive
                            ? AppColors.primaryColor
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    size: 24,
                  ),
          splashRadius: 24,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}

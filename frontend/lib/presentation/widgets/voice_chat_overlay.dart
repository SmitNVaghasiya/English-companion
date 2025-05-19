import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class VoiceChatOverlay extends StatefulWidget {
  final VoidCallback onCancel;
  final bool isConnected;
  final String initialState;
  final ValueChanged<String>? onStateChange;

  const VoiceChatOverlay({
    super.key,
    required this.onCancel,
    required this.isConnected,
    required this.initialState,
    this.onStateChange,
  });

  @override
  State<VoiceChatOverlay> createState() => _VoiceChatOverlayState();
}

class _VoiceChatOverlayState extends State<VoiceChatOverlay> {
  String _message = AppStrings.connecting;

  @override
  void initState() {
    super.initState();
    // Schedule the initial state update after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMessage(widget.initialState);
      if (widget.isConnected) {
        _updateMessage('listening');
      }
    });
  }

  @override
  void didUpdateWidget(VoiceChatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialState != oldWidget.initialState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMessage(widget.initialState);
      });
    }
    if (widget.isConnected != oldWidget.isConnected && widget.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMessage('listening');
      });
    }
  }

  void _updateMessage(String state) {
    setState(() {
      switch (state) {
        case 'connecting':
          _message = AppStrings.connecting;
          break;
        case 'listening':
          _message = 'Listening...';
          break;
        case 'processing':
          _message = 'Processing...';
          break;
        case 'speaking':
          _message = 'Speaking...';
          break;
        default:
          _message =
              widget.isConnected ? 'Start speaking...' : AppStrings.connecting;
      }
    });
    if (widget.onStateChange != null) {
      widget.onStateChange!(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconButton(Icons.mic, isDark, () {}),
                const SizedBox(width: 16),
                _buildIconButton(Icons.volume_up, isDark, () {}),
                const SizedBox(width: 16),
                _buildIconButton(Icons.close, isDark, widget.onCancel),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, bool isDark, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.darkGray : AppColors.lightGray,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primaryColor, size: 24),
        onPressed: onPressed,
        splashRadius: 28,
      ),
    );
  }
}

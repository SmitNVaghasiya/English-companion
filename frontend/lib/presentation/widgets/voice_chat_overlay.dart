// import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/constants/app_strings.dart';

// class VoiceChatOverlay extends StatefulWidget {
//   final VoidCallback onCancel;
//   final bool isConnected;
//   final bool isRecording;
//   final bool isPlaying;
//   final String initialState;
//   final ValueChanged<String>? onStateChange;

//   const VoiceChatOverlay({
//     super.key,
//     required this.onCancel,
//     required this.isConnected,
//     required this.isRecording,
//     required this.isPlaying,
//     required this.initialState,
//     this.onStateChange,
//   });

//   @override
//   State<VoiceChatOverlay> createState() => _VoiceChatOverlayState();
// }

// class _VoiceChatOverlayState extends State<VoiceChatOverlay>
//     with TickerProviderStateMixin {
//   String _message = AppStrings.connecting;
//   late AnimationController _waveController;
//   late Animation<double> _waveAnimation;
//   bool _isRecording = false;
//   bool _isPlaying = false;
//   bool _isMuted = false;

//   @override
//   void initState() {
//     super.initState();
//     _waveController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );
//     _waveAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
//       CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
//     );

//     _updateStateBasedOnProps();
//   }

//   @override
//   void didUpdateWidget(VoiceChatOverlay oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isRecording != oldWidget.isRecording ||
//         widget.isPlaying != oldWidget.isPlaying ||
//         widget.isConnected != oldWidget.isConnected) {
//       _updateStateBasedOnProps();
//     }
//   }

//   void _updateStateBasedOnProps() {
//     setState(() {
//       _isRecording = widget.isRecording;
//       _isPlaying = widget.isPlaying;
//     });

//     if (widget.isRecording) {
//       _updateMessage('listening');
//     } else if (widget.isPlaying) {
//       _updateMessage('speaking');
//     } else if (widget.isConnected) {
//       _updateMessage('ready');
//     } else {
//       _updateMessage('connecting');
//     }
//   }

//   void _updateMessage(String state) {
//     if (!mounted) return;

//     setState(() {
//       switch (state.toLowerCase()) {
//         case 'connecting':
//           _message = AppStrings.connecting;
//           _waveController.stop();
//           break;
//         case 'listening':
//         case 'recording':
//           _message = _isMuted ? 'Muted...' : 'Listening...';
//           if (!_isMuted)
//             _waveController.repeat(reverse: true);
//           else
//             _waveController.stop();
//           break;
//         case 'processing':
//           _message = 'Processing...';
//           _waveController.stop();
//           break;
//         case 'speaking':
//         case 'playing':
//           _message = 'Speaking...';
//           _waveController.stop();
//           break;
//         case 'ready':
//           _message = 'Start speaking...';
//           _waveController.stop();
//           break;
//         default:
//           _message = widget.isConnected ? 'Ready' : AppStrings.connecting;
//           _waveController.stop();
//       }
//     });

//     if (widget.onStateChange != null) {
//       widget.onStateChange!(state);
//     }
//   }

//   void _toggleMute() {
//     setState(() {
//       _isMuted = !_isMuted;
//       _updateMessage('listening');
//     });
//   }

//   void _togglePlayback() {
//     if (_isPlaying) {
//       _updateMessage('stop');
//     } else {
//       _updateMessage('speaking');
//     }
//   }

//   @override
//   void dispose() {
//     _waveController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Container(
//       color: Colors.black.withValues(alpha: 0.7),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               _message,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 24),
//             if (_message == 'Listening...' && !_isMuted)
//               FadeTransition(
//                 opacity: _waveAnimation,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     5,
//                     (index) => Container(
//                       width: 8,
//                       height: 8 + (index * 4),
//                       margin: const EdgeInsets.symmetric(horizontal: 4),
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryColor,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildIconButton(
//                   _isMuted ? Icons.mic_off : Icons.mic,
//                   isDark,
//                   _toggleMute,
//                 ),
//                 const SizedBox(width: 16),
//                 _buildIconButton(
//                   _isPlaying ? Icons.volume_off : Icons.volume_up,
//                   isDark,
//                   _togglePlayback,
//                 ),
//                 const SizedBox(width: 16),
//                 _buildIconButton(Icons.close, isDark, widget.onCancel),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildIconButton(IconData icon, bool isDark, VoidCallback onPressed) {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: isDark ? AppColors.darkGray : AppColors.lightGray,
//       ),
//       child: IconButton(
//         icon: Icon(icon, color: AppColors.primaryColor, size: 24),
//         onPressed: onPressed,
//         splashRadius: 28,
//       ),
//     );
//   }
// }

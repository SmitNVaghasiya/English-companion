import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:english_companion/data/models/message_model.dart';
import 'package:english_companion/presentation/providers/chat_provider.dart';
import 'package:english_companion/presentation/widgets/app_drawer.dart';
import 'package:english_companion/presentation/widgets/chat_input_field.dart';
import 'package:english_companion/presentation/widgets/message_bubble.dart';
import 'package:english_companion/presentation/widgets/voice_chat_overlay.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;
  final FlutterTts _flutterTts = FlutterTts();
  String _voiceOverlayState = 'connecting';
  bool _isOverlayOpen = false; // Track if overlay is open

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _typingAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _typingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Configure TTS
    _configureTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.testConnection();
      _addWelcomeMessage();
    });

    _inputFocusNode.addListener(() {
      if (_inputFocusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    // Optionally, set a specific voice (platform-dependent)
    await _flutterTts.setVoice({
      "name": "en-us-x-sfg#male_1-local",
      "locale": "en-US",
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _startTypingAnimation() {
    _typingAnimationController.repeat(reverse: true);
  }

  void _stopTypingAnimation() {
    _typingAnimationController.stop();
  }

  Future<void> _startVoiceChat(ChatProvider chatProvider) async {
    chatProvider.setVoiceMode(true);
    _startTypingAnimation();

    // Initialize state without setState() to avoid build-time updates
    _voiceOverlayState = 'connecting';
    _isOverlayOpen = true;

    // Show the voice chat overlay with dynamic states
    final GlobalKey<State> overlayKey = GlobalKey<State>();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder:
          (context) => VoiceChatOverlay(
            key: overlayKey,
            isConnected: chatProvider.connectionStatus == 'Connected',
            onCancel: () {
              Navigator.pop(context);
              chatProvider.setVoiceMode(false);
              _stopTypingAnimation();
              _isOverlayOpen = false;
            },
            initialState: _voiceOverlayState,
            onStateChange: (newState) {
              // Delay state update until after the build phase
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _voiceOverlayState = newState;
                });
              });
            },
          ),
    );

    try {
      // Update state to listening after build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _voiceOverlayState = 'listening';
        });
      });

      final response = await chatProvider.startVoiceChat();

      // Update state to processing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _voiceOverlayState = 'processing';
        });
      });

      if (response != null) {
        chatProvider.addMessage(response);

        // Update state to speaking
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _voiceOverlayState = 'speaking';
          });
        });

        // Play the response using TTS
        await _flutterTts.speak(response.content);
        await _flutterTts.awaitSpeakCompletion(true);
      }
    } catch (e) {
      debugPrint('Error in _startVoiceChat: $e');
      final errorMessage = MessageModel(
        content:
            'Failed to process voice request: ${e.toString()}. Please try again.',
        role: 'system',
        timestamp: DateTime.now(),
      );
      chatProvider.addMessage(errorMessage);
    } finally {
      chatProvider.setVoiceMode(false);
      _stopTypingAnimation();
      _scrollToBottom();
      // Close the overlay if it's still open
      if (_isOverlayOpen) {
        Navigator.pop(context);
        _isOverlayOpen = false;
      }
    }
  }

  void _addWelcomeMessage() {
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.messages.isEmpty) {
      chatProvider.addMessage(
        MessageModel(
          content:
              'Hello! I\'m your English learning assistant. How can I help you today?',
          role: 'assistant',
          timestamp: DateTime.now(),
        ),
      );
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _queryController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _sendQuery() async {
    final message = _queryController.text.trim();
    if (message.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();

    final userMessage = MessageModel(
      content: message,
      role: 'user',
      timestamp: DateTime.now(),
    );
    chatProvider.addMessage(userMessage);

    _queryController.clear();
    _inputFocusNode.unfocus();

    _scrollToBottom();

    try {
      chatProvider.setLoading(true);
      _startTypingAnimation();

      final response = await chatProvider.sendQuery(userMessage);

      if (response != null) {
        chatProvider.addMessage(response);
      }
    } catch (e) {
      debugPrint('Error in _sendQuery: $e');
      final errorMessage = MessageModel(
        content: 'Sorry, something went wrong. Please try again.',
        role: 'system',
        timestamp: DateTime.now(),
      );
      chatProvider.addMessage(errorMessage);
    } finally {
      chatProvider.setLoading(false);
      _stopTypingAnimation();
      _scrollToBottom();
    }
  }

  PreferredSizeWidget _buildAppBar(ChatProvider chatProvider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      toolbarHeight: 68, // Keep the increased height
      titleSpacing: 0, // Remove default title spacing
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: const Icon(Icons.menu),
              // iconSize: 32,
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Open menu',
            ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'English Companion',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap:
                  chatProvider.connectionStatus == 'Connection failed'
                      ? () => chatProvider.testConnection()
                      : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color:
                          chatProvider.connectionStatus == 'Connected'
                              ? Colors.green
                              : chatProvider.connectionStatus == 'Connecting...'
                              ? Colors.orange
                              : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    chatProvider.connectionStatus,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color:
                          chatProvider.connectionStatus == 'Connected'
                              ? Colors.green[400]
                              : chatProvider.connectionStatus == 'Connecting...'
                              ? Colors.orange[400]
                              : Colors.red[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: isDark ? Colors.amber : Colors.blueGrey,
          ),
          onPressed: () => chatProvider.toggleTheme(context),
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          appBar: _buildAppBar(chatProvider, theme),
          drawer: const AppDrawer(),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    chatProvider.messages.isEmpty
                        ? const Center(
                          child: Text(
                            'Start a conversation!',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: chatProvider.messages.length,
                          itemBuilder: (context, index) {
                            return MessageBubble(
                              message: chatProvider.messages[index],
                            );
                          },
                        ),
                    if (chatProvider.connectionStatus == 'Connection failed' &&
                        chatProvider.isConnecting)
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Connecting to server...',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  if (chatProvider.connectionMessage !=
                                      null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      chatProvider.connectionMessage!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed:
                                          () => chatProvider.testConnection(),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (chatProvider.isLoading)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: theme.scaffoldBackgroundColor.withOpacity(0.9),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              FadeTransition(
                                opacity: _typingAnimation,
                                child: Row(
                                  children: [
                                    TypingDot(animation: _typingAnimation),
                                    const SizedBox(width: 4),
                                    TypingDot(animation: _typingAnimation),
                                    const SizedBox(width: 4),
                                    TypingDot(animation: _typingAnimation),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text('Assistant is typing...'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              ChatInputField(
                controller: _queryController,
                focusNode: _inputFocusNode,
                isLoading: chatProvider.isLoading,
                isVoiceMode: chatProvider.isVoiceMode,
                onSend: _sendQuery,
                onVoice: () => _startVoiceChat(chatProvider),
                onClear: () => _queryController.clear(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TypingDot extends StatelessWidget {
  final Animation<double> animation;

  const TypingDot({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

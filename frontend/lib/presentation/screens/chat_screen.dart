import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/message_model.dart';
import '../providers/chat_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final bool initialVoiceMode;

  const ChatScreen({super.key, this.initialVoiceMode = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.clearMessages();
      chatProvider.testConnection(context);
      _addWelcomeMessage();

      if (widget.initialVoiceMode) {
        chatProvider.toggleVoiceMode(context);
      }
    });

    _inputFocusNode.addListener(() {
      if (_inputFocusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startTypingAnimation() {
    _typingAnimationController.repeat(reverse: true);
  }

  void _stopTypingAnimation() {
    _typingAnimationController.stop();
  }

  void _addWelcomeMessage() {
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.state.messages.isEmpty) {
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
      _startTypingAnimation();
      final response = await chatProvider.sendQuery(userMessage);
      if (response != null) {
        chatProvider.addMessage(response);
      }
    } catch (e) {
      debugPrint('ChatScreen: Error in _sendQuery: $e');
      final errorMessage = MessageModel(
        content: 'Sorry, something went wrong. Please try again.',
        role: 'system',
        timestamp: DateTime.now(),
      );
      chatProvider.addMessage(errorMessage);
    } finally {
      _stopTypingAnimation();
      _scrollToBottom();
    }
  }

  PreferredSizeWidget _buildAppBar(ChatProvider chatProvider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      toolbarHeight: 68,
      titleSpacing: 0,
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: const Icon(Icons.menu),
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
                  chatProvider.state.connectionStatus == 'Connection failed'
                      ? () => chatProvider.testConnection(context)
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
                          chatProvider.state.connectionStatus == 'Connected'
                              ? Colors.green
                              : chatProvider.state.connectionStatus ==
                                  'Connecting...'
                              ? Colors.orange
                              : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    chatProvider.state.connectionStatus,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color:
                          chatProvider.state.connectionStatus == 'Connected'
                              ? Colors.green[400]
                              : chatProvider.state.connectionStatus ==
                                  'Connecting...'
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
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: _buildAppBar(chatProvider, theme),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child:
                chatProvider.state.messages.isEmpty
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
                      itemCount: chatProvider.state.messages.length,
                      itemBuilder: (context, index) {
                        return MessageBubble(
                          message: chatProvider.state.messages[index],
                        );
                      },
                    ),
          ),
          ChatInputField(
            controller: _queryController,
            focusNode: _inputFocusNode,
            isLoading: chatProvider.state.isLoading,
            isVoiceMode: chatProvider.state.isVoiceMode,
            isRecording:
                chatProvider.state.voiceStatus == VoiceStatus.recording,
            isPlaying: chatProvider.state.voiceStatus == VoiceStatus.speaking,
            onSend: _sendQuery,
            onClear: () => _queryController.clear(),
          ),
          if (chatProvider.state.isLoading)
            Container(
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
        ],
      ),
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

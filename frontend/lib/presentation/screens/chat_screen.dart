import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/message_model.dart';
import '../providers/chat_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/message_bubble.dart';
import 'conversation_mode_screen.dart';

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

      // Set voice mode if needed, but don't navigate away
      if (widget.initialVoiceMode) {
        chatProvider.toggleVoiceMode(context);
      }

      // Check if conversation mode is set
      if (chatProvider.state.conversationMode == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ConversationModeScreen(
                  isVoiceMode: widget.initialVoiceMode,
                ),
          ),
        );
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

  Widget _buildChatHeader(ChatProvider chatProvider) {
    final mode = chatProvider.state.conversationMode ?? ConversationMode.custom;
    String title = 'English Companion';
    String description = '';

    switch (mode) {
      case ConversationMode.dailyLife:
        description = AppStrings.dailyLifeGreeting;
        break;
      case ConversationMode.beginnersHelper:
        description = AppStrings.beginnersHelperGreeting;
        break;
      case ConversationMode.professionalConversation:
        description = AppStrings.professionalConversationGreeting;
        break;
      case ConversationMode.everydaySituations:
        description = AppStrings.everydaySituationsGreeting;
        break;
      case ConversationMode.formal:
        description =
            "Greetings! I am your English Companion for formal conversations. How may I assist you in a professional setting today?";
        break;
      case ConversationMode.informal:
        description =
            "Hey there! I'm your English Companion for casual chats. What's up? Let's talk like friends!";
        break;
      case ConversationMode.custom:
        description =
            "Hi! I'm ready to talk about any topic you choose. What would you like to discuss today?";
        break;
    }

    return ChatHeader(
      title: title,
      description: description,
      mode: mode,
      isVoiceMode: chatProvider.state.isVoiceMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatProvider = context.watch<ChatProvider>();
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDark ? Colors.black12 : Colors.white.withValues(alpha: 0.1),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Open menu',
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
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [const Color(0xFF1A1A1A), const Color(0xFF0D0D0D)]
                    : [Colors.white, const Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildChatHeader(chatProvider),
              ),
              Expanded(
                child:
                    chatProvider.state.messages.isEmpty
                        ? Center(
                          child: Text(
                            'Start a conversation!',
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
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
                isPlaying:
                    chatProvider.state.voiceStatus == VoiceStatus.speaking,
                onSend: _sendQuery,
                onClear: () => _queryController.clear(),
              ),
              if (chatProvider.state.isLoading)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
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
        ),
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

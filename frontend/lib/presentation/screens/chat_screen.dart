import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_companion/data/models/message_model.dart';
import 'package:english_companion/presentation/providers/chat_provider.dart';
import 'package:english_companion/presentation/widgets/app_drawer.dart';
import 'package:english_companion/presentation/widgets/chat_input_field.dart';
import 'package:english_companion/presentation/widgets/message_bubble.dart';

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

    // Add initial message and test connection
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
  
  void _addWelcomeMessage() {
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.messages.isEmpty) {
      chatProvider.addMessage(
        MessageModel(
          content: 'Hello! I\'m your English learning assistant. How can I help you today?',
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
    
    // Add user message
    final userMessage = MessageModel(
      content: message,
      role: 'user',
      timestamp: DateTime.now(),
    );
    chatProvider.addMessage(userMessage);

    // Clear input field
    _queryController.clear();
    _inputFocusNode.unfocus();

    // Scroll to bottom
    _scrollToBottom();

    try {
      // Show loading state
      chatProvider.setLoading(true);
      _startTypingAnimation();

      // Send message to backend
      final response = await chatProvider.sendQuery(userMessage);

      // Add bot response if available
      if (response != null) {
        chatProvider.addMessage(response);
      }
    } catch (e) {
      debugPrint('Error in _sendQuery: $e');
      // Show error message
      final errorMessage = MessageModel(
        content: 'Sorry, something went wrong. Please try again.',
        role: 'system',
        timestamp: DateTime.now(),
      );
      chatProvider.addMessage(errorMessage);
    } finally {
      // Hide loading state
      chatProvider.setLoading(false);
      _stopTypingAnimation();
      _scrollToBottom();
    }
  }

  // Removed unused _clearChat method as it's not being used

  PreferredSizeWidget _buildAppBar(ChatProvider chatProvider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0), // Add padding above the title
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
            const SizedBox(height: 4), // Slightly increased spacing
            // Connection status indicator - moved below the title
            GestureDetector(
              onTap: chatProvider.connectionStatus == 'Connection failed'
                  ? () => chatProvider.testConnection()
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 8, // Slightly larger dot
                    height: 8, // Slightly larger dot
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: chatProvider.connectionStatus == 'Connected'
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
                      fontSize: 12, // Increased font size
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: chatProvider.connectionStatus == 'Connected'
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
        // Theme toggle
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: isDark ? Colors.amber : Colors.blueGrey,
          ),
          onPressed: () => chatProvider.toggleTheme(context),
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
        ),
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
                    // Chat messages
                    chatProvider.messages.isEmpty
                        ? const Center(
                            child: Text(
                              'Start a conversation!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
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
                    
                    // Show connecting overlay only when there's a connection issue
                    if (chatProvider.connectionStatus == 'Connection failed' && chatProvider.isConnecting)
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
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  if (chatProvider.connectionMessage != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      chatProvider.connectionMessage!,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () => chatProvider.testConnection(),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Typing indicator
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
              // Message input field
              ChatInputField(
                controller: _queryController,
                focusNode: _inputFocusNode,
                isLoading: chatProvider.isLoading,
                onSend: _sendQuery,
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

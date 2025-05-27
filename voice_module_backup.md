import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_endpoints.dart';
import '../../core/config/env_config.dart';
import '../../core/utils/connection_utils.dart';
import '../models/chat_response.dart';
import 'api_service.dart';

class ChatService {
  late ApiService _apiService;
  late String _baseUrl = '';
  bool _isInitialized = false;
  final AudioRecorder _recorder = AudioRecorder();

  ChatService();

  Future<Map<String, dynamic>> testConnection() async {
    try {
      debugPrint('ChatService: Starting connection test...');
      await _initialize();
      debugPrint('ChatService: After _initialize(), _baseUrl = $_baseUrl');

      if (!await ConnectionUtils.hasInternetConnection()) {
        final message =
            'No internet connection. Please check your network and try again.';
        debugPrint('ChatService: $message');
        return {'connected': false, 'message': message};
      }

      if (_baseUrl.isEmpty) {
        return {'connected': false, 'message': 'Server URL is not configured.'};
      }

      final cleanBaseUrl =
          _baseUrl.endsWith('/')
              ? _baseUrl.substring(0, _baseUrl.length - 1)
              : _baseUrl;
      final healthUrl = '$cleanBaseUrl${AppEndpoints.health}';
      debugPrint('ChatService: Testing connection to: $healthUrl');

      try {
        final response = await _apiService
            .get(AppEndpoints.health)
            .timeout(const Duration(seconds: 5));

        debugPrint('ChatService: Health response: $response');
        if (response['status'] == 'ok') {
          return {
            'connected': true,
            'message': 'Successfully connected to the server',
          };
        }

        return {
          'connected': false,
          'message':
              'Server responded with an unexpected status: ${response['status']}',
        };
      } catch (e) {
        debugPrint('ChatService: Connection test failed: $e');
        if (e is TimeoutException) {
          return {
            'connected': false,
            'message':
                'Connection timed out. The server at $cleanBaseUrl is not responding.',
          };
        } else if (e is SocketException) {
          return {
            'connected': false,
            'message':
                'Could not connect to the server at $cleanBaseUrl. Please check the URL and network.',
          };
        }
        return {
          'connected': false,
          'message':
              'Failed to connect to the server: ${e.toString().replaceAll('Exception:', '').trim()}',
        };
      }
    } catch (e) {
      debugPrint('ChatService: Error in testConnection: $e');
      return {
        'connected': false,
        'message':
            'Failed to connect to the server: ${e.toString().replaceAll('Exception:', '').trim()}',
      };
    }
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      final envUrl = EnvConfig.backendUrl;
      if (envUrl != null && envUrl.isNotEmpty) {
        String cleanUrl = envUrl.trim();
        if (!cleanUrl.endsWith('/')) {
          cleanUrl = '$cleanUrl/';
        }

        debugPrint('ChatService: Testing environment URL: $cleanUrl');
        final isReachable = await ConnectionUtils.testConnectionToUrl(cleanUrl);
        debugPrint(
          'ChatService: Environment URL $cleanUrl reachable: $isReachable',
        );

        if (isReachable) {
          _baseUrl = cleanUrl;
          _apiService = ApiService(_baseUrl);
          debugPrint('ChatService: Using environment server URL: $_baseUrl');
          _isInitialized = true;
          return;
        } else {
          debugPrint(
            'ChatService: Environment URL $cleanUrl is not reachable.',
          );
        }
      } else {
        debugPrint('ChatService: No environment URL found in .env file.');
      }

      debugPrint('ChatService: Trying auto-discovery for server URL');
      try {
        final serverUrl = await ConnectionUtils.findServerUrl();
        if (serverUrl != null) {
          _baseUrl = serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
          _apiService = ApiService(_baseUrl);
          debugPrint('ChatService: Using discovered server URL: $_baseUrl');
          _isInitialized = true;
          return;
        }
      } catch (e) {
        debugPrint('ChatService: Error during server discovery: $e');
      }

      debugPrint('ChatService: Trying localhost as fallback');
      const localUrl = 'http://localhost:8000/';
      final isLocalReachable = await ConnectionUtils.testConnectionToUrl(
        localUrl,
      );
      debugPrint('ChatService: Localhost reachable: $isLocalReachable');

      if (isLocalReachable) {
        _baseUrl = localUrl;
        _apiService = ApiService(_baseUrl);
        debugPrint('ChatService: Using localhost as server URL');
      } else {
        if (envUrl != null && envUrl.isNotEmpty) {
          _baseUrl = envUrl.endsWith('/') ? envUrl : '$envUrl/';
        } else {
          _baseUrl = localUrl;
        }
        _apiService = ApiService(_baseUrl);
        debugPrint('ChatService: Using fallback server URL: $_baseUrl');
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('ChatService: Error during initialization: $e');
      _baseUrl = 'http://localhost:8000/';
      _apiService = ApiService(_baseUrl);
      _isInitialized = true;
      rethrow;
    }
  }

  String get backendUrl {
    // Ensure no double slashes in the URL
    final cleanBaseUrl = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return cleanBaseUrl;
  }

  Future<ChatResponse> sendQuery(List<Map<String, dynamic>> messages) async {
    try {
      await _initialize();

      if (!await ConnectionUtils.hasInternetConnection()) {
        debugPrint('ChatService: No internet connection available');
        return ChatResponse(
          status: 'error',
          role: 'system',
          content:
              'No internet connection. Please check your network and try again.',
          timestamp: DateTime.now(),
        );
      }

      if (messages.isEmpty) {
        debugPrint('ChatService: No messages to send');
        return ChatResponse(
          status: 'error',
          role: 'system',
          content: 'No message content provided',
          timestamp: DateTime.now(),
        );
      }

      debugPrint(
        'ChatService: Sending message to server: ${messages.last['content']}',
      );

      final apiMessages = messages
          .map(
            (msg) => {
              'role': msg['role'] == 'user' ? 'user' : 'assistant',
              'content': msg['content'] ?? '',
              'timestamp': msg['timestamp']?.toString() ??
                  DateTime.now().toIso8601String(),
            },
          )
          .toList();

      final response = await _apiService.post(AppEndpoints.chat, {
        'messages': apiMessages,
      });

      debugPrint('ChatService: Received response: $response');
      return ChatResponse.fromMap({
        'status': 'success',
        'role': response['role'] ?? 'assistant',
        'content': response['content'] ?? 'No response content',
        'timestamp': response['timestamp'] ?? DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('ChatService: Error in sendQuery: $e');
      return ChatResponse(
        status: 'error',
        role: 'system',
        content: e is SocketException
            ? 'Could not connect to the server. Please check your connection.'
            : e.toString().contains('timed out')
                ? 'Request timed out. Please try again.'
                : 'An unexpected error occurred: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  Future<ChatResponse> sendVoiceQuery() async {
    String? audioPath; // Declare audioPath at method scope
    try {
      await _initialize();

      if (!await ConnectionUtils.hasInternetConnection()) {
        debugPrint('ChatService: No internet connection available');
        return ChatResponse(
          status: 'error',
          role: 'system',
          content:
              'No internet connection. Please check your network and try again.',
          timestamp: DateTime.now(),
        );
      }

      // Check microphone permission
      debugPrint('ChatService: Checking microphone permission');
      if (!await _recorder.hasPermission()) {
        debugPrint('ChatService: Microphone permission denied');
        return ChatResponse(
          status: 'error',
          role: 'system',
          content: 'Microphone permission is required for voice chat.',
          timestamp: DateTime.now(),
        );
      }
      debugPrint('ChatService: Microphone permission granted');

      // Record audio
      debugPrint('ChatService: Starting audio recording');
      final directory = await getTemporaryDirectory();
      audioPath = '${directory.path}/voice_input.wav';
      debugPrint('ChatService: Audio will be saved to: $audioPath');
      await _recorder.start(const RecordConfig(
        encoder: AudioEncoder.wav, // Use WAV for server compatibility
        sampleRate: 16000,
      ), path: audioPath);
      debugPrint('ChatService: Recording started');

      // Record for a longer duration (10 seconds) to ensure enough time to speak
      await Future.delayed(const Duration(seconds: 10));
      debugPrint('ChatService: Stopping audio recording');
      await _recorder.stop();
      debugPrint('ChatService: Recording stopped');

      // Check if the file exists
      final audioFile = File(audioPath);
      if (await audioFile.exists()) {
        debugPrint('ChatService: Audio file exists at: $audioPath');
        final fileSize = await audioFile.length();
        debugPrint('ChatService: Audio file size: $fileSize bytes');
      } else {
        debugPrint('ChatService: Audio file does not exist');
        return ChatResponse(
          status: 'error',
          role: 'system',
          content: 'Failed to record audio. Please try again.',
          timestamp: DateTime.now(),
        );
      }

      // Send audio to server
      final voiceChatUrl = '${backendUrl}${AppEndpoints.voiceChat}';
      debugPrint('ChatService: Preparing to send request to $voiceChatUrl');
      final request = http.MultipartRequest('POST', Uri.parse(voiceChatUrl));
      request.files.add(await http.MultipartFile.fromPath('file', audioPath));
      debugPrint('ChatService: Sending request...');
      final response = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('ChatService: Request timed out');
          throw TimeoutException('Request timed out');
        },
      );
      debugPrint('ChatService: Request sent, status code: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      debugPrint('ChatService: Received response: $responseBody');

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(responseBody);
        return ChatResponse.fromMap({
          'status': 'success',
          'role': responseJson['role'] ?? 'assistant',
          'content': responseJson['content'] ?? 'No response content',
          'timestamp':
              responseJson['timestamp'] ?? DateTime.now().toIso8601String(),
        });
      } else {
        debugPrint('ChatService: Server error: ${response.statusCode}');
        return ChatResponse(
          status: 'error',
          role: 'system',
          content: 'Server error: ${response.statusCode} - $responseBody',
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('ChatService: Error in sendVoiceQuery: $e');
      return ChatResponse(
        status: 'error',
        role: 'system',
        content: e is SocketException
            ? 'Could not connect to the server. Please check your connection.'
            : e.toString().contains('timed out')
                ? 'Request timed out. Please try again.'
                : 'Failed to process voice request: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    } finally {
      // Clean up the audio file if it was created
      if (audioPath != null) {
        final audioFile = File(audioPath);
        if (await audioFile.exists()) {
          await audioFile.delete();
          debugPrint('ChatService: Cleaned up audio file');
        }
      }
    }
  }
}



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
    await _flutterTts.setVoice({"name": "en-us-x-sfg#male_1-local", "locale": "en-US"});
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
      builder: (context) => VoiceChatOverlay(
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
        content: 'Failed to process voice request: ${e.toString()}. Please try again.',
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
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0),
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
            const SizedBox(height: 4),
            GestureDetector(
              onTap: chatProvider.connectionStatus == 'Connection failed'
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
                      fontSize: 12,
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
                                      onPressed: () =>
                                          chatProvider.testConnection(),
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
          _message = widget.isConnected ? 'Start speaking...' : AppStrings.connecting;
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




import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/message_model.dart';
import '../../data/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isConnecting = false;
  bool _isVoiceMode = false;
  String _connectionStatus = '';
  String? _connectionMessage;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isConnecting => _isConnecting;
  bool get isVoiceMode => _isVoiceMode;
  String get connectionStatus => _connectionStatus;
  String? get connectionMessage => _connectionMessage;

  void addMessage(MessageModel message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  Future<MessageModel?> sendQuery(MessageModel message) async {
    try {
      _isLoading = true;
      _isConnecting = true;
      notifyListeners();

      final messages = [
        {'role': message.role, 'content': message.content},
      ];

      final response = await _chatService.sendQuery(messages);

      _connectionStatus = 'Connected';
      _connectionMessage = 'Server is responding';

      return MessageModel(
        content: response.content,
        role: response.role,
        timestamp: response.timestamp,
      );
    } catch (e) {
      debugPrint('Error in sendQuery: $e');
      _connectionStatus = 'Connection failed';
      _connectionMessage = 'Error: ${e.toString()}';

      return MessageModel(
        content: 'Sorry, something went wrong. Please try again.',
        role: 'system',
        timestamp: DateTime.now(),
      );
    } finally {
      _isLoading = false;
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<MessageModel?> startVoiceChat() async {
    try {
      _isLoading = true;
      _isVoiceMode = true;
      notifyListeners();

      final response = await _chatService.sendVoiceQuery();

      _connectionStatus = 'Connected';
      _connectionMessage = 'Server is responding';

      return MessageModel(
        content: response.content,
        role: response.role,
        timestamp: response.timestamp,
      );
    } catch (e) {
      debugPrint('Error in startVoiceChat: $e');
      _connectionStatus = 'Connection failed';
      _connectionMessage = 'Error: ${e.toString()}';

      return MessageModel(
        content: 'Failed to process voice request. Please try again.',
        role: 'system',
        timestamp: DateTime.now(),
      );
    } finally {
      _isLoading = false;
      _isVoiceMode = false;
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setVoiceMode(bool voiceMode) {
    if (_isVoiceMode != voiceMode) {
      _isVoiceMode = voiceMode;
      notifyListeners();
    }
  }

  Future<void> testConnection() async {
    if (_isConnecting) return;

    _isConnecting = true;
    _connectionStatus = 'Connecting...';
    _connectionMessage = 'Checking server availability';
    notifyListeners();

    try {
      final result = await _chatService.testConnection();
      if (result['connected'] == true) {
        _connectionStatus = 'Connected';
        _connectionMessage = result['message'] ?? 'Server is responding';
      } else {
        _connectionStatus = 'Connection failed';
        _connectionMessage =
            result['message'] ?? 'Could not connect to the server';
      }
    } catch (e) {
      debugPrint('Connection test failed: $e');
      _connectionStatus = 'Connection failed';
      _connectionMessage = 'Error checking connection: ${e.toString()}';
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void clearConnectionStatus() {
    if (_connectionStatus != 'Connected') {
      _connectionStatus = 'Connecting...';
      _connectionMessage = 'Checking connection...';
      _isConnecting = true;
      notifyListeners();

      testConnection();
    } else {
      notifyListeners();
    }
  }

  void toggleTheme(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
  }
}





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
                    onPressed: widget.isLoading
                        ? null
                        : (_hasText ? widget.onSend : widget.onVoice),
                    icon: widget.isLoading
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
                            _hasText ? Icons.send : Icons.mic,
                            color: _hasText || !_hasText
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



from fastapi import APIRouter, HTTPException, UploadFile, File, Request, status
from app.models.message import ChatInput
from app.services.groq_service import get_chat_response
from app.services.stt_service import voice_to_text
from datetime import datetime
import logging
from typing import Dict

logger = logging.getLogger(__name__)
router = APIRouter()

def get_current_timestamp() -> str:
    """Get current ISO formatted timestamp."""
    return datetime.now().isoformat()

@router.post("/chat")
async def chat(input: ChatInput, request: Request):
    """Handle text-based chat messages and return AI response."""
    try {
        logger.info("Received /chat request")
        messages = [{"role": msg.role, "content": msg.content} for msg in input.messages]
        response_content = get_chat_response(messages, request.app.state.groq_client)
        logger.info(f"Chat response generated: {response_content}")
        return {
            "role": "assistant",
            "content": response_content,
            "timestamp": get_current_timestamp()
        }
    } except HTTPException as he:
        logger.error(f"HTTPException in /chat: {str(he)}")
        raise he
    except Exception as e:
        logger.error(f"Error in /chat: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error processing chat request: {str(e)}")

@router.post("/voice_chat")
async def voice_chat(request: Request, file: UploadFile = File(...)):
    """Handle voice input from an uploaded audio file and return AI response."""
    try {
        logger.info("Received /voice_chat request")
        audio_bytes = await file.read()
        logger.info(f"Audio file received, size: {len(audio_bytes)} bytes")
        user_text = voice_to_text(audio_bytes)
        logger.info(f"Transcribed text: {user_text}")
        messages = [{"role": "user", "content": user_text}]
        response_content = get_chat_response(messages, request.app.state.groq_client)
        logger.info(f"Voice chat response generated: {response_content}")
        return {
            "role": "assistant",
            "content": response_content,
            "timestamp": get_current_timestamp()
        }
    } except HTTPException as he:
        logger.error(f"HTTPException in /voice_chat: {str(he)}")
        raise he
    except Exception as e:
        logger.error(f"Error in /voice_chat: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to process voice request")

@router.post("/end")
async def end_conversation():
    """End the conversation."""
    try {
        logger.info("Received /end request")
        return {
            "role": "system",
            "content": "Thank you for practicing! Start a new session anytime.",
            "timestamp": get_current_timestamp()
        }
    } except Exception as e:
        logger.error(f"Error in /end: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to end conversation")

@router.get("/")
@router.get("/health")
async def health_check():
    """Health check endpoint."""
    try {
        logger.info("Received /health request")
        return {
            "status": "ok",
            "timestamp": get_current_timestamp(),
            "service": "English Companion API",
            "version": "1.0.0"
        }
    } except Exception as e:
        logger.error(f"Error in /health: {str(e)}")
        raise HTTPException(status_code=500, detail="Health check failed")



import speech_recognition as sr
import logging
import sys
from fastapi import HTTPException
from io import BytesIO
from pydub import AudioSegment

# Configure logger to force flush for real-time logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(logging.Formatter('%(levelname)s: %(message)s'))
logger.addHandler(handler)

def voice_to_text(audio_bytes: bytes) -> str:
    """
    Converts uploaded audio bytes to text using Google Speech Recognition.
    """
    recognizer = sr.Recognizer()
    try {
        logger.info("Processing audio bytes for speech-to-text conversion")
        logger.info(f"Audio bytes length: {len(audio_bytes)}")
        # Ensure the audio is in WAV format
        audio_segment = AudioSegment.from_file(BytesIO(audio_bytes), format="wav")
        audio_segment = audio_segment.set_channels(1)  # Mono
        audio_segment = audio_segment.set_frame_rate(16000)  # 16kHz
        audio_segment = audio_segment.set_sample_width(2)  # 16-bit PCM

        # Export to WAV format for speech recognition
        with BytesIO() as wav_file:
            audio_segment.export(wav_file, format="wav")
            wav_file.seek(0)
            audio_data = wav_file.read()
            logger.info(f"Processed WAV data length: {len(audio_data)} bytes")

        # Process with speech recognition
        logger.info("Starting speech recognition")
        with sr.AudioFile(BytesIO(audio_data)) as source:
            audio = recognizer.record(source)
            logger.info("Audio recorded for recognition")
            # Adjust recognizer settings to improve detection
            recognizer.energy_threshold = 300  # Lower threshold for sensitivity
            recognizer.pause_threshold = 0.5   # Shorter pause to consider speech ended
            text = recognizer.recognize_google(audio)
            logger.info(f"Recognized text: {text}")
            return text
    } except sr.UnknownValueError:
        logger.warning("Could not understand audio - possibly too quiet, noisy, or empty")
        raise HTTPException(status_code=400, detail="Could not understand audio")
    except sr.RequestError as e:
        logger.error(f"Google Speech Recognition service error: {str(e)}")
        raise HTTPException(status_code=503, detail="Speech recognition service unavailable")
    except Exception as e:
        logger.error(f"Unexpected STT error: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to process audio input")
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/conversation_mode_card.dart';
import '../widgets/info_box.dart';
import 'chat_screen.dart';

class ConversationModeScreen extends StatefulWidget {
  final bool isVoiceMode;

  const ConversationModeScreen({super.key, required this.isVoiceMode});

  @override
  State<ConversationModeScreen> createState() => _ConversationModeScreenState();
}

class _ConversationModeScreenState extends State<ConversationModeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    try {
      _fadeController.forward();
      _scaleController.forward();
    } catch (e) {
      debugPrint('ConversationModeScreen: Error starting animations: $e');
    }
  }

  @override
  void dispose() {
    try {
      _fadeController.dispose();
      _scaleController.dispose();
      _scrollController.dispose();
    } catch (e) {
      debugPrint('ConversationModeScreen: Error disposing animations: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDark ? Colors.black12 : Colors.white.withValues(alpha: 0.1),
        title: Text(
          widget.isVoiceMode ? 'Voice Chat Modes' : 'Text Chat Modes',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return RotationTransition(
                  turns: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey<bool>(isDark),
                color: isDark ? Colors.amber : Colors.blueGrey,
              ),
            ),
            onPressed:
                () =>
                    Provider.of<ThemeProvider>(
                      context,
                      listen: false,
                    ).toggleTheme(),
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          ),
          const SizedBox(width: 8),
        ],
      ),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.2),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _fadeController,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose a',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                            height: 0.9,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Conversation Mode',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: -0.5,
                              fontSize: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const InfoBox(text: 'Select a mode to start your chat'),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height > 700 ? 32 : 24,
                ),
                Text(
                  'Modes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ScaleTransition(
                    scale: _scaleController,
                    child: GridView.count(
                      controller: _scrollController,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          MediaQuery.of(context).size.width > 400 ? 0.85 : 0.75,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        // Daily Life Conversation
                        _buildModeCard(
                          context,
                          title: AppStrings.dailyLifeTitle,
                          icon: Icons.people_outline,
                          description: AppStrings.dailyLifeDesc,
                          onTap: () {
                            chatProvider.setConversationMode(
                              ConversationMode.dailyLife,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      initialVoiceMode:
                                          widget
                                              .isVoiceMode, // Respect initial mode
                                    ),
                              ),
                            );
                          },
                        ),
                        // Beginners Helper
                        _buildModeCard(
                          context,
                          title: AppStrings.beginnersHelperTitle,
                          icon: Icons.school_outlined,
                          description: AppStrings.beginnersHelperDesc,
                          onTap: () {
                            chatProvider.setConversationMode(
                              ConversationMode.beginnersHelper,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      initialVoiceMode:
                                          widget
                                              .isVoiceMode, // Respect initial mode
                                    ),
                              ),
                            );
                          },
                        ),
                        // Professional Conversation
                        _buildModeCard(
                          context,
                          title: AppStrings.professionalTitle,
                          icon: Icons.business_center,
                          description: AppStrings.professionalDesc,
                          onTap: () {
                            chatProvider.setConversationMode(
                              ConversationMode.professionalConversation,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      initialVoiceMode:
                                          widget
                                              .isVoiceMode, // Respect initial mode
                                    ),
                              ),
                            );
                          },
                        ),
                        // Everyday Situations
                        _buildModeCard(
                          context,
                          title: AppStrings.everydaySituationsTitle,
                          icon: Icons.local_mall,
                          description: AppStrings.everydaySituationsDesc,
                          onTap: () {
                            chatProvider.setConversationMode(
                              ConversationMode.everydaySituations,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      initialVoiceMode:
                                          widget
                                              .isVoiceMode, // Respect initial mode
                                    ),
                              ),
                            );
                          },
                        ),
                        // Custom conversation mode
                        _buildModeCard(
                          context,
                          title: AppStrings.customConversationTitle,
                          icon: Icons.edit,
                          description: AppStrings.customConversationDesc,
                          onTap: () {
                            chatProvider.setConversationMode(
                              ConversationMode.custom,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      initialVoiceMode:
                                          widget
                                              .isVoiceMode, // Respect initial mode
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
  }) {
    return ConversationModeCard(
      title: title,
      icon: icon,
      description: description,
      onTap: onTap,
    );
  }
}

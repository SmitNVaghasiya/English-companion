import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme_provider.dart';
import '../providers/chat_provider.dart';
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
            isDark ? Colors.black12 : Colors.white.withOpacity(0.1),
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
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width > 360
                                    ? 12
                                    : 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Select a mode to start your chat',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
                        // Only show Beginners Helper for text chat mode
                        if (!widget.isVoiceMode) _buildModeCard(
                          context,
                          title: AppStrings.beginnersHelperTitle,
                          icon: Icons.school,
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
                                      initialVoiceMode: false, // Force text mode
                                    ),
                              ),
                            );
                          },
                        ),
                        // Daily Life Conversation - for voice chat
                        if (widget.isVoiceMode) _buildModeCard(
                          context,
                          title: AppStrings.dailyLifeConversationTitle,
                          icon: Icons.people_outline,
                          description: AppStrings.dailyLifeConversationDesc,
                          onTap: () {
                            chatProvider.setConversationMode(
                              ConversationMode.dailyLife,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      initialVoiceMode: true, // Force voice mode
                                    ),
                              ),
                            );
                          },
                        ),
                        // Professional Conversation - for voice chat
                        if (widget.isVoiceMode) _buildModeCard(
                          context,
                          title: AppStrings.professionalConversationTitle,
                          icon: Icons.business_center,
                          description: AppStrings.professionalConversationDesc,
                          onTap: () {
                            chatProvider.setConversationMode(
                              ConversationMode.professionalConversation,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      initialVoiceMode: true, // Force voice mode
                                    ),
                              ),
                            );
                          },
                        ),
                        // Everyday Situations - for both text and voice chat
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
                                      initialVoiceMode: widget.isVoiceMode,
                                    ),
                              ),
                            );
                          },
                        ),
                        // Legacy modes - keeping for backward compatibility
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
                                      initialVoiceMode: widget.isVoiceMode,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final randomRotation = (math.Random().nextInt(6) - 3) * 0.05;

    return Card(
      elevation: 4,
      shadowColor:
          isDark ? AppColors.primaryColor.withOpacity(0.3) : Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDark
                      ? [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)]
                      : [Colors.white, const Color(0xFFF8F8F8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Transform.rotate(
                  angle: randomRotation,
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.3,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
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

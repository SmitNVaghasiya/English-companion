import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../screens/progress_screen.dart';
import '../providers/notification_provider.dart';
import 'grammar_screen.dart';
import 'chat_screen.dart';
import '../widgets/app_drawer.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeProviders();
  }

  void _initializeAnimations() {
    try {
      _fadeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );

      _scaleController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );

      _fadeAnimation = CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      );

      _scaleAnimation = CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      );

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, -0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
      );

      _startAnimationsSequentially();
    } catch (e) {
      debugPrint('HomeScreen: Error initializing animations: $e');
    }
  }

  void _startAnimationsSequentially() async {
    try {
      await _fadeController.forward();
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        await _scaleController.forward();
      }
    } catch (e) {
      debugPrint('HomeScreen: Error in animation sequence: $e');
    }
  }

  void _initializeProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        final notificationProvider = Provider.of<NotificationProvider>(
          context,
          listen: false,
        );

        // Initialize both providers
        await Future.wait([
          chatProvider.testConnection(context),
          notificationProvider.initialize(),
        ]);
      } catch (e) {
        debugPrint('HomeScreen: Error initializing providers: $e');
      }
    });
  }

  @override
  void dispose() {
    try {
      _fadeController.dispose();
      _scaleController.dispose();
    } catch (e) {
      debugPrint('HomeScreen: Error disposing animations: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        SystemChrome.setSystemUIOverlayStyle(
          themeProvider.systemUiOverlayStyle,
        );

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context, isDark),
          drawer: const AppDrawer(),
          body: _buildBody(context, isDark),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor:
          isDark ? Colors.black12 : Colors.white.withValues(alpha: 0.1),
      title: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          return Column(
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
              _buildConnectionStatus(context, chatProvider),
            ],
          );
        },
      ),
      titleSpacing: 16,
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
    );
  }

  Widget _buildConnectionStatus(
    BuildContext context,
    ChatProvider chatProvider,
  ) {
    final status = chatProvider.state.connectionStatus;
    final color =
        status == 'Connected'
            ? Colors.green
            : status == 'Connecting...'
            ? Colors.orange
            : Colors.red;

    return GestureDetector(
      onTap:
          status == 'Connection failed'
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
              color:
                  status == 'Connected'
                      ? Colors.green[400]
                      : status == 'Connecting...'
                      ? Colors.orange[400]
                      : Colors.red[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    return Container(
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
              _buildWelcomeSection(context, isDark),
              SizedBox(
                height: MediaQuery.of(context).size.height > 700 ? 32 : 24,
              ),
              _buildFeaturesSection(context, isDark),
              const SizedBox(height: 16),
              _buildFeatureGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
                height: 0.9,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'English Companion',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 360 ? 12 : 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Improve your English speaking and grammar skills',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Text(
      'Available Features',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Expanded(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GridView.count(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: _getChildAspectRatio(context),
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          children: _buildFeatureCards(context),
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 400 ? 2 : 2;
  }

  double _getChildAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 400 ? 0.8 : 0.7;
  }

  List<Widget> _buildFeatureCards(BuildContext context) {
    final features = [
      _FeatureData(
        title: 'Text Chat',
        icon: Icons.chat_bubble_outline,
        description: 'Practice with text conversations',
        onTap:
            () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                ),
      ),
      _FeatureData(
        title: 'Voice Chat',
        icon: Icons.mic_none_rounded,
        description: 'Practice speaking and pronunciation',
        onTap:
            () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => 
                        const ChatScreen(initialVoiceMode: true),
                  ),
                ),
      ),
      _FeatureData(
        title: 'Grammar',
        icon: Icons.school_outlined,
        description: 'Learn essential grammar rules',
        onTap:
            () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GrammarScreen()),
                ),
      ),
      _FeatureData(
        title: 'Progress',
        icon: Icons.trending_up_outlined,
        description: 'Track your learning journey',
        onTap:
            () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProgressScreen()),
                ),
      ),
    ];

    return features.asMap().entries.map((entry) {
      final index = entry.key;
      final feature = entry.value;

      return AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          final delay = index * 0.1;
          final animationValue = Curves.easeOut.transform(
            (_scaleController.value - delay).clamp(0.0, 1.0),
          );

          return Transform.scale(
            scale: animationValue,
            child: _buildFeatureCard(
              context,
              title: feature.title,
              icon: feature.icon,
              description: feature.description,
              onTap: feature.onTap,
              isComingSoon: feature.isComingSoon,
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final randomRotation = (math.Random().nextInt(6) - 3) * 0.05;

    return Card(
      elevation: 5,
      shadowColor:
          isDark
              ? AppColors.primaryColor.withValues(alpha: 0.3)
              : Colors.black26,
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
                      color: AppColors.primaryColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        size: 28,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isComingSoon)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.blueGrey[900] : Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 10,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Coming Soon',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureData {
  final String title;
  final IconData icon;
  final String description;
  final VoidCallback onTap;
  final bool isComingSoon;

  const _FeatureData({
    required this.title,
    required this.icon,
    required this.description,
    required this.onTap,
    this.isComingSoon = false,
  });
}

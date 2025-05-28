import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import 'grammar_topic_screen.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;

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
      debugPrint('Error starting animations: $e');
    }
  }

  @override
  void dispose() {
    try {
      _fadeController.dispose();
      _scaleController.dispose();
    } catch (e) {
      debugPrint('Error disposing animations: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor:
                isDark ? Colors.black12 : Colors.white.withOpacity(0.1),
            title: const Text(
              'Grammar Lessons',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            titleSpacing: 16,
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
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
                onPressed: () => themeProvider.toggleTheme(),
                tooltip:
                    isDark ? 'Switch to light mode' : 'Switch to dark mode',
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
                              'Master',
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
                                'English Grammar',
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
                                  color: AppColors.primaryColor.withOpacity(
                                    0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Learn essential grammar rules and improve your English',
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
                      height:
                          MediaQuery.of(context).size.height > 700 ? 32 : 24,
                    ),
                    Text(
                      'Grammar Topics',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ScaleTransition(
                        scale: _scaleController,
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              MediaQuery.of(context).size.width > 400
                                  ? 0.8
                                  : 0.7,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 16),
                          children: [
                            _buildGrammarTopicCard(
                              context,
                              title: 'Parts of Speech',
                              icon: Icons.category_outlined,
                              description: 'Nouns, verbs, adjectives, and more',
                              onTap:
                                  () => _navigateToTopic(
                                    context,
                                    'parts_of_speech',
                                  ),
                            ),
                            _buildGrammarTopicCard(
                              context,
                              title: 'Verb Tenses',
                              icon: Icons.access_time_outlined,
                              description: 'Past, present, and future tenses',
                              onTap:
                                  () =>
                                      _navigateToTopic(context, 'verb_tenses'),
                            ),
                            _buildGrammarTopicCard(
                              context,
                              title: 'Sentence Structure',
                              icon: Icons.format_align_left_outlined,
                              description: 'Building correct English sentences',
                              onTap:
                                  () => _navigateToTopic(
                                    context,
                                    'sentence_structure',
                                  ),
                            ),
                            _buildGrammarTopicCard(
                              context,
                              title: 'Articles',
                              icon: Icons.article_outlined,
                              description: 'A, an, and the',
                              onTap:
                                  () => _navigateToTopic(context, 'articles'),
                            ),
                            _buildGrammarTopicCard(
                              context,
                              title: 'Prepositions',
                              icon: Icons.place_outlined,
                              description: 'In, on, at, and more',
                              onTap:
                                  () =>
                                      _navigateToTopic(context, 'prepositions'),
                            ),
                            _buildGrammarTopicCard(
                              context,
                              title: 'Modals',
                              icon: Icons.help_outline,
                              description: 'Can, could, should, would, etc.',
                              onTap: () => _navigateToTopic(context, 'modals'),
                            ),
                            _buildGrammarTopicCard(
                              context,
                              title: 'Conditionals',
                              icon: Icons.compare_arrows_outlined,
                              description:
                                  'If clauses and conditional sentences',
                              onTap:
                                  () =>
                                      _navigateToTopic(context, 'conditionals'),
                            ),
                            _buildGrammarTopicCard(
                              context,
                              title: 'Passive Voice',
                              icon: Icons.swap_horiz_outlined,
                              description:
                                  'When the subject receives the action',
                              onTap:
                                  () => _navigateToTopic(
                                    context,
                                    'passive_voice',
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
          ),
        );
      },
    );
  }

  void _navigateToTopic(BuildContext context, String topicId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GrammarTopicScreen(topicId: topicId),
      ),
    );
  }

  Widget _buildGrammarTopicCard(
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
      elevation: 5,
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.15),
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
                            color: AppColors.primaryColor.withOpacity(0.1),
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
            ],
          ),
        ),
      ),
    );
  }
}

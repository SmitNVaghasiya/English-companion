import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/progress_model.dart' as model;
import '../providers/progress_provider.dart';
import '../widgets/badge_card.dart';
import '../widgets/progress_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Use WidgetsBinding to ensure the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final progressProvider = Provider.of<ProgressProvider>(
        context,
        listen: false,
      );
      await progressProvider.initialize();
    } catch (e) {
      debugPrint('Error loading progress data: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, _) {
        final progressData = progressProvider.progressData;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Progress Tracker'),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              labelColor: isDark ? Colors.white : Colors.black87,
              unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Badges'),
                Tab(text: 'History'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isLoading
                    ? null
                    : () async {
                        await _loadData();
                        if (!mounted) return;
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Progress data refreshed'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                tooltip: 'Refresh data',
              ),
            ],
          ),
          body:
              _isLoading
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Loading your progress...',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                  : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(context, progressData),
                      _buildBadgesTab(context, progressProvider),
                      _buildHistoryTab(context, progressProvider),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    model.ProgressData progressData,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Streak',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        '${progressData.daysStreak}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'days in a row',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value:
                          progressData.daysStreak >= 7
                              ? 1.0
                              : progressData.daysStreak / 7,
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[300],
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      progressData.daysStreak >= 7
                          ? 'Weekly goal achieved! 🎉'
                          : '${7 - progressData.daysStreak} more days to reach weekly goal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Activity Summary
            Text(
              'Activity Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Activity Cards
            Row(
              children: [
                Expanded(
                  child: _buildActivityCard(
                    context,
                    Icons.chat_bubble_outline,
                    'Text Chats',
                    progressData.totalChatInteractions.toString(),
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActivityCard(
                    context,
                    Icons.mic_none_outlined,
                    'Voice Chats',
                    progressData.totalVoiceInteractions.toString(),
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActivityCard(
                    context,
                    Icons.menu_book_outlined,
                    'Grammar Lessons',
                    progressData.grammarLessonsCompleted.toString(),
                    Colors.teal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActivityCard(
                    context,
                    Icons.fitness_center,
                    'Practice Sessions',
                    progressData.totalPracticeSessionsCompleted.toString(),
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Skill Progress
            Text(
              'Skill Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Progress Chart
            if (progressData.skillScores.isNotEmpty)
              ProgressChart(skillScores: progressData.skillScores)
            else
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 48,
                          color: isDark ? Colors.white60 : Colors.black38,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No skill data available yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete more activities to see your progress',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Recent Badges
            if (progressData.earnedBadges.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Badges',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _tabController.animateTo(1); // Switch to Badges tab
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      progressData.earnedBadges.length > 5
                          ? 5
                          : progressData.earnedBadges.length,
                  itemBuilder: (context, index) {
                    final reversedIndex =
                        progressData.earnedBadges.length - 1 - index;
                    final badge = progressData.earnedBadges[reversedIndex];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: BadgeCard(badge: badge, compact: true),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Server Feedback
            Consumer<ProgressProvider>(
              builder: (context, provider, _) {
                final feedback = provider.progressFeedback;

                if (feedback == null) {
                  return const SizedBox.shrink();
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: isDark ? Colors.indigo[900] : Colors.indigo[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.insights,
                              color:
                                  isDark ? Colors.indigo[300] : Colors.indigo,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Personalized Insights',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark ? Colors.indigo[300] : Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          feedback['message'] ??
                              'Keep practicing to improve your English skills!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (feedback['suggestions'] != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Suggestions:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(
                            (feedback['suggestions'] as List).length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      feedback['suggestions'][index],
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesTab(
    BuildContext context,
    ProgressProvider progressProvider,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Using BadgeCategory.values directly in the widget tree
    final groupedBadges = progressProvider.getAllBadgesGroupedByCategory();
    final earnedBadgesCount = progressProvider.progressData.earnedBadges.length;

    // Total number of badges defined in the system
    const totalBadgesCount =
        15; // This should match the number in ProgressService._badgeDefinitions

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Progress
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Badge Collection',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$earnedBadgesCount',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          '/$totalBadgesCount',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'badges earned',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: earnedBadgesCount / totalBadgesCount,
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[300],
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      earnedBadgesCount == totalBadgesCount
                          ? 'All badges collected! 🏆'
                          : '${totalBadgesCount - earnedBadgesCount} more badges to collect',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Badges by Category
            ...model.BadgeCategory.values.map((category) {
              final badges = groupedBadges[category] ?? [];

              if (badges.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(category.icon, color: category.color, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${category.toString().split('.').last.toUpperCase()} BADGES',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: category.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      return BadgeCard(badge: badges[index]);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    ProgressProvider progressProvider,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progressHistory = progressProvider.progressData.progressHistory;

    if (progressHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'No activity history yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your learning activities will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    // Sort history by date (newest first)
    final sortedHistory = List<model.ProgressEntry>.from(progressHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sortedHistory.length,
        itemBuilder: (context, index) {
          final entry = sortedHistory[index];

          // Group by date
          final bool showDateHeader =
              index == 0 ||
              !_isSameDay(entry.date, sortedHistory[index - 1].date);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateHeader) ...[
                if (index > 0) const SizedBox(height: 16),
                _buildDateHeader(context, entry.date),
                const SizedBox(height: 8),
              ],
              _buildHistoryItem(context, entry),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (entryDate == today) {
      dateText = 'Today';
    } else if (entryDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('EEEE, MMMM d, y').format(date);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        dateText,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, model.ProgressEntry entry) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData activityIcon;
    Color activityColor;

    switch (entry.activityType) {
      case 'chat':
        activityIcon = Icons.chat_bubble_outline;
        activityColor = Colors.blue;
        break;
      case 'voice':
        activityIcon = Icons.mic_none_outlined;
        activityColor = Colors.purple;
        break;
      case 'grammar':
        activityIcon = Icons.menu_book_outlined;
        activityColor = Colors.teal;
        break;
      case 'practice':
        activityIcon = Icons.fitness_center;
        activityColor = Colors.green;
        break;
      default:
        activityIcon = Icons.star_outline;
        activityColor = Colors.amber;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activityColor.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(activityIcon, color: activityColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm a').format(entry.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  if (entry.scoreImprovement != null &&
                      entry.scoreImprovement! > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+${entry.scoreImprovement!.toStringAsFixed(1)} points',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

import 'package:flutter/material.dart';
import '../../data/models/progress_model.dart' as model;
import '../../data/services/progress_service.dart';
// import '../../data/services/notification_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressService _progressService = ProgressService();
  // final NotificationService _notificationService = NotificationService();

  model.ProgressData _progressData = model.ProgressData();
  bool _isLoading = false;
  String? _error;
  List<model.Badge> _recentlyEarnedBadges = [];
  Map<String, dynamic>? _progressFeedback;

  // Getters
  model.ProgressData get progressData => _progressData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<model.Badge> get recentlyEarnedBadges => _recentlyEarnedBadges;
  Map<String, dynamic>? get progressFeedback => _progressFeedback;

  // Initialize progress data
  Future<void> initialize() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Load progress data
      _progressData = await _progressService.getProgressData();
      
      // Update login streak
      final updatedData = await _progressService.updateLoginStreak();

      // Check if new badges were earned
      final previousBadgeCount = _progressData.earnedBadges.length;
      _progressData = updatedData;

      if (_progressData.earnedBadges.length > previousBadgeCount) {
        // Get newly earned badges
        _recentlyEarnedBadges = _progressData.earnedBadges.sublist(
          previousBadgeCount,
        );
      }

      // Try to sync with server in the background
      syncWithServer().catchError((e) {
        debugPrint('Error syncing with server: $e');
        return false;
      });
    } catch (e) {
      _error = 'Error initializing progress data: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Record a completed activity
  Future<void> recordActivity({
    required String activityType,
    required String description,
    double? scoreImprovement,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final previousBadgeCount = _progressData.earnedBadges.length;

      _progressData = await _progressService.recordActivity(
        activityType: activityType,
        description: description,
        scoreImprovement: scoreImprovement,
        additionalData: additionalData,
      );

      // Check if new badges were earned
      if (_progressData.earnedBadges.length > previousBadgeCount) {
        // Get newly earned badges
        _recentlyEarnedBadges = _progressData.earnedBadges.sublist(
          previousBadgeCount,
        );

        // Show notifications for new badges
        // for (final badge in _recentlyEarnedBadges) {
        //   await _notificationService.showAchievementNotification(
        //     'New Badge Earned!',
        //     'You earned the "${badge.name}" badge: ${badge.description}',
        //   );
        // }
      }

      // If there was a score improvement, show a progress notification
      // if (scoreImprovement != null && scoreImprovement > 0) {
      //   final skillType = additionalData?['skillType'] as String? ?? 'skill';
      //   await _notificationService.showProgressNotification(
      //     'Progress Update',
      //     'Your $skillType improved by ${scoreImprovement.toStringAsFixed(1)} points!',
      //   );
      // }

      notifyListeners();
    } catch (e) {
      _setError('Error recording activity: $e');
    }
  }

  // Sync progress data with server
  Future<bool> syncWithServer() async {
    try {
      final success = await _progressService.syncProgressWithServer();

      if (success) {
        // Get feedback from server
        _progressFeedback = await _progressService.getProgressFeedback();
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError('Error syncing with server: $e');
      return false;
    }
  }

  // Clear recently earned badges
  void clearRecentlyEarnedBadges() {
    _recentlyEarnedBadges = [];
    notifyListeners();
  }

  // Get badges by category
  Map<model.BadgeCategory, List<model.Badge>> getBadgesByCategory() {
    final Map<model.BadgeCategory, List<model.Badge>> badgesByCategory = {};

    for (final badge in _progressData.earnedBadges) {
      badgesByCategory.putIfAbsent(badge.category, () => []).add(badge);
    }

    // Sort badges by earned date within each category
    for (final category in badgesByCategory.keys) {
      badgesByCategory[category]!.sort(
        (a, b) => b.earnedDate.compareTo(a.earnedDate),
      );
    }

    return badgesByCategory;
  }

  // Get all badges grouped by category
  Map<model.BadgeCategory, List<model.Badge>> getAllBadgesGroupedByCategory() {
    final Map<model.BadgeCategory, List<model.Badge>> groupedBadges = {};

    for (final category in model.BadgeCategory.values) {
      groupedBadges[category] = getBadgesByCategory()[category] ?? [];
    }

    return groupedBadges;
  }

  // Get progress history for a specific activity type
  List<model.ProgressEntry> getProgressHistoryByType(String activityType) {
    return _progressData.progressHistory
        .where((entry) => entry.activityType == activityType)
        .toList();
  }

  // Get recent progress history (last 7 days)
  List<model.ProgressEntry> getRecentProgressHistory() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    return _progressData.progressHistory
        .where((entry) => entry.date.isAfter(sevenDaysAgo))
        .toList();
  }

  // Helper method for error handling
  void _setError(String? errorMessage) {
    _error = errorMessage;
    _isLoading = false;
    notifyListeners();
  }
}

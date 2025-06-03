import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../core/config/env_config.dart';
import '../models/progress_model.dart' as model;

class ProgressService {
  static const String _progressKey = 'user_progress_data';
  static const String _lastLoginKey = 'last_login_date';

  // Predefined badges
  static final List<Map<String, dynamic>> _badgeDefinitions = [
    // Streak badges
    {
      'id': 'streak_3',
      'name': 'Consistent Learner',
      'description': 'Maintained a 3-day streak',
      'iconPath': 'assets/images/badges/streak_3.png',
      'category': 'streak',
      'rarity': 'common',
      'requirement': {'type': 'streak', 'value': 3},
    },
    {
      'id': 'streak_7',
      'name': 'Weekly Warrior',
      'description': 'Maintained a 7-day streak',
      'iconPath': 'assets/images/badges/streak_7.png',
      'category': 'streak',
      'rarity': 'uncommon',
      'requirement': {'type': 'streak', 'value': 7},
    },
    {
      'id': 'streak_30',
      'name': 'Monthly Master',
      'description': 'Maintained a 30-day streak',
      'iconPath': 'assets/images/badges/streak_30.png',
      'category': 'streak',
      'rarity': 'rare',
      'requirement': {'type': 'streak', 'value': 30},
    },
    {
      'id': 'streak_100',
      'name': 'Dedication Champion',
      'description': 'Maintained a 100-day streak',
      'iconPath': 'assets/images/badges/streak_100.png',
      'category': 'streak',
      'rarity': 'legendary',
      'requirement': {'type': 'streak', 'value': 100},
    },

    // Chat badges
    {
      'id': 'chat_10',
      'name': 'Conversation Starter',
      'description': 'Completed 10 text chat sessions',
      'iconPath': 'assets/images/badges/chat_10.png',
      'category': 'chat',
      'rarity': 'common',
      'requirement': {'type': 'chat', 'value': 10},
    },
    {
      'id': 'chat_50',
      'name': 'Text Communicator',
      'description': 'Completed 50 text chat sessions',
      'iconPath': 'assets/images/badges/chat_50.png',
      'category': 'chat',
      'rarity': 'uncommon',
      'requirement': {'type': 'chat', 'value': 50},
    },
    {
      'id': 'chat_100',
      'name': 'Chat Expert',
      'description': 'Completed 100 text chat sessions',
      'iconPath': 'assets/images/badges/chat_100.png',
      'category': 'chat',
      'rarity': 'rare',
      'requirement': {'type': 'chat', 'value': 100},
    },

    // Voice badges
    {
      'id': 'voice_10',
      'name': 'Voice Explorer',
      'description': 'Completed 10 voice chat sessions',
      'iconPath': 'assets/images/badges/voice_10.png',
      'category': 'voice',
      'rarity': 'common',
      'requirement': {'type': 'voice', 'value': 10},
    },
    {
      'id': 'voice_50',
      'name': 'Fluent Speaker',
      'description': 'Completed 50 voice chat sessions',
      'iconPath': 'assets/images/badges/voice_50.png',
      'category': 'voice',
      'rarity': 'uncommon',
      'requirement': {'type': 'voice', 'value': 50},
    },
    {
      'id': 'voice_100',
      'name': 'Pronunciation Pro',
      'description': 'Completed 100 voice chat sessions',
      'iconPath': 'assets/images/badges/voice_100.png',
      'category': 'voice',
      'rarity': 'rare',
      'requirement': {'type': 'voice', 'value': 100},
    },

    // Grammar badges
    {
      'id': 'grammar_5',
      'name': 'Grammar Novice',
      'description': 'Completed 5 grammar lessons',
      'iconPath': 'assets/images/badges/grammar_5.png',
      'category': 'grammar',
      'rarity': 'common',
      'requirement': {'type': 'grammar', 'value': 5},
    },
    {
      'id': 'grammar_20',
      'name': 'Grammar Enthusiast',
      'description': 'Completed 20 grammar lessons',
      'iconPath': 'assets/images/badges/grammar_20.png',
      'category': 'grammar',
      'rarity': 'uncommon',
      'requirement': {'type': 'grammar', 'value': 20},
    },
    {
      'id': 'grammar_50',
      'name': 'Grammar Master',
      'description': 'Completed 50 grammar lessons',
      'iconPath': 'assets/images/badges/grammar_50.png',
      'category': 'grammar',
      'rarity': 'rare',
      'requirement': {'type': 'grammar', 'value': 50},
    },

    // Achievement badges
    {
      'id': 'first_chat',
      'name': 'First Conversation',
      'description': 'Completed your first text chat',
      'iconPath': 'assets/images/badges/first_chat.png',
      'category': 'achievement',
      'rarity': 'common',
      'requirement': {'type': 'chat', 'value': 1},
    },
    {
      'id': 'first_voice',
      'name': 'First Voice Chat',
      'description': 'Completed your first voice chat',
      'iconPath': 'assets/images/badges/first_voice.png',
      'category': 'achievement',
      'rarity': 'common',
      'requirement': {'type': 'voice', 'value': 1},
    },
    {
      'id': 'improvement_10',
      'name': 'Quick Learner',
      'description': 'Improved your skills by 10%',
      'iconPath': 'assets/images/badges/improvement_10.png',
      'category': 'achievement',
      'rarity': 'uncommon',
      'requirement': {'type': 'improvement', 'value': 10},
    },
  ];

  // Get user progress data
  Future<model.ProgressData> getProgressData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);

      if (progressJson != null) {
        return model.ProgressData.fromJson(jsonDecode(progressJson));
      }

      // If no data exists, create default progress data
      return model.ProgressData();
    } catch (e) {
      debugPrint('Error getting progress data: $e');
      return model.ProgressData();
    }
  }

  // Save user progress data
  Future<bool> saveProgressData(model.ProgressData progressData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_progressKey, jsonEncode(progressData.toJson()));
      return true;
    } catch (e) {
      debugPrint('Error saving progress data: $e');
      return false;
    }
  }

  // Update streak when user opens the app
  Future<model.ProgressData> updateLoginStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressData = await getProgressData();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final lastLoginStr = prefs.getString(_lastLoginKey);
      DateTime? lastLogin;

      if (lastLoginStr != null) {
        lastLogin = DateTime.parse(lastLoginStr);
      }

      int streak = progressData.daysStreak;

      if (lastLogin == null) {
        // First time login
        streak = 1;
      } else {
        final lastLoginDate = DateTime(
          lastLogin.year,
          lastLogin.month,
          lastLogin.day,
        );
        final difference = today.difference(lastLoginDate).inDays;

        if (difference == 1) {
          // Consecutive day
          streak += 1;
        } else if (difference > 1) {
          // Streak broken
          streak = 1;
        }
        // If difference is 0, user already logged in today, keep current streak
      }

      // Save today's date as last login
      await prefs.setString(_lastLoginKey, today.toIso8601String());

      // Update progress data with new streak
      final updatedProgressData = progressData.copyWith(daysStreak: streak);

      // Check for new streak badges
      final newBadges = await checkForNewBadges(updatedProgressData);

      // Save updated progress data
      final finalProgressData = updatedProgressData.copyWith(
        earnedBadges: [...updatedProgressData.earnedBadges, ...newBadges],
      );

      await saveProgressData(finalProgressData);
      return finalProgressData;
    } catch (e) {
      debugPrint('Error updating login streak: $e');
      return await getProgressData();
    }
  }

  // Record a completed activity
  Future<model.ProgressData> recordActivity({
    required String activityType,
    required String description,
    double? scoreImprovement,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final progressData = await getProgressData();

      // Create a new progress entry
      final entry = model.ProgressEntry(
        date: DateTime.now(),
        activityType: activityType,
        description: description,
        scoreImprovement: scoreImprovement,
        additionalData: additionalData,
      );

      // Update relevant counters based on activity type
      model.ProgressData updatedProgressData = progressData.copyWith(
        progressHistory: [...progressData.progressHistory, entry],
      );

      switch (activityType) {
        case 'chat':
          updatedProgressData = updatedProgressData.copyWith(
            totalChatInteractions: progressData.totalChatInteractions + 1,
          );
          break;
        case 'voice':
          updatedProgressData = updatedProgressData.copyWith(
            totalVoiceInteractions: progressData.totalVoiceInteractions + 1,
          );
          break;
        case 'grammar':
          updatedProgressData = updatedProgressData.copyWith(
            grammarLessonsCompleted: progressData.grammarLessonsCompleted + 1,
          );
          break;
        case 'practice':
          updatedProgressData = updatedProgressData.copyWith(
            totalPracticeSessionsCompleted:
                progressData.totalPracticeSessionsCompleted + 1,
          );
          break;
      }

      // Update skill scores if provided
      if (scoreImprovement != null &&
          additionalData != null &&
          additionalData.containsKey('skillType')) {
        final skillType = additionalData['skillType'] as String;
        final currentScore = progressData.skillScores[skillType] ?? 0.0;
        final newScore = currentScore + scoreImprovement;

        final updatedScores = Map<String, double>.from(
          progressData.skillScores,
        );
        updatedScores[skillType] = newScore > 100 ? 100 : newScore;

        updatedProgressData = updatedProgressData.copyWith(
          skillScores: updatedScores,
        );
      }

      // Check for new badges
      final newBadges = await checkForNewBadges(updatedProgressData);

      // Save updated progress data with new badges
      final finalProgressData = updatedProgressData.copyWith(
        earnedBadges: [...updatedProgressData.earnedBadges, ...newBadges],
      );

      await saveProgressData(finalProgressData);
      return finalProgressData;
    } catch (e) {
      debugPrint('Error recording activity: $e');
      return await getProgressData();
    }
  }

  // Check for new badges based on updated progress
  Future<List<model.Badge>> checkForNewBadges(
    model.ProgressData progressData,
  ) async {
    final List<model.Badge> newBadges = [];
    final earnedBadgeIds = progressData.earnedBadges.map((b) => b.id).toSet();

    for (final badgeDef in _badgeDefinitions) {
      final String badgeId = badgeDef['id'];

      // Skip if badge already earned
      if (earnedBadgeIds.contains(badgeId)) {
        continue;
      }

      final requirement = badgeDef['requirement'] as Map<String, dynamic>;
      final String type = requirement['type'];
      final int value = requirement['value'];

      bool isEarned = false;

      // Check if the user meets the badge requirements
      switch (type) {
        case 'streak':
          isEarned = progressData.daysStreak >= value;
          break;
        case 'chat':
          isEarned = progressData.totalChatInteractions >= value;
          break;
        case 'voice':
          isEarned = progressData.totalVoiceInteractions >= value;
          break;
        case 'grammar':
          isEarned = progressData.grammarLessonsCompleted >= value;
          break;
        case 'improvement':
          // Check if any skill has improved by the required percentage
          isEarned = progressData.skillScores.values.any(
            (score) => score >= value,
          );
          break;
      }

      if (isEarned) {
        newBadges.add(
          model.Badge(
            id: badgeId,
            name: badgeDef['name'],
            description: badgeDef['description'],
            iconPath: badgeDef['iconPath'],
            earnedDate: DateTime.now(),
            category: model.BadgeCategoryExtension.fromString(
              badgeDef['category'],
            ),
            rarity: model.BadgeRarityExtension.fromString(badgeDef['rarity']),
          ),
        );
      }
    }

    return newBadges;
  }

  // Sync progress data with server
  Future<bool> syncProgressWithServer() async {
    try {
      final progressData = await getProgressData();
      final url = '${EnvConfig.backendUrl}/api/progress/sync';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(progressData.toJson()),
      );

      if (response.statusCode == 200) {
        final serverData = model.ProgressData.fromJson(
          jsonDecode(response.body),
        );
        await saveProgressData(serverData);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error syncing progress with server: $e');
      return false;
    }
  }

  // Get feedback from server about user's progress
  Future<Map<String, dynamic>?> getProgressFeedback() async {
    try {
      final url = '${EnvConfig.backendUrl}/api/progress/feedback';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting progress feedback: $e');
      return null;
    }
  }
}

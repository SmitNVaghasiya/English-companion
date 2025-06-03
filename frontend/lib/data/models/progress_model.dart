import 'package:flutter/material.dart';

class ProgressData {
  final int daysStreak;
  final int totalPracticeSessionsCompleted;
  final int totalChatInteractions;
  final int totalVoiceInteractions;
  final int grammarLessonsCompleted;
  final List<Badge> earnedBadges;
  final Map<String, double> skillScores; // e.g., 'pronunciation': 85.0
  final List<ProgressEntry> progressHistory;

  ProgressData({
    this.daysStreak = 0,
    this.totalPracticeSessionsCompleted = 0,
    this.totalChatInteractions = 0,
    this.totalVoiceInteractions = 0,
    this.grammarLessonsCompleted = 0,
    this.earnedBadges = const [],
    this.skillScores = const {},
    this.progressHistory = const [],
  });

  ProgressData copyWith({
    int? daysStreak,
    int? totalPracticeSessionsCompleted,
    int? totalChatInteractions,
    int? totalVoiceInteractions,
    int? grammarLessonsCompleted,
    List<Badge>? earnedBadges,
    Map<String, double>? skillScores,
    List<ProgressEntry>? progressHistory,
  }) {
    return ProgressData(
      daysStreak: daysStreak ?? this.daysStreak,
      totalPracticeSessionsCompleted: totalPracticeSessionsCompleted ?? this.totalPracticeSessionsCompleted,
      totalChatInteractions: totalChatInteractions ?? this.totalChatInteractions,
      totalVoiceInteractions: totalVoiceInteractions ?? this.totalVoiceInteractions,
      grammarLessonsCompleted: grammarLessonsCompleted ?? this.grammarLessonsCompleted,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      skillScores: skillScores ?? this.skillScores,
      progressHistory: progressHistory ?? this.progressHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daysStreak': daysStreak,
      'totalPracticeSessionsCompleted': totalPracticeSessionsCompleted,
      'totalChatInteractions': totalChatInteractions,
      'totalVoiceInteractions': totalVoiceInteractions,
      'grammarLessonsCompleted': grammarLessonsCompleted,
      'earnedBadges': earnedBadges.map((badge) => badge.toJson()).toList(),
      'skillScores': skillScores,
      'progressHistory': progressHistory.map((entry) => entry.toJson()).toList(),
    };
  }

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      daysStreak: json['daysStreak'] ?? 0,
      totalPracticeSessionsCompleted: json['totalPracticeSessionsCompleted'] ?? 0,
      totalChatInteractions: json['totalChatInteractions'] ?? 0,
      totalVoiceInteractions: json['totalVoiceInteractions'] ?? 0,
      grammarLessonsCompleted: json['grammarLessonsCompleted'] ?? 0,
      earnedBadges: json['earnedBadges'] != null
          ? List<Badge>.from(json['earnedBadges'].map((x) => Badge.fromJson(x)))
          : [],
      skillScores: json['skillScores'] != null
          ? Map<String, double>.from(json['skillScores'])
          : {},
      progressHistory: json['progressHistory'] != null
          ? List<ProgressEntry>.from(
              json['progressHistory'].map((x) => ProgressEntry.fromJson(x)))
          : [],
    );
  }
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final DateTime earnedDate;
  final BadgeCategory category;
  final BadgeRarity rarity;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.earnedDate,
    required this.category,
    required this.rarity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'earnedDate': earnedDate.toIso8601String(),
      'category': category.toString().split('.').last,
      'rarity': rarity.toString().split('.').last,
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconPath: json['iconPath'],
      earnedDate: DateTime.parse(json['earnedDate']),
      category: BadgeCategoryExtension.fromString(json['category']),
      rarity: BadgeRarityExtension.fromString(json['rarity']),
    );
  }
}

enum BadgeCategory {
  streak,
  practice,
  chat,
  voice,
  grammar,
  achievement,
}

extension BadgeCategoryExtension on BadgeCategory {
  static BadgeCategory fromString(String value) {
    return BadgeCategory.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => BadgeCategory.achievement,
    );
  }
  
  IconData get icon {
    switch (this) {
      case BadgeCategory.streak:
        return Icons.local_fire_department;
      case BadgeCategory.practice:
        return Icons.fitness_center;
      case BadgeCategory.chat:
        return Icons.chat_bubble;
      case BadgeCategory.voice:
        return Icons.mic;
      case BadgeCategory.grammar:
        return Icons.menu_book;
      case BadgeCategory.achievement:
        return Icons.emoji_events;
    }
  }
  
  Color get color {
    switch (this) {
      case BadgeCategory.streak:
        return Colors.orange;
      case BadgeCategory.practice:
        return Colors.green;
      case BadgeCategory.chat:
        return Colors.blue;
      case BadgeCategory.voice:
        return Colors.purple;
      case BadgeCategory.grammar:
        return Colors.teal;
      case BadgeCategory.achievement:
        return Colors.amber;
    }
  }
}

enum BadgeRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

extension BadgeRarityExtension on BadgeRarity {
  static BadgeRarity fromString(String value) {
    return BadgeRarity.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => BadgeRarity.common,
    );
  }
  
  Color get color {
    switch (this) {
      case BadgeRarity.common:
        return Colors.grey.shade400;
      case BadgeRarity.uncommon:
        return Colors.green.shade400;
      case BadgeRarity.rare:
        return Colors.blue.shade400;
      case BadgeRarity.epic:
        return Colors.purple.shade400;
      case BadgeRarity.legendary:
        return Colors.orange.shade400;
    }
  }
}

class ProgressEntry {
  final DateTime date;
  final String activityType; // 'chat', 'voice', 'grammar', etc.
  final String description;
  final double? scoreImprovement;
  final Map<String, dynamic>? additionalData;

  ProgressEntry({
    required this.date,
    required this.activityType,
    required this.description,
    this.scoreImprovement,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'activityType': activityType,
      'description': description,
      'scoreImprovement': scoreImprovement,
      'additionalData': additionalData,
    };
  }

  factory ProgressEntry.fromJson(Map<String, dynamic> json) {
    return ProgressEntry(
      date: DateTime.parse(json['date']),
      activityType: json['activityType'],
      description: json['description'],
      scoreImprovement: json['scoreImprovement'],
      additionalData: json['additionalData'],
    );
  }
}

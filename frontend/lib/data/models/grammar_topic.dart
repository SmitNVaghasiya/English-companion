import 'package:flutter/material.dart';

class GrammarTopic {
  final String id;
  final String title;
  final IconData icon;
  final String shortDescription;
  final String introduction;
  final List<GrammarRule> Function() rules;
  final List<GrammarExample> Function() examples;

  GrammarTopic({
    required this.id,
    required this.title,
    required this.icon,
    required this.shortDescription,
    required this.introduction,
    required this.rules,
    required this.examples,
  });

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    return GrammarTopic(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: _getIconFromString(json['icon'] as String),
      shortDescription: json['shortDescription'] as String,
      introduction: json['introduction'] as String,
      rules:
          () =>
              (json['rules'] as List)
                  .map(
                    (rule) =>
                        GrammarRule.fromJson(rule as Map<String, dynamic>),
                  )
                  .toList(),
      examples:
          () =>
              (json['examples'] as List)
                  .map(
                    (example) => GrammarExample.fromJson(
                      example as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
    );
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'category_outlined':
        return Icons.category_outlined;
      case 'access_time_outlined':
        return Icons.access_time_outlined;
      case 'format_align_left_outlined':
        return Icons.format_align_left_outlined;
      case 'article_outlined':
        return Icons.article_outlined;
      case 'place_outlined':
        return Icons.place_outlined;
      case 'help_outline':
        return Icons.help_outline;
      case 'compare_arrows_outlined':
        return Icons.compare_arrows_outlined;
      case 'swap_horiz_outlined':
        return Icons.swap_horiz_outlined;
      default:
        return Icons.school_outlined;
    }
  }
}

class GrammarRule {
  final String title;
  final String description;

  GrammarRule({required this.title, required this.description});

  factory GrammarRule.fromJson(Map<String, dynamic> json) {
    return GrammarRule(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

class GrammarExample {
  final String title;
  final String correct;
  final String incorrect;
  final String explanation;

  GrammarExample({
    required this.title,
    required this.correct,
    required this.incorrect,
    required this.explanation,
  });

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      title: json['title'] as String? ?? '',
      correct: json['correct'] as String,
      incorrect: json['incorrect'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

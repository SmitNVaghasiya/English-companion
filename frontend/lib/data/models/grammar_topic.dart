import 'package:flutter/material.dart';

class GrammarTopic {
  final String id;
  final String title;
  final IconData icon;
  final String shortDescription;
  final String introduction;
  final String detailedExplanation;
  final List<GrammarRule> Function() rules;
  final List<GrammarExample> Function() examples;
  final List<GrammarExample> Function() practiceSentences;
  final List<GrammarQuestion> Function() practiceQuestions;
  final bool isCompleted;
  final bool isAttempted;

  GrammarTopic({
    required this.id,
    required this.title,
    required this.icon,
    required this.shortDescription,
    required this.introduction,
    required this.detailedExplanation,
    required this.rules,
    required this.examples,
    required this.practiceSentences,
    required this.practiceQuestions,
    this.isCompleted = false,
    this.isAttempted = false,
  });

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    return GrammarTopic(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: _getIconFromString(json['icon'] as String),
      shortDescription: json['shortDescription'] as String,
      introduction: json['introduction'] as String,
      detailedExplanation: json['detailedExplanation'] as String,
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
      practiceSentences:
          () =>
              (json['practiceSentences'] as List? ?? [])
                  .map(
                    (sentence) => GrammarExample.fromJson(
                      sentence as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
      practiceQuestions:
          () =>
              (json['practiceQuestions'] as List? ?? [])
                  .map(
                    (question) => GrammarQuestion.fromJson(
                      question as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
      isCompleted: json['isCompleted'] ?? false,
      isAttempted: json['isAttempted'] ?? false,
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
  final String? incorrect;
  final String? explanation;
  final bool isCorrect;
  final bool isAttempted;

  GrammarExample({
    required this.title,
    required this.correct,
    this.incorrect,
    this.explanation,
    this.isCorrect = false,
    this.isAttempted = false,
  });

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      title: json['title'] as String,
      correct: json['correct'] as String,
      incorrect: json['incorrect'] as String?,
      explanation: json['explanation'] as String?,
      isCorrect: json['isCorrect'] ?? false,
      isAttempted: json['isAttempted'] ?? false,
    );
  }
}

class GrammarQuestion {
  final String question;
  final String type; // 'multiple_choice', 'fill_blank', 'true_false', 'matching'
  final List<String> options;
  final dynamic correctAnswer; // Can be String, List, Map, or bool depending on question type
  final String? userAnswer;
  final bool isCorrect;
  final bool isAttempted;

  GrammarQuestion({
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
    this.isCorrect = false,
    this.isAttempted = false,
  });
  
  GrammarQuestion copyWith({
    String? userAnswer,
    bool? isCorrect,
    bool? isAttempted,
  }) {
    return GrammarQuestion(
      question: question,
      type: type,
      options: options,
      correctAnswer: correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      isAttempted: isAttempted ?? this.isAttempted,
    );
  }

  factory GrammarQuestion.fromJson(Map<String, dynamic> json) {
    return GrammarQuestion(
      question: json['question'] as String,
      type: json['type'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'],
      userAnswer: json['userAnswer'] as String?,
      isCorrect: json['isCorrect'] ?? false,
      isAttempted: json['isAttempted'] ?? false,
    );
  }

  GrammarQuestion checkAnswer(dynamic answer) {
    if (answer == null) {
      return copyWith(
        userAnswer: null,
        isCorrect: false,
        isAttempted: true,
      );
    }

    bool isAnswerCorrect;
    if (answer is List && correctAnswer is List) {
      isAnswerCorrect = _areListsEqual(
        answer.map((e) => e.toString().trim().toLowerCase()).toList(),
        (correctAnswer as List).map((e) => e.toString().trim().toLowerCase()).toList(),
      );
    } else {
      isAnswerCorrect = answer.toString().trim().toLowerCase() == 
                       correctAnswer.toString().trim().toLowerCase();
    }
    
    return copyWith(
      userAnswer: answer.toString(),
      isCorrect: isAnswerCorrect,
      isAttempted: true,
    );
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}

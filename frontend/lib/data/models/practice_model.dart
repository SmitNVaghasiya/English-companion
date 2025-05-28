// Question types and practice models

enum PracticeQuestionType {
  multipleChoice,
  fillInTheBlank,
  reorder,
  trueFalse,
}

class PracticeSession {
  final String id;
  final String title;
  final String description;
  final String topicId; // Related grammar topic
  final List<PracticeQuestion> questions;
  final int timeLimit; // In seconds, 0 means no limit
  final int difficulty; // 1-5 scale

  PracticeSession({
    required this.id,
    required this.title,
    required this.description,
    required this.topicId,
    required this.questions,
    this.timeLimit = 0,
    this.difficulty = 1,
  });

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      topicId: json['topicId'] as String,
      timeLimit: json['timeLimit'] as int? ?? 0,
      difficulty: json['difficulty'] as int? ?? 1,
      questions: (json['questions'] as List)
          .map((q) => PracticeQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PracticeQuestion {
  final String id;
  final String question;
  final PracticeQuestionType type;
  final List<String> options; // For multiple choice and reorder
  final String correctAnswer;
  final String explanation;
  final String? hint;

  PracticeQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.hint,
  });

  factory PracticeQuestion.fromJson(Map<String, dynamic> json) {
    return PracticeQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      type: _getQuestionTypeFromString(json['type'] as String),
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
      hint: json['hint'] as String?,
    );
  }

  static PracticeQuestionType _getQuestionTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'multiplechoice':
        return PracticeQuestionType.multipleChoice;
      case 'fillintheblank':
        return PracticeQuestionType.fillInTheBlank;
      case 'reorder':
        return PracticeQuestionType.reorder;
      case 'truefalse':
        return PracticeQuestionType.trueFalse;
      default:
        return PracticeQuestionType.multipleChoice;
    }
  }
}

class PracticeResult {
  final String sessionId;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpent; // In seconds
  final DateTime completedAt;
  final Map<String, bool> questionResults; // QuestionId -> isCorrect

  PracticeResult({
    required this.sessionId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpent,
    required this.completedAt,
    required this.questionResults,
  });

  double get scorePercentage => (correctAnswers / totalQuestions) * 100;

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeSpent': timeSpent,
      'completedAt': completedAt.toIso8601String(),
      'questionResults': questionResults,
      'scorePercentage': scorePercentage,
    };
  }
}

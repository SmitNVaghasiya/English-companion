import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/practice_model.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_endpoints.dart';

/// Service class to manage practice sessions and results.
class PracticeService {
  /// Cache for storing practice results to avoid redundant API calls.
  final Map<String, PracticeResult> _resultsCache = {};

  /// Fetches a list of practice sessions for a given topic ID.
  Future<List<PracticeSession>> getPracticeSessions(String topicId) async {
    try {
      final baseUrl = await ApiConfig.baseUrl;
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl${AppEndpoints.practiceSessions}?topicId=$topicId',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.isEmpty
            ? _getMockPracticeSessions(topicId)
            : data.map((json) => PracticeSession.fromJson(json)).toList();
      }
      debugPrint('Falling back to mock data for topicId: $topicId');
      return _getMockPracticeSessions(topicId);
    } catch (e) {
      debugPrint('Error fetching practice sessions for topicId $topicId: $e');
      return _getMockPracticeSessions(topicId);
    }
  }

  /// Retrieves a specific practice session by its ID.
  Future<PracticeSession> getPracticeSession(String sessionId) async {
    try {
      final baseUrl = await ApiConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl${AppEndpoints.practiceSessions}/$sessionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return PracticeSession.fromJson(json.decode(response.body));
      }
      throw Exception(
        'Failed to load practice session: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Error fetching session $sessionId: $e');
      return _getMockPracticeSessions(
        'mock',
      ).firstWhere((s) => s.id == sessionId, orElse: () => throw e);
    }
  }

  /// Submits a practice result to the server or caches it locally on failure.
  Future<void> submitPracticeResult(PracticeResult result) async {
    try {
      final baseUrl = await ApiConfig.baseUrl;
      await http.post(
        Uri.parse('$baseUrl${AppEndpoints.practiceResults}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(result.toJson()),
      );
      _resultsCache[result.sessionId] = result;
    } catch (e) {
      debugPrint('Error submitting result for session ${result.sessionId}: $e');
      _resultsCache[result.sessionId] = result; // Cache locally
    }
  }

  /// Gets the practice status and score for a session from the cache.
  Future<Map<String, String>> getPracticeStatus(String sessionId) async {
    if (_resultsCache.containsKey(sessionId)) {
      final result = _resultsCache[sessionId]!;
      final score =
          (result.correctAnswers / result.totalQuestions * 100).toInt();
      return {
        'status':
            result.correctAnswers == result.totalQuestions
                ? 'completed'
                : 'attempted',
        'score': '$score%',
      };
    }
    return {'status': 'not_attempted', 'score': '0%'};
  }

  /// Generates mock practice sessions for testing or fallback.
  List<PracticeSession> _getMockPracticeSessions(String topicId) {
    return [
      PracticeSession(
        id: 'practice1_$topicId',
        title: 'Basic Practice - $topicId',
        description:
            'Test your understanding of ${topicId.replaceAll('_', ' ')}',
        topicId: topicId,
        difficulty: 1,
        questions: [
          PracticeQuestion(
            id: 'q1',
            question:
                'What is the correct form for ${topicId.replaceAll('_', ' ')}?',
            type: PracticeQuestionType.multipleChoice,
            options: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
            correctAnswer: 'Option 2',
            explanation: 'This is a basic example for $topicId.',
            hint: null,
          ),
          PracticeQuestion(
            id: 'q2',
            question: 'Fill in: "I ___ $topicId."',
            type: PracticeQuestionType.fillInTheBlank,
            options: [], // No options for fill-in-the-blank
            correctAnswer: 'understand',
            explanation: 'Simple practice for $topicId.',
            hint: null,
          ),
        ],
      ),
    ];
  }
}

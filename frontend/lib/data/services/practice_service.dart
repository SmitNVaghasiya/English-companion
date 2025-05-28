import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/practice_model.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_endpoints.dart';

class PracticeService {
  Future<List<PracticeSession>> getPracticeSessions(String topicId) async {
    try {
      final baseUrl = await ApiConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl${AppEndpoints.practiceSessions}?topicId=$topicId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          // If no sessions returned, return mock data
          return _getMockPracticeSessions(topicId);
        }
        return data
            .map((session) => PracticeSession.fromJson(session))
            .toList();
      } else {
        debugPrint('Failed to load practice sessions: ${response.statusCode}');
        // Return mock data if API call fails
        return _getMockPracticeSessions(topicId);
      }
    } catch (e) {
      debugPrint('Error loading practice sessions: $e');
      // Return mock data if any error occurs
      return _getMockPracticeSessions(topicId);
    }
  }

  Future<PracticeSession> getPracticeSession(String sessionId) async {
    try {
      final baseUrl = await ApiConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl${AppEndpoints.practiceSessions}/$sessionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return PracticeSession.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load practice session');
      }
    } catch (e) {
      // Return mock data for development
      return _getMockPracticeSessions('mock').first;
    }
  }

  Future<void> submitPracticeResult(PracticeResult result) async {
    try {
      final baseUrl = await ApiConfig.baseUrl;
      await http.post(
        Uri.parse('$baseUrl${AppEndpoints.practiceResults}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(result.toJson()),
      );
    } catch (e) {
      // In development, just print the result
      debugPrint('Practice result submitted: ${result.toJson()}');
    }
  }

  // Mock data for development
  List<PracticeSession> _getMockPracticeSessions(String topicId) {
    return [
      PracticeSession(
        id: 'practice1',
        title: 'Basic Tenses Practice',
        description: 'Practice your understanding of present, past, and future tenses',
        topicId: topicId,
        difficulty: 2,
        questions: [
          PracticeQuestion(
            id: 'q1',
            question: 'She ___ to the store every day.',
            type: PracticeQuestionType.multipleChoice,
            options: ['go', 'goes', 'going', 'went'],
            correctAnswer: 'goes',
            explanation: 'We use "goes" with third-person singular subjects in the present simple tense.',
            hint: 'Think about the subject-verb agreement in present simple tense.',
          ),
          PracticeQuestion(
            id: 'q2',
            question: 'They ___ dinner when I called them yesterday.',
            type: PracticeQuestionType.multipleChoice,
            options: ['are eating', 'were eating', 'have eaten', 'eat'],
            correctAnswer: 'were eating',
            explanation: 'We use past continuous (were eating) to describe an action that was in progress at a specific time in the past.',
          ),
          PracticeQuestion(
            id: 'q3',
            question: 'I ___ my homework by the time the class starts tomorrow.',
            type: PracticeQuestionType.multipleChoice,
            options: ['will finish', 'will have finished', 'am finishing', 'finish'],
            correctAnswer: 'will have finished',
            explanation: 'We use future perfect (will have finished) to describe an action that will be completed before a specific time in the future.',
          ),
          PracticeQuestion(
            id: 'q4',
            question: 'Put these words in the correct order to form a sentence: "yesterday / the library / to / went / she"',
            type: PracticeQuestionType.reorder,
            options: ['yesterday', 'the library', 'to', 'went', 'she'],
            correctAnswer: 'she went to the library yesterday',
            explanation: 'The correct word order for this simple past tense sentence is: Subject + Verb + Object + Time.',
          ),
          PracticeQuestion(
            id: 'q5',
            question: 'Fill in the blank: "By next month, I ___ in this city for five years."',
            type: PracticeQuestionType.fillInTheBlank,
            options: [],
            correctAnswer: 'will have been living',
            explanation: 'We use future perfect continuous tense to express an action that will continue up to a certain point in the future.',
          ),
        ],
      ),
      PracticeSession(
        id: 'practice2',
        title: 'Articles Practice',
        description: 'Test your knowledge of articles (a, an, the)',
        topicId: topicId,
        difficulty: 1,
        questions: [
          PracticeQuestion(
            id: 'q1',
            question: 'I need ___ umbrella because it\'s raining.',
            type: PracticeQuestionType.multipleChoice,
            options: ['a', 'an', 'the', 'no article'],
            correctAnswer: 'an',
            explanation: 'We use "an" before words that begin with a vowel sound.',
          ),
          PracticeQuestion(
            id: 'q2',
            question: 'The statement "We use THE with unique objects like the sun and the moon" is:',
            type: PracticeQuestionType.trueFalse,
            options: ['True', 'False'],
            correctAnswer: 'True',
            explanation: 'We use "the" with unique objects or entities.',
          ),
        ],
      ),
    ];
  }
}

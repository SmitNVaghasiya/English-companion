import 'package:flutter/material.dart';
import '../../data/models/grammar_topic.dart' as models;

class GrammarService {
  final Map<String, GrammarTopic> _topicCache = {};

  Future<GrammarTopic> getGrammarTopic(String topicId) async {
    try {
      if (_topicCache.containsKey(topicId)) return _topicCache[topicId]!;
      final topic = _fetchGrammarTopic(topicId);
      _topicCache[topicId] = topic;
      return topic;
    } catch (e) {
      debugPrint('Error getting grammar topic $topicId: $e');
      rethrow;
    }
  }

  GrammarTopic _fetchGrammarTopic(String topicId) {
    switch (topicId) {
      case 'parts_of_speech':
        return _getPartsOfSpeechTopic();
      case 'verb_tenses':
        return _getVerbTensesTopic();
      case 'sentence_structure':
        return _getSentenceStructureTopic();
      case 'articles':
        return _getArticlesTopic();
      case 'prepositions':
        return _getPrepositionsTopic();
      case 'modals':
        return _getModalsTopic();
      case 'conditionals':
        return _getConditionalsTopic();
      case 'passive_voice':
        return _getPassiveVoiceTopic();
      default:
        throw Exception('Topic not found: $topicId');
    }
  }

  GrammarTopic _getPartsOfSpeechTopic() {
    return GrammarTopic(
      id: 'parts_of_speech',
      title: 'Parts of Speech',
      icon: Icons.category_outlined,
      shortDescription: 'Nouns, verbs, adjectives, and more',
      introduction:
          'Parts of speech are the building blocks of language, categorizing words based on their syntactic roles within sentences. Mastery of these categories enhances clarity and precision in communication.',
      detailedExplanation:
          'In English, words are classified into eight main parts of speech based on their function:\n\n'
          '1. **Nouns**: Name people, places, things, or ideas. They can be common (e.g., "dog"), proper (e.g., "London"), abstract (e.g., "happiness"), or concrete (e.g., "table").\n'
          '2. **Pronouns**: Replace nouns to avoid repetition (e.g., "she", "it").\n'
          '3. **Verbs**: Indicate actions (e.g., "run"), states (e.g., "is"), or occurrences.\n'
          '4. **Adjectives**: Describe nouns (e.g., "blue", "tall").\n'
          '5. **Adverbs**: Modify verbs, adjectives, or other adverbs (e.g., "quickly").\n'
          '6. **Prepositions**: Show relationships (e.g., "in", "on").\n'
          '7. **Conjunctions**: Connect elements (e.g., "and", "but").\n'
          '8. **Interjections**: Express emotions (e.g., "Wow!").\n\n'
          'Understanding these roles is crucial for constructing grammatically correct sentences.',
      rules:
          () => [
            models.GrammarRule(
              title: 'Nouns',
              description:
                  'Name entities. Can act as subjects, objects, or complements.',
            ),
            models.GrammarRule(
              title: 'Pronouns',
              description: 'Substitute for nouns to avoid repetition.',
            ),
            models.GrammarRule(
              title: 'Verbs',
              description:
                  'Express actions or states; essential for sentence completion.',
            ),
            models.GrammarRule(
              title: 'Adjectives',
              description: 'Modify nouns, providing detail or description.',
            ),
            models.GrammarRule(
              title: 'Adverbs',
              description:
                  'Modify verbs, adjectives, or adverbs, often ending in -ly.',
            ),
            models.GrammarRule(
              title: 'Prepositions',
              description: 'Indicate relationships like place or time.',
            ),
            models.GrammarRule(
              title: 'Conjunctions',
              description: 'Link words or clauses.',
            ),
            models.GrammarRule(
              title: 'Interjections',
              description: 'Express sudden emotion, often standalone.',
            ),
          ],
      examples:
          () => [
            models.GrammarExample(
              title: 'Nouns',
              correct: 'The dog barked loudly in the park.',
              explanation:
                  '"Dog" and "park" are nouns naming a thing and a place.',
            ),
            models.GrammarExample(
              title: 'Pronouns',
              correct: 'She gave him the book.',
              explanation: '"She" and "him" replace specific nouns.',
            ),
            models.GrammarExample(
              title: 'Verbs',
              correct: 'They run every morning.',
              explanation: '"Run" is an action verb.',
            ),
            models.GrammarExample(
              title: 'Adjectives',
              correct: 'The tall tree swayed in the wind.',
              explanation: '"Tall" describes the noun "tree".',
            ),
            models.GrammarExample(
              title: 'Adverbs',
              correct: 'She sings beautifully.',
              explanation: '"Beautifully" modifies the verb "sings".',
            ),
            models.GrammarExample(
              title: 'Prepositions',
              correct: 'The cat is on the roof.',
              explanation:
                  '"On" shows the relationship between "cat" and "roof".',
            ),
            models.GrammarExample(
              title: 'Conjunctions',
              correct: 'I wanted to go, but it rained.',
              explanation: '"But" connects two clauses.',
            ),
            models.GrammarExample(
              title: 'Interjections',
              correct: 'Wow! That\'s amazing!',
              explanation: '"Wow" expresses surprise.',
            ),
            models.GrammarExample(
              title: 'Mixed Example',
              correct: 'He quickly ran to the store and bought milk.',
              explanation:
                  'Contains multiple parts: "He" (pronoun), "ran" (verb), "quickly" (adverb), "to" (preposition), "store" (noun), "and" (conjunction), "bought" (verb), "milk" (noun).',
            ),
            models.GrammarExample(
              title: 'Abstract Nouns',
              correct: 'Happiness filled the room.',
              explanation: '"Happiness" is an abstract noun.',
            ),
          ],
      practiceSentences:
          () => [
            models.GrammarExample(
              title: 'Identify Parts of Speech',
              correct: 'The quick brown fox jumps over the lazy dog.',
              explanation: 'A classic sentence containing all parts of speech.',
            ),
            models.GrammarExample(
              title: 'Mixed Practice',
              correct:
                  'She quickly ran to the store and bought some fresh bread.',
              explanation:
                  'Practice identifying different parts of speech in this sentence.',
            ),
            models.GrammarExample(
              title: 'Adjective Practice',
              correct:
                  'The beautiful sunset painted the sky with vibrant colors.',
              explanation: 'Focus on identifying adjectives in this sentence.',
            ),
            models.GrammarExample(
              title: 'Verb Practice',
              correct: 'The children played happily in the park all afternoon.',
              explanation: 'Identify the action verbs in this sentence.',
            ),
            models.GrammarExample(
              title: 'Preposition Practice',
              correct: 'The book on the table belongs to my sister.',
              explanation: 'Find the prepositions in this sentence.',
            ),
          ],
      practiceQuestions:
          () => [
            GrammarQuestion(
              question: 'Which word is a noun? "The cat sleeps quietly."',
              type: 'multiple_choice',
              options: ['The', 'cat', 'sleeps', 'quietly'],
              correctAnswer: 'cat',
              explanation: '"Cat" is a noun naming an animal.',
            ),
            GrammarQuestion(
              question: 'Identify the verb: "She dances gracefully."',
              type: 'multiple_choice',
              options: ['She', 'dances', 'gracefully', 'none'],
              correctAnswer: 'dances',
              explanation: '"Dances" is the action verb.',
            ),
            GrammarQuestion(
              question: 'Which is an adjective? "The bright sun shines."',
              type: 'multiple_choice',
              options: ['The', 'bright', 'sun', 'shines'],
              correctAnswer: 'bright',
              explanation: '"Bright" describes the noun "sun".',
            ),
            GrammarQuestion(
              question: 'Find the adverb: "He runs very fast."',
              type: 'multiple_choice',
              options: ['He', 'runs', 'very', 'fast'],
              correctAnswer: 'very',
              explanation: '"Very" modifies the adverb "fast".',
            ),
            GrammarQuestion(
              question:
                  'Which is a preposition? "The book is under the table."',
              type: 'multiple_choice',
              options: ['book', 'is', 'under', 'table'],
              correctAnswer: 'under',
              explanation:
                  '"Under" shows the position of the book relative to the table.',
            ),
            GrammarQuestion(
              question: 'Identify the conjunction: "I like tea and coffee."',
              type: 'multiple_choice',
              options: ['I', 'like', 'and', 'coffee'],
              correctAnswer: 'and',
              explanation: '"And" connects "tea" and "coffee".',
            ),
            GrammarQuestion(
              question: 'Which is a pronoun? "They went home."',
              type: 'multiple_choice',
              options: ['They', 'went', 'home', 'none'],
              correctAnswer: 'They',
              explanation: '"They" replaces a specific group of people.',
            ),
            GrammarQuestion(
              question: 'Find the interjection: "Ouch! That hurts!"',
              type: 'multiple_choice',
              options: ['Ouch', 'That', 'hurts', '!'],
              correctAnswer: 'Ouch',
              explanation: '"Ouch" expresses sudden pain.',
            ),
            GrammarQuestion(
              question: 'Is "quickly" an adverb? "She runs quickly."',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'True',
              explanation: '"Quickly" modifies the verb "runs".',
            ),
            GrammarQuestion(
              question: 'Fill in the blank with a noun: "The ___ jumped high."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'dog',
              explanation:
                  '"Dog" is a noun that fits as the subject performing the action.',
            ),
            GrammarQuestion(
              question: 'Reorder to form a sentence: "sang / she / loudly"',
              type: 'reorder',
              options: ['sang', 'she', 'loudly'],
              correctAnswer: 'she sang loudly',
              explanation:
                  'Correct order: Subject (she) + Verb (sang) + Adverb (loudly).',
            ),
          ],
    );
  }

  GrammarTopic _getVerbTensesTopic() {
    return GrammarTopic(
      id: 'verb_tenses',
      title: 'Verb Tenses',
      icon: Icons.access_time_outlined,
      shortDescription: 'Past, present, and future tenses',
      introduction:
          'Verb tenses indicate when an action occurs—past, present, or future. Each tense has aspects (simple, continuous, perfect, perfect continuous) that refine its meaning.',
      detailedExplanation:
          'English verbs use tense to show time:\n\n'
          '- **Present**: Actions now or habits (e.g., "I walk").\n'
          '- **Past**: Completed actions (e.g., "I walked").\n'
          '- **Future**: Actions to come (e.g., "I will walk").\n\n'
          'Aspects:\n'
          '1. **Simple**: General facts or routines.\n'
          '2. **Continuous**: Ongoing actions.\n'
          '3. **Perfect**: Completed actions with relevance.\n'
          '4. **Perfect Continuous**: Ongoing actions with duration.\n\n'
          'Correct tense usage ensures clear communication of timing.',
      rules:
          () => [
            models.GrammarRule(
              title: 'Simple Present',
              description:
                  'Habits and facts: base verb (+s for 3rd person singular).',
            ),
            models.GrammarRule(
              title: 'Present Continuous',
              description: 'Current actions: am/is/are + verb-ing.',
            ),
            models.GrammarRule(
              title: 'Simple Past',
              description: 'Completed actions: verb + -ed or irregular form.',
            ),
            models.GrammarRule(
              title: 'Past Continuous',
              description: 'Ongoing past actions: was/were + verb-ing.',
            ),
            models.GrammarRule(
              title: 'Future Simple',
              description: 'Future actions: will + base verb.',
            ),
            models.GrammarRule(
              title: 'Present Perfect',
              description:
                  'Past with present impact: have/has + past participle.',
            ),
            models.GrammarRule(
              title: 'Past Perfect',
              description: 'Before another past action: had + past participle.',
            ),
            models.GrammarRule(
              title: 'Future Perfect',
              description:
                  'Completed by a future time: will have + past participle.',
            ),
          ],
      examples:
          () => [
            models.GrammarExample(
              title: 'Simple Present',
              correct: 'I eat breakfast daily.',
              explanation: 'Simple present for habits.',
            ),
            models.GrammarExample(
              title: 'Present Continuous',
              correct: 'She is reading a book now.',
              explanation: 'Present continuous for current action.',
            ),
            models.GrammarExample(
              title: 'Simple Past',
              correct: 'He walked to school yesterday.',
              explanation: 'Simple past for completed action.',
            ),
            models.GrammarExample(
              title: 'Past Continuous',
              correct: 'They were playing when it rained.',
              explanation: 'Past continuous for ongoing action.',
            ),
            models.GrammarExample(
              title: 'Future Simple',
              correct: 'I will call you tomorrow.',
              explanation: 'Future simple for prediction.',
            ),
            models.GrammarExample(
              title: 'Present Perfect',
              correct: 'We have just finished dinner.',
              explanation: 'Present perfect for recent action.',
            ),
            models.GrammarExample(
              title: 'Past Perfect',
              correct: 'She had left before he arrived.',
              explanation: 'Past perfect for earlier action.',
            ),
            models.GrammarExample(
              title: 'Future Perfect',
              correct: 'By 5 PM, I will have completed this.',
              explanation: 'Future perfect for future completion.',
            ),
            models.GrammarExample(
              title: 'Present Continuous Temporary',
              correct: 'I am studying English this semester.',
              explanation: 'Present continuous for temporary action.',
            ),
            models.GrammarExample(
              title: 'Present Perfect Ongoing',
              correct: 'They have lived here for years.',
              explanation: 'Present perfect for ongoing state.',
            ),
          ],
      practiceSentences: () => [],
      practiceQuestions:
          () => [
            GrammarQuestion(
              question: 'Choose the correct tense: "She ___ every day."',
              type: 'multiple_choice',
              options: ['walks', 'walking', 'walked', 'will walk'],
              correctAnswer: 'walks',
              explanation: 'Simple present is used for daily habits.',
            ),
            GrammarQuestion(
              question: 'What tense is this? "I am writing a letter."',
              type: 'multiple_choice',
              options: [
                'Present Simple',
                'Present Continuous',
                'Past Simple',
                'Future Simple',
              ],
              correctAnswer: 'Present Continuous',
              explanation:
                  'The sentence shows an ongoing action happening now.',
            ),
            GrammarQuestion(
              question: 'Fill in: "They ___ when I called."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'were sleeping',
              explanation:
                  'Past continuous describes an ongoing action interrupted by another past event.',
            ),
            GrammarQuestion(
              question:
                  'True or False: "I will have finished by tomorrow" is Future Perfect.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'True',
              explanation:
                  '"Will have" + past participle indicates the Future Perfect tense.',
            ),
            GrammarQuestion(
              question: 'Reorder: "finished / have / I / just"',
              type: 'reorder',
              options: ['finished', 'have', 'I', 'just'],
              correctAnswer: 'I have just finished',
              explanation:
                  'Present perfect structure: Subject + have + just + past participle.',
            ),
            GrammarQuestion(
              question: 'Choose: "He ___ here since 2010."',
              type: 'multiple_choice',
              options: ['lives', 'has lived', 'lived', 'is living'],
              correctAnswer: 'has lived',
              explanation:
                  'Present perfect indicates an action starting in the past and continuing to now.',
            ),
            GrammarQuestion(
              question: 'What tense? "She had eaten before leaving."',
              type: 'multiple_choice',
              options: [
                'Past Simple',
                'Past Continuous',
                'Past Perfect',
                'Present Perfect',
              ],
              correctAnswer: 'Past Perfect',
              explanation:
                  'Past perfect shows an action completed before another past action.',
            ),
            GrammarQuestion(
              question: 'Fill in: "By next year, we ___ this project."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'will have completed',
              explanation:
                  'Future perfect indicates completion by a specific future time.',
            ),
            GrammarQuestion(
              question: 'Choose: "I ___ TV when the phone rang."',
              type: 'multiple_choice',
              options: ['watch', 'watched', 'was watching', 'have watched'],
              correctAnswer: 'was watching',
              explanation:
                  'Past continuous describes an ongoing action interrupted by another event.',
            ),
            GrammarQuestion(
              question:
                  'True or False: "I eat now" is correct for current action.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'False',
              explanation:
                  'Present continuous "I am eating now" is correct for current actions.',
            ),
          ],
    );
  }

  GrammarTopic _getSentenceStructureTopic() {
    return GrammarTopic(
      id: 'sentence_structure',
      title: 'Sentence Structure',
      icon: Icons.format_align_left_outlined,
      shortDescription: 'Building correct English sentences',
      introduction:
          'Sentence structure refers to the arrangement of words to form meaningful sentences. English typically follows a Subject-Verb-Object (SVO) order.',
      detailedExplanation:
          'English sentences have key patterns:\n\n'
          '- **SVO**: "She eats apples."\n'
          '- **SVC**: "He is happy." (Complement describes subject)\n'
          '- **SVA**: "They run quickly." (Adverbial modifies verb)\n'
          '- **SVOO**: "She gave him a gift." (Two objects: indirect + direct)\n'
          '- **SVOC**: "They made her captain." (Object + complement)\n\n'
          'Types include simple, compound, complex, and compound-complex sentences, each serving different purposes.',
      rules:
          () => [
            models.GrammarRule(
              title: 'Subject-Verb-Object',
              description: 'Basic structure: Subject performs Verb on Object.',
            ),
            models.GrammarRule(
              title: 'Simple Sentence',
              description: 'One independent clause.',
            ),
            models.GrammarRule(
              title: 'Compound Sentence',
              description: 'Two+ independent clauses joined by conjunctions.',
            ),
            models.GrammarRule(
              title: 'Complex Sentence',
              description: 'Independent + dependent clause(s).',
            ),
            models.GrammarRule(
              title: 'Word Order',
              description: 'Typically SVO; deviations can confuse meaning.',
            ),
          ],
      examples:
          () => [
            models.GrammarExample(
              title: 'SVO Pattern',
              correct: 'The dog chased the cat.',
              explanation:
                  'SVO: "dog" (subject), "chased" (verb), "cat" (object).',
            ),
            models.GrammarExample(
              title: 'SVC Pattern',
              correct: 'She is a teacher.',
              explanation:
                  'SVC: "She" (subject), "is" (verb), "teacher" (complement).',
            ),
            models.GrammarExample(
              title: 'SVA Pattern',
              correct: 'He runs fast.',
              explanation:
                  'SVA: "He" (subject), "runs" (verb), "fast" (adverbial).',
            ),
            models.GrammarExample(
              title: 'SVOO Pattern',
              correct: 'They gave her a book.',
              explanation:
                  'SVOO: "They" (subject), "gave" (verb), "her" (indirect object), "book" (direct object).',
            ),
            models.GrammarExample(
              title: 'SVOC Pattern',
              correct: 'We elected him president.',
              explanation:
                  'SVOC: "We" (subject), "elected" (verb), "him" (object), "president" (complement).',
            ),
            models.GrammarExample(
              title: 'Compound Sentence',
              correct: 'I study, and she sleeps.',
              explanation: 'Compound: Two independent clauses with "and".',
            ),
            models.GrammarExample(
              title: 'Complex Sentence',
              correct: 'If it rains, we stay home.',
              explanation:
                  'Complex: Dependent ("If it rains") + Independent ("we stay home").',
            ),
            models.GrammarExample(
              title: 'SVA with Adverbial',
              correct: 'The sun shines brightly every day.',
              explanation: 'SVA with time adverbial.',
            ),
            models.GrammarExample(
              title: 'Complex with Subordinate Clause',
              correct: 'She cooked dinner because he was hungry.',
              explanation: 'Complex with subordinating conjunction.',
            ),
            models.GrammarExample(
              title: 'Compound-Complex Sentence',
              correct: 'They laughed, but she cried after the movie.',
              explanation: 'Compound-complex structure.',
            ),
          ],
      practiceSentences: () => [],
      practiceQuestions:
          () => [
            GrammarQuestion(
              question: 'Identify the pattern: "She sings well."',
              type: 'multiple_choice',
              options: ['SVO', 'SVC', 'SVA', 'SVOO'],
              correctAnswer: 'SVA',
              explanation: 'Subject (She) + Verb (sings) + Adverbial (well).',
            ),
            GrammarQuestion(
              question: 'Which is a simple sentence?',
              type: 'multiple_choice',
              options: [
                'I run.',
                'I run, and she walks.',
                'If I run, she walks.',
                'I run when she walks.',
              ],
              correctAnswer: 'I run.',
              explanation: 'A simple sentence has one independent clause.',
            ),
            GrammarQuestion(
              question: 'Fill in: "He ___ her a letter." (SVOO)',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'gave',
              explanation:
                  'SVOO: Subject + Verb + Indirect Object (her) + Direct Object (a letter).',
            ),
            GrammarQuestion(
              question: 'True or False: "She is happy" is SVC.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'True',
              explanation:
                  'SVC: Subject (She) + Verb (is) + Complement (happy).',
            ),
            GrammarQuestion(
              question: 'Reorder: "bought / she / a car"',
              type: 'reorder',
              options: ['bought', 'she', 'a car'],
              correctAnswer: 'she bought a car',
              explanation:
                  'SVO: Subject (she) + Verb (bought) + Object (a car).',
            ),
            GrammarQuestion(
              question:
                  'Which is complex? "I left because it rained." or "I left."',
              type: 'multiple_choice',
              options: ['I left because it rained.', 'I left.'],
              correctAnswer: 'I left because it rained.',
              explanation:
                  'Complex sentences have an independent and a dependent clause.',
            ),
            GrammarQuestion(
              question: 'Identify: "They made him leader."',
              type: 'multiple_choice',
              options: ['SVO', 'SVC', 'SVOC', 'SVA'],
              correctAnswer: 'SVOC',
              explanation:
                  'SVOC: Subject (They) + Verb (made) + Object (him) + Complement (leader).',
            ),
            GrammarQuestion(
              question: 'Fill in: "The cat ___ on the mat." (SVA)',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'slept',
              explanation:
                  'SVA: Subject (The cat) + Verb (slept) + Adverbial (on the mat).',
            ),
          ],
    );
  }

  GrammarTopic _getArticlesTopic() {
    return GrammarTopic(
      id: 'articles',
      title: 'Articles',
      icon: Icons.article_outlined,
      shortDescription: 'A, an, and the',
      introduction:
          'Articles ("a", "an", "the") are determiners that specify whether a noun is general or specific. Their correct use enhances clarity in communication.',
      detailedExplanation:
          '- **Indefinite Articles (a, an)**: Used for unspecified singular countable nouns. "A" before consonant sounds, "an" before vowel sounds.\n'
          '- **Definite Article (the)**: Used for specific nouns, unique items, or previously mentioned entities.\n'
          '- **Zero Article**: No article for general plural/uncountable nouns or certain proper nouns.\n\n'
          'Choosing the right article depends on context and pronunciation.',
      rules:
          () => [
            models.GrammarRule(
              title: 'A vs. An',
              description: 'Based on sound: "a cat", "an apple".',
            ),
            models.GrammarRule(
              title: 'The',
              description: 'Specific or unique: "the sun", "the book I read".',
            ),
            models.GrammarRule(
              title: 'Zero Article',
              description:
                  'Generalizations: "Dogs bark", "Water is essential".',
            ),
          ],
      examples:
          () => [
            models.GrammarExample(
              title: 'Indefinite Article A',
              correct: 'I saw a bird.',
              explanation: 'First mention, unspecified.',
            ),
            models.GrammarExample(
              title: 'Indefinite Article An',
              correct: 'An elephant is big.',
              explanation: 'Vowel sound triggers "an".',
            ),
            models.GrammarExample(
              title: 'Definite Article The',
              correct: 'The moon shines at night.',
              explanation: 'Unique entity.',
            ),
            models.GrammarExample(
              title: 'Zero Article',
              correct: 'Cats love fish.',
              explanation: 'General statement, zero article.',
            ),
            models.GrammarExample(
              title: 'Article Progression',
              correct: 'She bought a car. The car is red.',
              explanation: 'First "a", then "the" for specificity.',
            ),
            models.GrammarExample(
              title: 'Vowel Sound Article',
              correct: 'An hour passed.',
              explanation: 'Silent "h", vowel sound.',
            ),
            models.GrammarExample(
              title: 'Specific Articles',
              correct: 'The teacher explained the lesson.',
              explanation: 'Specific teacher and lesson.',
            ),
            models.GrammarExample(
              title: 'General Uncountable Noun',
              correct: 'Water flows downhill.',
              explanation: 'General uncountable noun.',
            ),
            models.GrammarExample(
              title: 'Consonant Sound Article',
              correct: 'A university offers courses.',
              explanation: 'Consonant sound "you".',
            ),
            models.GrammarExample(
              title: 'Specific Group',
              correct: 'The children played.',
              explanation: 'Specific group.',
            ),
          ],
      practiceSentences: () => [],
      practiceQuestions:
          () => [
            GrammarQuestion(
              question: 'Fill in: "I need ___ apple."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'an',
              explanation:
                  '"An" is used before a noun starting with a vowel sound.',
            ),
            GrammarQuestion(
              question: 'Choose: "___ sun is bright."',
              type: 'multiple_choice',
              options: ['A', 'An', 'The', 'No article'],
              correctAnswer: 'The',
              explanation: '"The" is used for unique entities like the sun.',
            ),
            GrammarQuestion(
              question: 'True or False: "Dogs are friendly" uses zero article.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'True',
              explanation: 'No article is used for general plural nouns.',
            ),
            GrammarQuestion(
              question: 'Which is correct? "___ elephant"',
              type: 'multiple_choice',
              options: ['a', 'an', 'the', 'no article'],
              correctAnswer: 'an',
              explanation:
                  '"An" is correct before the vowel sound in "elephant".',
            ),
            GrammarQuestion(
              question: 'Reorder: "book / the / I / read"',
              type: 'reorder',
              options: ['book', 'the', 'I', 'read'],
              correctAnswer: 'I read the book',
              explanation: '"The" specifies the book in an SVO structure.',
            ),
            GrammarQuestion(
              question: 'Fill in: "___ happiness is key."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'no article',
              explanation: 'No article is used with general abstract nouns.',
            ),
            GrammarQuestion(
              question: 'Choose: "She is ___ teacher."',
              type: 'multiple_choice',
              options: ['a', 'an', 'the', 'no article'],
              correctAnswer: 'a',
              explanation:
                  '"A" is used for an unspecified singular countable noun.',
            ),
            GrammarQuestion(
              question: 'True or False: "The London" is correct.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'False',
              explanation:
                  'Proper nouns like "London" typically use no article.',
            ),
          ],
    );
  }

  GrammarTopic _getPrepositionsTopic() {
    return GrammarTopic(
      id: 'prepositions',
      title: 'Prepositions',
      icon: Icons.place_outlined,
      shortDescription: 'In, on, at, and more',
      introduction:
          'Prepositions link nouns or pronouns to other words, showing relationships like place, time, or direction.',
      detailedExplanation:
          '- **Place**: "in" (enclosed), "on" (surface), "at" (point).\n'
          '- **Time**: "at" (specific time), "on" (days), "in" (months/years).\n'
          '- **Direction**: "to", "into", "across".\n'
          'Prepositions are often idiomatic, requiring memorization.',
      rules:
          () => [
            models.GrammarRule(
              title: 'Place',
              description:
                  '"In" for areas, "on" for surfaces, "at" for points.',
            ),
            models.GrammarRule(
              title: 'Time',
              description:
                  '"At" for times, "on" for days, "in" for longer periods.',
            ),
            models.GrammarRule(
              title: 'Direction',
              description: 'Show movement: "to", "through", "across".',
            ),
          ],
      examples:
          () => [
            models.GrammarExample(
              title: 'Preposition of Place',
              correct: 'The cat is on the mat.',
              explanation: '"On" for surface.',
            ),
            models.GrammarExample(
              title: 'Preposition of Time',
              correct: 'We meet at 5 PM.',
              explanation: '"At" for specific time.',
            ),
            models.GrammarExample(
              title: 'Preposition of Place City',
              correct: 'She lives in Paris.',
              explanation: '"In" for large area.',
            ),
            models.GrammarExample(
              title: 'Preposition of Direction',
              correct: 'He walked to the park.',
              explanation: '"To" for direction.',
            ),
            models.GrammarExample(
              title: 'Preposition of Time Day',
              correct: 'The meeting is on Monday.',
              explanation: '"On" for day.',
            ),
            models.GrammarExample(
              title: 'Preposition of Movement',
              correct: 'They swam across the river.',
              explanation: '"Across" for movement.',
            ),
            models.GrammarExample(
              title: 'Preposition of Time Since',
              correct: 'I’ve been here since morning.',
              explanation: '"Since" for starting point.',
            ),
            models.GrammarExample(
              title: 'Preposition of Position',
              correct: 'The book is under the table.',
              explanation: '"Under" for position.',
            ),
            models.GrammarExample(
              title: 'Preposition of Movement Through',
              correct: 'We traveled through the forest.',
              explanation: '"Through" for enclosed movement.',
            ),
            models.GrammarExample(
              title: 'Preposition of Duration',
              correct: 'She waited for an hour.',
              explanation: '"For" for duration.',
            ),
          ],
      practiceSentences: () => [],
      practiceQuestions:
          () => [
            GrammarQuestion(
              question: 'Fill in: "The keys are ___ the table."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'on',
              explanation: '"On" is used for objects resting on a surface.',
            ),
            GrammarQuestion(
              question: 'Choose: "I’ll see you ___ 7 PM."',
              type: 'multiple_choice',
              options: ['at', 'on', 'in', 'for'],
              correctAnswer: 'at',
              explanation: '"At" is used for specific points in time.',
            ),
            GrammarQuestion(
              question: 'True or False: "In Monday" is correct.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'False',
              explanation:
                  '"On" is the correct preposition for days of the week.',
            ),
            GrammarQuestion(
              question: 'Reorder: "park / to / he / walked"',
              type: 'reorder',
              options: ['park', 'to', 'he', 'walked'],
              correctAnswer: 'he walked to the park',
              explanation: '"To" indicates direction in an SVO structure.',
            ),
            GrammarQuestion(
              question: 'Which preposition? "She lives ___ London."',
              type: 'multiple_choice',
              options: ['at', 'on', 'in', 'by'],
              correctAnswer: 'in',
              explanation: '"In" is used for large areas like cities.',
            ),
            GrammarQuestion(
              question: 'Fill in: "We’ve been here ___ yesterday."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'since',
              explanation: '"Since" indicates a starting point in time.',
            ),
            GrammarQuestion(
              question: 'Choose: "He ran ___ the street."',
              type: 'multiple_choice',
              options: ['across', 'in', 'at', 'on'],
              correctAnswer: 'across',
              explanation:
                  '"Across" indicates movement from one side to the other.',
            ),
            GrammarQuestion(
              question: 'True or False: "At the morning" is correct.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'False',
              explanation:
                  '"In the morning" is the correct phrase for parts of the day.',
            ),
          ],
    );
  }

  GrammarTopic _getModalsTopic() {
    return GrammarTopic(
      id: 'modals',
      title: 'Modals',
      icon: Icons.help_outline,
      shortDescription: 'Can, could, should, would, etc.',
      introduction:
          'Modal verbs modify main verbs to express ability, possibility, obligation, or permission.',
      detailedExplanation:
          'Modals don’t change form and are followed by base verbs:\n'
          '- **Can/Could**: Ability, possibility, permission.\n'
          '- **May/Might**: Possibility, permission.\n'
          '- **Must/Have to**: Obligation.\n'
          '- **Should**: Advice.\n'
          '- **Will/Would**: Future, hypothetical.',
      rules:
          () => [
            models.GrammarRule(
              title: 'Can',
              description: 'Present ability/permission.',
            ),
            models.GrammarRule(
              title: 'Could',
              description: 'Past ability, polite requests.',
            ),
            models.GrammarRule(
              title: 'May',
              description: 'Formal permission, possibility.',
            ),
            models.GrammarRule(
              title: 'Must',
              description: 'Strong obligation.',
            ),
            models.GrammarRule(title: 'Should', description: 'Recommendation.'),
          ],
      examples:
          () => [
            models.GrammarExample(
              title: 'Modal Can',
              correct: 'I can swim.',
              explanation: 'Present ability.',
            ),
            models.GrammarExample(
              title: 'Modal Could',
              correct: 'Could you help me?',
              explanation: 'Polite request.',
            ),
            models.GrammarExample(
              title: 'Modal May',
              correct: 'You may leave now.',
              explanation: 'Permission.',
            ),
            models.GrammarExample(
              title: 'Modal Must',
              correct: 'We must finish this.',
              explanation: 'Obligation.',
            ),
            models.GrammarExample(
              title: 'Modal Should',
              correct: 'You should rest.',
              explanation: 'Advice.',
            ),
            models.GrammarExample(
              title: 'Modal Will',
              correct: 'I will call later.',
              explanation: 'Future intention.',
            ),
            models.GrammarExample(
              title: 'Modal Might',
              correct: 'She might come.',
              explanation: 'Possibility.',
            ),
            models.GrammarExample(
              title: 'Modal Would',
              correct: 'I would go if I could.',
              explanation: 'Hypothetical.',
            ),
            models.GrammarExample(
              title: 'Modal Have To',
              correct: 'They have to attend.',
              explanation: 'External obligation.',
            ),
            models.GrammarExample(
              title: 'Modal Can Negative',
              correct: 'He can’t be late.',
              explanation: 'Impossibility.',
            ),
          ],
      practiceSentences: () => [],
      practiceQuestions:
          () => [
            GrammarQuestion(
              question: 'Fill in: "I ___ drive a car."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'can',
              explanation: '"Can" expresses present ability.',
            ),
            GrammarQuestion(
              question: 'Choose: "___ you please wait?"',
              type: 'multiple_choice',
              options: ['Can', 'Could', 'Must', 'Should'],
              correctAnswer: 'Could',
              explanation: '"Could" is used for polite requests.',
            ),
            GrammarQuestion(
              question: 'True or False: "Must" has a past form.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'False',
              explanation: '"Must" has no past form; "had to" is used instead.',
            ),
            GrammarQuestion(
              question: 'Reorder: "leave / may / you / now"',
              type: 'reorder',
              options: ['leave', 'may', 'you', 'now'],
              correctAnswer: 'you may leave now',
              explanation:
                  'Modal structure: Subject + modal (may) + base verb (leave).',
            ),
            GrammarQuestion(
              question: 'Which modal for advice? "You ___ study more."',
              type: 'multiple_choice',
              options: ['can', 'must', 'should', 'might'],
              correctAnswer: 'should',
              explanation: '"Should" is used to give advice.',
            ),
            GrammarQuestion(
              question: 'Fill in: "We ___ finish by tomorrow."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'must',
              explanation: '"Must" indicates a strong obligation.',
            ),
            GrammarQuestion(
              question: 'Choose: "She ___ be tired."',
              type: 'multiple_choice',
              options: ['can', 'might', 'must', 'will'],
              correctAnswer: 'might',
              explanation: '"Might" suggests a possibility.',
            ),
            GrammarQuestion(
              question: 'True or False: "I will to go" is correct.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'False',
              explanation:
                  'Modals like "will" are followed by a base verb without "to".',
            ),
          ],
    );
  }

  GrammarTopic _getConditionalsTopic() {
    return GrammarTopic(
      id: 'conditionals',
      title: 'Conditionals',
      icon: Icons.compare_arrows_outlined,
      shortDescription: 'If clauses and conditional sentences',
      introduction:
          'Conditionals describe outcomes dependent on conditions, using "if" clauses.',
      detailedExplanation:
          '- **Zero**: General truths (If + present, present).\n'
          '- **First**: Possible future (If + present, will + base).\n'
          '- **Second**: Unreal present/future (If + past, would + base).\n'
          '- **Third**: Unreal past (If + past perfect, would have + past participle).',
      rules:
          () => [
            models.GrammarRule(
              title: 'Zero Conditional',
              description: 'Facts: If + present, present.',
            ),
            models.GrammarRule(
              title: 'First Conditional',
              description: 'Future possibilities: If + present, will.',
            ),
            models.GrammarRule(
              title: 'Second Conditional',
              description: 'Hypothetical: If + past, would.',
            ),
            models.GrammarRule(
              title: 'Third Conditional',
              description: 'Past hypothetical: If + past perfect, would have.',
            ),
          ],
      examples:
          () => [
            models.GrammarExample(
              title: 'Zero Conditional',
              correct: 'If water boils, it evaporates.',
              explanation: 'Zero: general truth.',
            ),
            models.GrammarExample(
              title: 'First Conditional',
              correct: 'If it rains, we’ll stay home.',
              explanation: 'First: possible future.',
            ),
            models.GrammarExample(
              title: 'Second Conditional',
              correct: 'If I were rich, I’d travel.',
              explanation: 'Second: unreal present.',
            ),
            models.GrammarExample(
              title: 'Third Conditional',
              correct: 'If I had studied, I’d have passed.',
              explanation: 'Third: unreal past.',
            ),
            models.GrammarExample(
              title: 'Zero Conditional Fact',
              correct: 'If you heat ice, it melts.',
              explanation: 'Zero: scientific fact.',
            ),
            models.GrammarExample(
              title: 'First Conditional Possibility',
              correct: 'If she calls, I’ll answer.',
              explanation: 'First: future possibility.',
            ),
            models.GrammarExample(
              title: 'Second Conditional Hypothetical',
              correct: 'If he knew, he’d tell us.',
              explanation: 'Second: hypothetical.',
            ),
            models.GrammarExample(
              title: 'Third Conditional Past',
              correct: 'If they’d arrived early, we’d have started.',
              explanation: 'Third: past.',
            ),
            models.GrammarExample(
              title: 'First Conditional Outcome',
              correct: 'If I win, I’ll celebrate.',
              explanation: 'First: possible outcome.',
            ),
            models.GrammarExample(
              title: 'Third Conditional Reaction',
              correct: 'If she had seen it, she’d have reacted.',
              explanation: 'Third: past.',
            ),
          ],
      practiceSentences: () => [],
      practiceQuestions:
          () => [
            GrammarQuestion(
              question: 'Fill in: "If it ___ , the ground gets wet."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'rains',
              explanation:
                  'Zero conditional uses present simple for general truths.',
            ),
            GrammarQuestion(
              question: 'Choose: "If I ___ time, I’ll help."',
              type: 'multiple_choice',
              options: ['have', 'had', 'will have', 'having'],
              correctAnswer: 'have',
              explanation:
                  'First conditional uses present tense in the if-clause.',
            ),
            GrammarQuestion(
              question: 'True or False: "If I were you" is Second Conditional.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'True',
              explanation:
                  'Second conditional uses past tense for unreal present situations.',
            ),
            GrammarQuestion(
              question:
                  'Reorder: "passed / had / I / studied / I’d / have / if"',
              type: 'reorder',
              options: ['passed', 'had', 'I', 'studied', 'I’d', 'have', 'if'],
              correctAnswer: 'If I had studied, I’d have passed',
              explanation:
                  'Third conditional: If + past perfect, would have + past participle.',
            ),
            GrammarQuestion(
              question: 'Which is Zero Conditional?',
              type: 'multiple_choice',
              options: [
                'If it rains, we’ll cancel.',
                'If you heat water, it boils.',
                'If I were tall, I’d play.',
                'If I had known, I’d have told.',
              ],
              correctAnswer: 'If you heat water, it boils.',
              explanation:
                  'Zero conditional describes general facts with present tenses.',
            ),
            GrammarQuestion(
              question: 'Fill in: "If he ___ harder, he’d succeed."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'worked',
              explanation:
                  'Second conditional uses past tense for hypothetical situations.',
            ),
            GrammarQuestion(
              question: 'Choose: "If she ___ early, we’d have finished."',
              type: 'multiple_choice',
              options: ['arrives', 'arrived', 'had arrived', 'will arrive'],
              correctAnswer: 'had arrived',
              explanation:
                  'Third conditional uses past perfect for unreal past events.',
            ),
            GrammarQuestion(
              question: 'True or False: "If I will go" is correct.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'False',
              explanation:
                  'First conditional uses present tense, not "will", in the if-clause.',
            ),
          ],
    );
  }

  GrammarTopic _getPassiveVoiceTopic() {
    return GrammarTopic(
      id: 'passive_voice',
      title: 'Passive Voice',
      icon: Icons.swap_horiz_outlined,
      shortDescription: 'When the subject receives the action',
      introduction:
          'Passive voice shifts focus to the action or receiver, using "be" + past participle.',
      detailedExplanation:
          'In active voice, the subject acts (e.g., "She writes a letter"). In passive, the subject receives the action (e.g., "A letter is written").\n'
          '- Used when the doer is unknown, unimportant, or to emphasize the action.\n'
          '- Structure varies by tense: "is written" (present), "was written" (past), "will be written" (future).',
      rules:
          () => [
            models.GrammarRule(
              title: 'Structure',
              description: 'Be + past participle.',
            ),
            models.GrammarRule(
              title: 'Agent',
              description: 'Optional "by" phrase for doer.',
            ),
            models.GrammarRule(
              title: 'Tense',
              description: 'Adjust "be" for tense.',
            ),
          ],
      examples:
          () => [
            models.GrammarExample(
              title: 'Past Passive',
              correct: 'The cake was baked by her.',
              explanation: 'Past passive with agent.',
            ),
            models.GrammarExample(
              title: 'Present Passive',
              correct: 'Books are read daily.',
              explanation: 'Present passive, no agent.',
            ),
            models.GrammarExample(
              title: 'Future Passive',
              correct: 'The house will be painted.',
              explanation: 'Future passive.',
            ),
            models.GrammarExample(
              title: 'Present Continuous Passive',
              correct: 'The room is being cleaned.',
              explanation: 'Present continuous passive.',
            ),
            models.GrammarExample(
              title: 'Past Passive Simple',
              correct: 'The letter was sent yesterday.',
              explanation: 'Past passive.',
            ),
            models.GrammarExample(
              title: 'Present Passive Manufacturing',
              correct: 'Cars are manufactured here.',
              explanation: 'Present passive.',
            ),
            models.GrammarExample(
              title: 'Present Perfect Passive',
              correct: 'The game has been won.',
              explanation: 'Present perfect passive.',
            ),
            models.GrammarExample(
              title: 'Past Continuous Passive',
              correct: 'The bridge was being built.',
              explanation: 'Past continuous passive.',
            ),
            models.GrammarExample(
              title: 'Passive with Two Objects',
              correct: 'A gift was given to me.',
              explanation: 'Passive with two objects.',
            ),
            models.GrammarExample(
              title: 'Modal Passive',
              correct: 'The rules must be followed.',
              explanation: 'Modal passive.',
            ),
          ],
      practiceSentences: () => [],
      practiceQuestions:
          () => [
            GrammarQuestion(
              question: 'Fill in: "The room ___ cleaned."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'is',
              explanation: 'Present passive uses "is" + past participle.',
            ),
            GrammarQuestion(
              question: 'Choose: "The song ___ by the band."',
              type: 'multiple_choice',
              options: ['is sung', 'sings', 'sung', 'was singing'],
              correctAnswer: 'is sung',
              explanation: 'Present passive: "is" + past participle "sung".',
            ),
            GrammarQuestion(
              question: 'True or False: "She was helped" is passive.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'True',
              explanation: 'The subject "She" receives the action "helped".',
            ),
            GrammarQuestion(
              question: 'Reorder: "written / was / the / book"',
              type: 'reorder',
              options: ['written', 'was', 'the', 'book'],
              correctAnswer: 'the book was written',
              explanation: 'Past passive: Subject + was + past participle.',
            ),
            GrammarQuestion(
              question: 'Which is passive? "He paints" or "It is painted"?',
              type: 'multiple_choice',
              options: ['He paints', 'It is painted'],
              correctAnswer: 'It is painted',
              explanation:
                  'Passive voice has the subject receiving the action.',
            ),
            GrammarQuestion(
              question: 'Fill in: "The car ___ tomorrow."',
              type: 'fill_blank',
              options: [],
              correctAnswer: 'will be repaired',
              explanation: 'Future passive: "will be" + past participle.',
            ),
            GrammarQuestion(
              question: 'Choose: "The homework ___ done."',
              type: 'multiple_choice',
              options: ['is', 'does', 'did', 'was doing'],
              correctAnswer: 'is',
              explanation: 'Present passive: "is" + past participle "done".',
            ),
            GrammarQuestion(
              question: 'True or False: "They built it" is passive.',
              type: 'true_false',
              options: ['True', 'False'],
              correctAnswer: 'False',
              explanation:
                  'Active voice has the subject "They" performing the action.',
            ),
          ],
    );
  }
}

class GrammarTopic {
  final String id;
  final String title;
  final IconData icon;
  final String shortDescription;
  final String introduction;
  final String detailedExplanation;
  final List<models.GrammarRule> Function() rules;
  final List<models.GrammarExample> Function() examples;
  final List<models.GrammarExample> Function() practiceSentences;
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
                    (rule) => models.GrammarRule.fromJson(
                      rule as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
      examples:
          () =>
              (json['examples'] as List)
                  .map(
                    (example) => models.GrammarExample.fromJson(
                      example as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
      practiceSentences:
          () =>
              (json['practiceSentences'] as List? ?? [])
                  .map(
                    (sentence) => models.GrammarExample.fromJson(
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
  final String type;
  final List<String> options;
  final dynamic correctAnswer;
  final String? explanation;
  final String? userAnswer;
  final bool isCorrect;
  final bool isAttempted;

  GrammarQuestion({
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    this.explanation,
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
      explanation: explanation,
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
      explanation: json['explanation'] as String?,
      userAnswer: json['userAnswer'] as String?,
      isCorrect: json['isCorrect'] ?? false,
      isAttempted: json['isAttempted'] ?? false,
    );
  }

  GrammarQuestion checkAnswer(dynamic answer) {
    if (answer == null) {
      return copyWith(userAnswer: null, isCorrect: false, isAttempted: true);
    }

    bool isAnswerCorrect;
    if (answer is List && correctAnswer is List) {
      isAnswerCorrect = _areListsEqual(
        answer.map((e) => e.toString().trim().toLowerCase()).toList(),
        (correctAnswer as List)
            .map((e) => e.toString().trim().toLowerCase())
            .toList(),
      );
    } else {
      isAnswerCorrect =
          answer.toString().trim().toLowerCase() ==
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

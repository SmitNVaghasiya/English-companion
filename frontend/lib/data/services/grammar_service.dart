import 'package:flutter/material.dart';
import 'package:english_companion/data/models/grammar_topic.dart';

class GrammarService {
  // This is a mock service that returns predefined grammar topics
  // In a real app, this would fetch data from an API
  Future<GrammarTopic> getGrammarTopic(String topicId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return the appropriate topic based on the ID
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
        throw Exception('Topic not found');
    }
  }

  GrammarTopic _getPartsOfSpeechTopic() {
    return GrammarTopic(
      id: 'parts_of_speech',
      title: 'Parts of Speech',
      icon: Icons.category_outlined,
      shortDescription: 'Nouns, verbs, adjectives, and more',
      introduction:
          'Parts of speech are categories of words that have similar grammatical properties. Understanding parts of speech is essential for constructing proper sentences and communicating effectively in English.',
      rules: [
        GrammarRule(
          title: 'Nouns',
          description:
              'Nouns are words that name people, places, things, or ideas. They can be common (dog, city) or proper (John, London), and can be singular or plural.',
        ),
        GrammarRule(
          title: 'Verbs',
          description:
              'Verbs express actions (run, eat), states (be, exist), or occurrences (happen, become). They are essential to forming complete sentences.',
        ),
        GrammarRule(
          title: 'Adjectives',
          description:
              'Adjectives modify or describe nouns and pronouns. They provide information about qualities, quantities, and which one.',
        ),
        GrammarRule(
          title: 'Adverbs',
          description:
              'Adverbs modify verbs, adjectives, or other adverbs. They often answer questions like how, when, where, or to what extent.',
        ),
        GrammarRule(
          title: 'Pronouns',
          description:
              'Pronouns replace nouns to avoid repetition. Examples include personal pronouns (I, you, he), possessive pronouns (mine, yours), and relative pronouns (who, which).',
        ),
        GrammarRule(
          title: 'Prepositions',
          description:
              'Prepositions show relationships between other words in a sentence, typically involving direction, place, or time (in, on, at, by, with).',
        ),
        GrammarRule(
          title: 'Conjunctions',
          description:
              'Conjunctions connect words, phrases, or clauses (and, but, or, because, although).',
        ),
        GrammarRule(
          title: 'Interjections',
          description:
              'Interjections express emotion or surprise and are usually followed by an exclamation mark (Oh!, Wow!, Ouch!).',
        ),
      ],
      examples: [
        GrammarExample(
          title: 'Nouns',
          correct: 'The dog chased the ball in the park.',
          incorrect: '',
          explanation:
              'In this sentence, "dog," "ball," and "park" are all nouns.',
        ),
        GrammarExample(
          title: 'Verbs',
          correct: 'She runs every morning and enjoys the fresh air.',
          incorrect: '',
          explanation: 'Here, "runs" and "enjoys" are verbs that show action.',
        ),
        GrammarExample(
          title: 'Adjectives',
          correct: 'The tall man bought a new red car.',
          incorrect: '',
          explanation:
              '"Tall" describes the man, while "new" and "red" describe the car.',
        ),
        GrammarExample(
          title: 'Multiple Parts of Speech',
          correct: 'The happy children quickly ran to their friendly teacher.',
          incorrect: '',
          explanation:
              '"Happy" is an adjective describing "children" (noun), "quickly" is an adverb describing "ran" (verb), "their" is a possessive pronoun, and "friendly" is an adjective describing "teacher" (noun).',
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
          'Verb tenses indicate when an action takes place: in the past, present, or future. English has 12 major tenses, each with its own specific use and formation. Understanding tenses is crucial for expressing time relationships accurately.',
      rules: [
        GrammarRule(
          title: 'Simple Present',
          description:
              'Used for habits, general truths, and scheduled events. Form: base verb (+ s/es for third person singular).',
        ),
        GrammarRule(
          title: 'Present Continuous',
          description:
              'Used for actions happening now or temporary situations. Form: am/is/are + verb-ing.',
        ),
        GrammarRule(
          title: 'Present Perfect',
          description:
              'Used for past actions with present relevance or experiences. Form: have/has + past participle.',
        ),
        GrammarRule(
          title: 'Present Perfect Continuous',
          description:
              'Used for ongoing actions that started in the past and continue to the present. Form: have/has been + verb-ing.',
        ),
        GrammarRule(
          title: 'Simple Past',
          description:
              'Used for completed actions in the past. Form: past tense verb (usually -ed for regular verbs).',
        ),
        GrammarRule(
          title: 'Past Continuous',
          description:
              'Used for actions in progress at a specific time in the past. Form: was/were + verb-ing.',
        ),
        GrammarRule(
          title: 'Past Perfect',
          description:
              'Used for actions completed before another past action. Form: had + past participle.',
        ),
        GrammarRule(
          title: 'Simple Future',
          description:
              'Used for predictions or decisions made at the moment of speaking. Form: will + base verb.',
        ),
      ],
      examples: [
        GrammarExample(
          title: 'Simple Present',
          correct: 'She works at a hospital.',
          incorrect: 'She working at a hospital.',
          explanation:
              'Simple present uses the base verb with "s" for third person singular.',
        ),
        GrammarExample(
          title: 'Present Continuous',
          correct: 'They are studying for their exam.',
          incorrect: 'They study for their exam now.',
          explanation:
              'Present continuous uses am/is/are + verb-ing to show an action in progress.',
        ),
        GrammarExample(
          title: 'Simple Past vs. Present Perfect',
          correct:
              'I visited Paris last year. / I have visited Paris three times.',
          incorrect: 'I have visited Paris last year.',
          explanation:
              'Simple past is used for a specific time in the past. Present perfect is used for experiences without a specific time.',
        ),
        GrammarExample(
          title: 'Future Tense',
          correct: 'The train will arrive at 10 PM.',
          incorrect: 'The train arrives at 10 PM tomorrow.',
          explanation:
              'For future events, we typically use "will" + base verb, not simple present (unless it\'s a scheduled event).',
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
          'English sentences follow specific structural patterns. A basic sentence contains a subject and a predicate (verb). Understanding sentence structure helps you communicate clearly and avoid common grammatical errors.',
      rules: [
        GrammarRule(
          title: 'Basic Sentence Structure',
          description:
              'A complete sentence must have a subject (who or what the sentence is about) and a predicate (what the subject is or does).',
        ),
        GrammarRule(
          title: 'Word Order',
          description:
              'English typically follows Subject-Verb-Object (SVO) word order. This pattern is essential for clarity.',
        ),
        GrammarRule(
          title: 'Simple Sentences',
          description:
              'A simple sentence contains one independent clause with a subject and a verb.',
        ),
        GrammarRule(
          title: 'Compound Sentences',
          description:
              'A compound sentence contains two or more independent clauses joined by coordinating conjunctions (and, but, or, so, yet) or semicolons.',
        ),
        GrammarRule(
          title: 'Complex Sentences',
          description:
              'A complex sentence has one independent clause and at least one dependent clause. Dependent clauses start with subordinating conjunctions like because, although, when, if.',
        ),
        GrammarRule(
          title: 'Compound-Complex Sentences',
          description:
              'These sentences have at least two independent clauses and at least one dependent clause.',
        ),
      ],
      examples: [
        GrammarExample(
          title: 'Simple Sentence',
          correct: 'The dog barked.',
          incorrect: '',
          explanation: 'Subject (The dog) + Verb (barked)',
        ),
        GrammarExample(
          title: 'Compound Sentence',
          correct: 'The sun was shining, but the air was cold.',
          incorrect: 'The sun was shining but the air was cold',
          explanation:
              'Two independent clauses joined by a coordinating conjunction (but) with a comma before the conjunction.',
        ),
        GrammarExample(
          title: 'Complex Sentence',
          correct: 'Although it was raining, we went for a walk.',
          incorrect: 'Although it was raining we went for a walk.',
          explanation:
              'A dependent clause (Although it was raining) followed by an independent clause (we went for a walk), with a comma separating them.',
        ),
        GrammarExample(
          title: 'Word Order',
          correct: 'She reads books every day.',
          incorrect: 'She every day reads books.',
          explanation:
              'Follows the Subject-Verb-Object pattern with the time expression at the end.',
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
          'Articles are small but important words that precede nouns. English has two types of articles: definite (the) and indefinite (a, an). Using articles correctly can be challenging, especially for speakers of languages that don\'t have articles.',
      rules: [
        GrammarRule(
          title: 'Definite Article (the)',
          description:
              'Used when referring to something specific that both the speaker and listener know about. Also used with unique items, superlatives, and some geographic features.',
        ),
        GrammarRule(
          title: 'Indefinite Articles (a, an)',
          description:
              '"A" is used before consonant sounds, and "an" is used before vowel sounds. They refer to non-specific items or when mentioning something for the first time.',
        ),
        GrammarRule(
          title: 'Zero Article',
          description:
              'Sometimes no article is needed, especially with plural or uncountable nouns when speaking generally, with most names of countries, cities, and streets, and with some institutions and meals.',
        ),
        GrammarRule(
          title: 'Articles with Countable/Uncountable Nouns',
          description:
              'Countable nouns can use all articles. Uncountable nouns generally don\'t use "a/an" but can use "the" or no article.',
        ),
      ],
      examples: [
        GrammarExample(
          title: 'Definite Article',
          correct: 'The book on the table is mine.',
          incorrect: 'Book on table is mine.',
          explanation:
              '"The" is used because both speaker and listener know which specific book is being referred to.',
        ),
        GrammarExample(
          title: 'Indefinite Articles',
          correct: 'I need a pen. / She bought an apple.',
          incorrect: 'I need an pen. / She bought a apple.',
          explanation:
              '"A" is used before "pen" (consonant sound), and "an" is used before "apple" (vowel sound).',
        ),
        GrammarExample(
          title: 'Zero Article',
          correct: 'Dogs are loyal animals. / Life is beautiful.',
          incorrect: 'The dogs are loyal animals. / The life is beautiful.',
          explanation:
              'No article is used when making general statements about plural countable nouns or uncountable nouns.',
        ),
        GrammarExample(
          title: 'Mixed Usage',
          correct:
              'I had dinner at a restaurant. The restaurant was very crowded.',
          incorrect: 'I had dinner at restaurant. Restaurant was very crowded.',
          explanation:
              'First mention uses "a" (indefinite), and subsequent mentions use "the" (now specific).',
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
          'Prepositions are words that show the relationship between a noun or pronoun and other words in a sentence. They indicate relationships of place, time, direction, or other abstract relationships. Using the correct preposition can be challenging because they often don\'t translate directly between languages.',
      rules: [
        GrammarRule(
          title: 'Prepositions of Place',
          description:
              'These show where something is located. Common examples include: in (inside a space), on (touching a surface), at (a specific point), under, over, between, among, beside, behind, in front of.',
        ),
        GrammarRule(
          title: 'Prepositions of Time',
          description:
              'These indicate when something happens. Common examples include: at (specific time), on (specific day/date), in (longer periods, months, years, seasons), for (duration), since (starting point), during, until/till, by.',
        ),
        GrammarRule(
          title: 'Prepositions of Movement',
          description:
              'These show direction or how something moves. Common examples include: to, toward(s), from, into, out of, across, through, along, around, over, up, down.',
        ),
        GrammarRule(
          title: 'Prepositions with Verbs (Phrasal Verbs)',
          description:
              'Some verbs combine with prepositions to create new meanings. For example: look for, think about, depend on, apply for, believe in.',
        ),
        GrammarRule(
          title: 'Prepositions with Adjectives',
          description:
              'Certain adjectives are typically followed by specific prepositions. For example: afraid of, interested in, good at, famous for, similar to.',
        ),
      ],
      examples: [
        GrammarExample(
          title: 'Prepositions of Place',
          correct:
              'The book is on the table. / They live in London. / We\'ll meet at the station.',
          incorrect:
              'The book is at the table. / They live at London. / We\'ll meet in the station.',
          explanation:
              'Use "on" for surfaces, "in" for enclosed spaces or larger areas, and "at" for specific points or locations.',
        ),
        GrammarExample(
          title: 'Prepositions of Time',
          correct: 'The meeting is at 3 PM on Monday in May.',
          incorrect: 'The meeting is in 3 PM at Monday on May.',
          explanation:
              'Use "at" for specific times, "on" for days/dates, and "in" for months/years/seasons.',
        ),
        GrammarExample(
          title: 'Prepositions of Movement',
          correct:
              'She walked to the store, went through the door, and looked around the shop.',
          incorrect:
              'She walked at the store, went across the door, and looked about the shop.',
          explanation:
              '"To" indicates direction toward a destination, "through" means entering and exiting an enclosed space, and "around" means in various parts of an area.',
        ),
        GrammarExample(
          title: 'Phrasal Verbs',
          correct: 'I\'m looking for my keys. / She depends on her friends.',
          incorrect:
              'I\'m looking after my keys. / She depends of her friends.',
          explanation:
              'Phrasal verbs require specific prepositions that must be memorized.',
        ),
      ],
    );
  }

  GrammarTopic _getModalsTopic() {
    return GrammarTopic(
      id: 'modals',
      title: 'Modal Verbs',
      icon: Icons.help_outline,
      shortDescription: 'Can, could, should, would, etc.',
      introduction:
          'Modal verbs (also called modal auxiliaries) are special verbs that express necessity, possibility, permission, or ability. They modify the meaning of the main verb and help convey the speaker\'s attitude toward the action or state described by the main verb.',
      rules: [
        GrammarRule(
          title: 'Basic Characteristics of Modals',
          description:
              'Modal verbs don\'t change form for different subjects, don\'t use auxiliaries for questions or negatives, and are always followed by the base form of the verb (without "to").',
        ),
        GrammarRule(
          title: 'Can/Could',
          description:
              '"Can" expresses ability, possibility, or permission in the present. "Could" is the past form of "can" but also expresses possibility or polite requests.',
        ),
        GrammarRule(
          title: 'May/Might',
          description:
              '"May" expresses possibility or permission (more formal than "can"). "Might" expresses a smaller possibility than "may".',
        ),
        GrammarRule(
          title: 'Must/Have to',
          description:
              '"Must" expresses obligation, necessity, or strong belief. "Have to" is similar but is often used for external obligation.',
        ),
        GrammarRule(
          title: 'Should/Ought to',
          description:
              'Both express advice, recommendation, or expectation, with "ought to" being slightly stronger or more formal.',
        ),
        GrammarRule(
          title: 'Will/Would',
          description:
              '"Will" expresses future actions, promises, or willingness. "Would" is the past form of "will" but also expresses hypothetical situations or polite requests.',
        ),
      ],
      examples: [
        GrammarExample(
          title: 'Can/Could',
          correct: 'I can swim. / Could you help me, please?',
          incorrect: 'I can to swim. / Could you to help me, please?',
          explanation:
              'Modals are always followed by the base form of the verb (without "to").',
        ),
        GrammarExample(
          title: 'May/Might',
          correct: 'You may leave now. / It might rain later.',
          incorrect: 'You may to leave now. / It might rains later.',
          explanation:
              '"May" can express permission, and "might" expresses possibility. Both are followed by the base form of the verb.',
        ),
        GrammarExample(
          title: 'Must/Have to',
          correct: 'You must finish this today. / I have to go to the dentist.',
          incorrect:
              'You must to finish this today. / I must go to the dentist yesterday.',
          explanation:
              '"Must" expresses obligation and is followed by the base form. "Have to" can be used in all tenses, unlike "must".',
        ),
        GrammarExample(
          title: 'Should/Would',
          correct:
              'You should exercise regularly. / I would like a coffee, please.',
          incorrect:
              'You should to exercise regularly. / I would to like a coffee, please.',
          explanation:
              '"Should" expresses advice and "would" can express polite requests. Both are followed by the base form of the verb.',
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
          'Conditional sentences express that the action in the main clause can only take place if a certain condition (expressed in the if-clause) is fulfilled. English has several types of conditionals, each used for different situations and levels of probability.',
      rules: [
        GrammarRule(
          title: 'Zero Conditional',
          description:
              'Used for general truths and scientific facts. Structure: If + present simple, present simple.',
        ),
        GrammarRule(
          title: 'First Conditional',
          description:
              'Used for real and possible situations in the future. Structure: If + present simple, will + infinitive.',
        ),
        GrammarRule(
          title: 'Second Conditional',
          description:
              'Used for unreal or improbable situations in the present or future. Structure: If + past simple, would + infinitive.',
        ),
        GrammarRule(
          title: 'Third Conditional',
          description:
              'Used for impossible situations in the past (hypothetical past). Structure: If + past perfect, would have + past participle.',
        ),
        GrammarRule(
          title: 'Mixed Conditionals',
          description:
              'Combine different types of conditionals when the time reference in the if-clause is different from the time reference in the main clause.',
        ),
        GrammarRule(
          title: 'Unless, As Long As, Provided That',
          description:
              'These can be used instead of "if" in conditional sentences, with slightly different meanings.',
        ),
      ],
      examples: [
        GrammarExample(
          title: 'Zero Conditional',
          correct: 'If you heat water to 100°C, it boils.',
          incorrect: 'If you heat water to 100°C, it will boil.',
          explanation:
              'Zero conditional uses present simple in both clauses to express general truths.',
        ),
        GrammarExample(
          title: 'First Conditional',
          correct: 'If it rains tomorrow, we will cancel the picnic.',
          incorrect: 'If it will rain tomorrow, we will cancel the picnic.',
          explanation:
              'First conditional uses present simple in the if-clause (not future) and will + infinitive in the main clause.',
        ),
        GrammarExample(
          title: 'Second Conditional',
          correct: 'If I won the lottery, I would buy a house.',
          incorrect: 'If I would win the lottery, I would buy a house.',
          explanation:
              'Second conditional uses past simple in the if-clause (not would) and would + infinitive in the main clause.',
        ),
        GrammarExample(
          title: 'Third Conditional',
          correct: 'If you had told me earlier, I would have helped you.',
          incorrect:
              'If you would have told me earlier, I would have helped you.',
          explanation:
              'Third conditional uses past perfect in the if-clause (not would have) and would have + past participle in the main clause.',
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
          'The passive voice is used when the focus is on the action rather than who or what is performing the action. In passive sentences, the subject receives the action expressed by the verb, rather than performing it. The passive voice is particularly common in formal, scientific, and academic writing.',
      rules: [
        GrammarRule(
          title: 'Basic Passive Structure',
          description:
              'Form: be (in the appropriate tense) + past participle. The object of the active sentence becomes the subject of the passive sentence.',
        ),
        GrammarRule(
          title: 'Agent (By Phrase)',
          description:
              'The agent (doer of the action) can be mentioned using "by" but is often omitted if it\'s unknown or unimportant.',
        ),
        GrammarRule(
          title: 'Tenses in Passive Voice',
          description:
              'All tenses can be used in the passive voice by changing the form of "be" to the appropriate tense.',
        ),
        GrammarRule(
          title: 'When to Use Passive Voice',
          description:
              'Use passive when: the doer is unknown, unimportant, or obvious; you want to emphasize the action or the receiver; in formal or scientific writing; or to avoid mentioning who is responsible.',
        ),
        GrammarRule(
          title: 'Verbs with Two Objects',
          description:
              'When an active sentence has two objects (direct and indirect), either can become the subject of the passive sentence.',
        ),
      ],
      examples: [
        GrammarExample(
          title: 'Basic Transformation',
          correct:
              'Active: The chef prepared the meal. / Passive: The meal was prepared by the chef.',
          incorrect: 'The meal was prepare by the chef.',
          explanation:
              'In passive voice, the object of the active sentence becomes the subject, and we use "be" + past participle.',
        ),
        GrammarExample(
          title: 'Different Tenses',
          correct:
              'Present: The house is cleaned weekly. / Past: The house was cleaned yesterday. / Future: The house will be cleaned tomorrow.',
          incorrect:
              'The house cleaned weekly. / The house is clean yesterday.',
          explanation:
              'The form of "be" changes according to the tense, but the past participle remains the same.',
        ),
        GrammarExample(
          title: 'Omitting the Agent',
          correct: 'My car was stolen last night.',
          incorrect: 'My car was stolen by someone last night.',
          explanation:
              'The agent is omitted because it\'s unknown who stole the car.',
        ),
        GrammarExample(
          title: 'Verbs with Two Objects',
          correct:
              'Active: She gave me a book. / Passive: I was given a book (by her). OR A book was given to me (by her).',
          incorrect: 'A book was given me by her.',
          explanation:
              'Either the indirect object ("me") or the direct object ("a book") can become the subject of the passive sentence.',
        ),
      ],
    );
  }
}

GrammarTopic _getPartsOfSpeechTopic() {
  return GrammarTopic(
    id: 'parts_of_speech',
    title: 'Parts of Speech',
    icon: Icons.category_outlined,
    shortDescription: 'Nouns, verbs, adjectives, and more',
    introduction:
        'Parts of speech are categories of words that have similar grammatical properties. Understanding parts of speech is essential for constructing proper sentences and communicating effectively in English.',
    rules: [
      GrammarRule(
        title: 'Nouns',
        description:
            'Nouns are words that name people, places, things, or ideas. They can be common (dog, city) or proper (John, London), and can be singular or plural.',
      ),
      GrammarRule(
        title: 'Verbs',
        description:
            'Verbs express actions (run, eat), states (be, exist), or occurrences (happen, become). They are essential to forming complete sentences.',
      ),
      GrammarRule(
        title: 'Adjectives',
        description:
            'Adjectives modify or describe nouns and pronouns. They provide information about qualities, quantities, and which one.',
      ),
      GrammarRule(
        title: 'Adverbs',
        description:
            'Adverbs modify verbs, adjectives, or other adverbs. They often answer questions like how, when, where, or to what extent.',
      ),
      GrammarRule(
        title: 'Pronouns',
        description:
            'Pronouns replace nouns to avoid repetition. Examples include personal pronouns (I, you, he), possessive pronouns (mine, yours), and relative pronouns (who, which).',
      ),
      GrammarRule(
        title: 'Prepositions',
        description:
            'Prepositions show relationships between other words in a sentence, typically involving direction, place, or time (in, on, at, by, with).',
      ),
      GrammarRule(
        title: 'Conjunctions',
        description:
            'Conjunctions connect words, phrases, or clauses (and, but, or, because, although).',
      ),
      GrammarRule(
        title: 'Interjections',
        description:
            'Interjections express emotion or surprise and are usually followed by an exclamation mark (Oh!, Wow!, Ouch!).',
      ),
    ],
    examples: [
      GrammarExample(
        title: 'Nouns',
        correct: 'The dog chased the ball in the park.',
        incorrect: '',
        explanation:
            'In this sentence, "dog," "ball," and "park" are all nouns.',
      ),
      GrammarExample(
        title: 'Verbs',
        correct: 'She runs every morning and enjoys the fresh air.',
        incorrect: '',
        explanation: 'Here, "runs" and "enjoys" are verbs that show action.',
      ),
      GrammarExample(
        title: 'Adjectives',
        correct: 'The tall man bought a new red car.',
        incorrect: '',
        explanation:
            '"Tall" describes the man, while "new" and "red" describe the car.',
      ),
      GrammarExample(
        title: 'Multiple Parts of Speech',
        correct: 'The happy children quickly ran to their friendly teacher.',
        incorrect: '',
        explanation:
            '"Happy" is an adjective describing "children" (noun), "quickly" is an adverb describing "ran" (verb), "their" is a possessive pronoun, and "friendly" is an adjective describing "teacher" (noun).',
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
        'Verb tenses indicate when an action takes place: in the past, present, or future. English has 12 major tenses, each with its own specific use and formation. Understanding tenses is crucial for expressing time relationships accurately.',
    rules: [
      GrammarRule(
        title: 'Simple Present',
        description:
            'Used for habits, general truths, and scheduled events. Form: base verb (+ s/es for third person singular).',
      ),
      GrammarRule(
        title: 'Present Continuous',
        description:
            'Used for actions happening now or temporary situations. Form: am/is/are + verb-ing.',
      ),
      GrammarRule(
        title: 'Present Perfect',
        description:
            'Used for past actions with present relevance or experiences. Form: have/has + past participle.',
      ),
      GrammarRule(
        title: 'Present Perfect Continuous',
        description:
            'Used for ongoing actions that started in the past and continue to the present. Form: have/has been + verb-ing.',
      ),
      GrammarRule(
        title: 'Simple Past',
        description:
            'Used for completed actions in the past. Form: past tense verb (usually -ed for regular verbs).',
      ),
      GrammarRule(
        title: 'Past Continuous',
        description:
            'Used for actions in progress at a specific time in the past. Form: was/were + verb-ing.',
      ),
      GrammarRule(
        title: 'Past Perfect',
        description:
            'Used for actions completed before another past action. Form: had + past participle.',
      ),
      GrammarRule(
        title: 'Simple Future',
        description:
            'Used for predictions or decisions made at the moment of speaking. Form: will + base verb.',
      ),
    ],
    examples: [
      GrammarExample(
        title: 'Simple Present',
        correct: 'She works at a hospital.',
        incorrect: 'She working at a hospital.',
        explanation:
            'Simple present uses the base verb with "s" for third person singular.',
      ),
      GrammarExample(
        title: 'Present Continuous',
        correct: 'They are studying for their exam.',
        incorrect: 'They study for their exam now.',
        explanation:
            'Present continuous uses am/is/are + verb-ing to show an action in progress.',
      ),
      GrammarExample(
        title: 'Simple Past vs. Present Perfect',
        correct:
            'I visited Paris last year. / I have visited Paris three times.',
        incorrect: 'I have visited Paris last year.',
        explanation:
            'Simple past is used for a specific time in the past. Present perfect is used for experiences without a specific time.',
      ),
      GrammarExample(
        title: 'Future Tense',
        correct: 'The train will arrive at 10 PM.',
        incorrect: 'The train arrives at 10 PM tomorrow.',
        explanation:
            'For future events, we typically use "will" + base verb, not simple present (unless it\'s a scheduled event).',
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
        'English sentences follow specific structural patterns. A basic sentence contains a subject and a predicate (verb). Understanding sentence structure helps you communicate clearly and avoid common grammatical errors.',
    rules: [
      GrammarRule(
        title: 'Basic Sentence Structure',
        description:
            'A complete sentence must have a subject (who or what the sentence is about) and a predicate (what the subject is or does).',
      ),
      GrammarRule(
        title: 'Word Order',
        description:
            'English typically follows Subject-Verb-Object (SVO) word order. This pattern is essential for clarity.',
      ),
      GrammarRule(
        title: 'Simple Sentences',
        description:
            'A simple sentence contains one independent clause with a subject and a verb.',
      ),
      GrammarRule(
        title: 'Compound Sentences',
        description:
            'A compound sentence contains two or more independent clauses joined by coordinating conjunctions (and, but, or, so, yet) or semicolons.',
      ),
      GrammarRule(
        title: 'Complex Sentences',
        description:
            'A complex sentence has one independent clause and at least one dependent clause. Dependent clauses start with subordinating conjunctions like because, although, when, if.',
      ),
      GrammarRule(
        title: 'Compound-Complex Sentences',
        description:
            'These sentences have at least two independent clauses and at least one dependent clause.',
      ),
    ],
    examples: [
      GrammarExample(
        title: 'Simple Sentence',
        correct: 'The dog barked.',
        incorrect: '',
        explanation: 'Subject (The dog) + Verb (barked)',
      ),
      GrammarExample(
        title: 'Compound Sentence',
        correct: 'The sun was shining, but the air was cold.',
        incorrect: 'The sun was shining but the air was cold',
        explanation:
            'Two independent clauses joined by a coordinating conjunction (but) with a comma before the conjunction.',
      ),
      GrammarExample(
        title: 'Complex Sentence',
        correct: 'Although it was raining, we went for a walk.',
        incorrect: 'Although it was raining we went for a walk.',
        explanation:
            'A dependent clause (Although it was raining) followed by an independent clause (we went for a walk), with a comma separating them.',
      ),
      GrammarExample(
        title: 'Word Order',
        correct: 'She reads books every day.',
        incorrect: 'She every day reads books.',
        explanation:
            'Follows the Subject-Verb-Object pattern with the time expression at the end.',
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
        'Articles are small but important words that precede nouns. English has two types of articles: definite (the) and indefinite (a, an). Using articles correctly can be challenging, especially for speakers of languages that don\'t have articles.',
    rules: [
      GrammarRule(
        title: 'Definite Article (the)',
        description:
            'Used when referring to something specific that both the speaker and listener know about. Also used with unique items, superlatives, and some geographic features.',
      ),
      GrammarRule(
        title: 'Indefinite Articles (a, an)',
        description:
            '"A" is used before consonant sounds, and "an" is used before vowel sounds. They refer to non-specific items or when mentioning something for the first time.',
      ),
      GrammarRule(
        title: 'Zero Article',
        description:
            'Sometimes no article is needed, especially with plural or uncountable nouns when speaking generally, with most names of countries, cities, and streets, and with some institutions and meals.',
      ),
      GrammarRule(
        title: 'Articles with Countable/Uncountable Nouns',
        description:
            'Countable nouns can use all articles. Uncountable nouns generally don\'t use "a/an" but can use "the" or no article.',
      ),
    ],
    examples: [
      GrammarExample(
        title: 'Definite Article',
        correct: 'The book on the table is mine.',
        incorrect: 'Book on table is mine.',
        explanation:
            '"The" is used because both speaker and listener know which specific book is being referred to.',
      ),
      GrammarExample(
        title: 'Indefinite Articles',
        correct: 'I need a pen. / She bought an apple.',
        incorrect: 'I need an pen. / She bought a apple.',
        explanation:
            '"A" is used before "pen" (consonant sound), and "an" is used before "apple" (vowel sound).',
      ),
      GrammarExample(
        title: 'Zero Article',
        correct: 'Dogs are loyal animals. / Life is beautiful.',
        incorrect: 'The dogs are loyal animals. / The life is beautiful.',
        explanation:
            'No article is used when making general statements about plural countable nouns or uncountable nouns.',
      ),
      GrammarExample(
        title: 'Mixed Usage',
        correct:
            'I had dinner at a restaurant. The restaurant was very crowded.',
        incorrect: 'I had dinner at restaurant. Restaurant was very crowded.',
        explanation:
            'First mention uses "a" (indefinite), and subsequent mentions use "the" (now specific).',
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
        'Prepositions are words that show the relationship between a noun or pronoun and other words in a sentence. They indicate relationships of place, time, direction, or other abstract relationships. Using the correct preposition can be challenging because they often don\'t translate directly between languages.',
    rules: [
      GrammarRule(
        title: 'Prepositions of Place',
        description:
            'These show where something is located. Common examples include: in (inside a space), on (touching a surface), at (a specific point), under, over, between, among, beside, behind, in front of.',
      ),
      GrammarRule(
        title: 'Prepositions of Time',
        description:
            'These indicate when something happens. Common examples include: at (specific time), on (specific day/date), in (longer periods, months, years, seasons), for (duration), since (starting point), during, until/till, by.',
      ),
      GrammarRule(
        title: 'Prepositions of Movement',
        description:
            'These show direction or how something moves. Common examples include: to, toward(s), from, into, out of, across, through, along, around, over, up, down.',
      ),
      GrammarRule(
        title: 'Prepositions with Verbs (Phrasal Verbs)',
        description:
            'Some verbs combine with prepositions to create new meanings. For example: look for, think about, depend on, apply for, believe in.',
      ),
      GrammarRule(
        title: 'Prepositions with Adjectives',
        description:
            'Certain adjectives are typically followed by specific prepositions. For example: afraid of, interested in, good at, famous for, similar to.',
      ),
    ],
    examples: [
      GrammarExample(
        title: 'Prepositions of Place',
        correct:
            'The book is on the table. / They live in London. / We\'ll meet at the station.',
        incorrect:
            'The book is at the table. / They live at London. / We\'ll meet in the station.',
        explanation:
            'Use "on" for surfaces, "in" for enclosed spaces or larger areas, and "at" for specific points or locations.',
      ),
      GrammarExample(
        title: 'Prepositions of Time',
        correct: 'The meeting is at 3 PM on Monday in May.',
        incorrect: 'The meeting is in 3 PM at Monday on May.',
        explanation:
            'Use "at" for specific times, "on" for days/dates, and "in" for months/years/seasons.',
      ),
      GrammarExample(
        title: 'Prepositions of Movement',
        correct:
            'She walked to the store, went through the door, and looked around the shop.',
        incorrect:
            'She walked at the store, went across the door, and looked about the shop.',
        explanation:
            '"To" indicates direction toward a destination, "through" means entering and exiting an enclosed space, and "around" means in various parts of an area.',
      ),
      GrammarExample(
        title: 'Phrasal Verbs',
        correct: 'I\'m looking for my keys. / She depends on her friends.',
        incorrect: 'I\'m looking after my keys. / She depends of her friends.',
        explanation:
            'Phrasal verbs require specific prepositions that must be memorized.',
      ),
    ],
  );
}

GrammarTopic _getModalsTopic() {
  return GrammarTopic(
    id: 'modals',
    title: 'Modal Verbs',
    icon: Icons.help_outline,
    shortDescription: 'Can, could, should, would, etc.',
    introduction:
        'Modal verbs (also called modal auxiliaries) are special verbs that express necessity, possibility, permission, or ability. They modify the meaning of the main verb and help convey the speaker\'s attitude toward the action or state described by the main verb.',
    rules: [
      GrammarRule(
        title: 'Basic Characteristics of Modals',
        description:
            'Modal verbs don\'t change form for different subjects, don\'t use auxiliaries for questions or negatives, and are always followed by the base form of the verb (without "to").',
      ),
      GrammarRule(
        title: 'Can/Could',
        description:
            '"Can" expresses ability, possibility, or permission in the present. "Could" is the past form of "can" but also expresses possibility or polite requests.',
      ),
      GrammarRule(
        title: 'May/Might',
        description:
            '"May" expresses possibility or permission (more formal than "can"). "Might" expresses a smaller possibility than "may".',
      ),
      GrammarRule(
        title: 'Must/Have to',
        description:
            '"Must" expresses obligation, necessity, or strong belief. "Have to" is similar but is often used for external obligation.',
      ),
      GrammarRule(
        title: 'Should/Ought to',
        description:
            'Both express advice, recommendation, or expectation, with "ought to" being slightly stronger or more formal.',
      ),
      GrammarRule(
        title: 'Will/Would',
        description:
            '"Will" expresses future actions, promises, or willingness. "Would" is the past form of "will" but also expresses hypothetical situations or polite requests.',
      ),
    ],
    examples: [
      GrammarExample(
        title: 'Can/Could',
        correct: 'I can swim. / Could you help me, please?',
        incorrect: 'I can to swim. / Could you to help me, please?',
        explanation:
            'Modals are always followed by the base form of the verb (without "to").',
      ),
      GrammarExample(
        title: 'May/Might',
        correct: 'You may leave now. / It might rain later.',
        incorrect: 'You may to leave now. / It might rains later.',
        explanation:
            '"May" can express permission, and "might" expresses possibility. Both are followed by the base form of the verb.',
      ),
      GrammarExample(
        title: 'Must/Have to',
        correct: 'You must finish this today. / I have to go to the dentist.',
        incorrect:
            'You must to finish this today. / I must go to the dentist yesterday.',
        explanation:
            '"Must" expresses obligation and is followed by the base form. "Have to" can be used in all tenses, unlike "must".',
      ),
      GrammarExample(
        title: 'Should/Would',
        correct:
            'You should exercise regularly. / I would like a coffee, please.',
        incorrect:
            'You should to exercise regularly. / I would to like a coffee, please.',
        explanation:
            '"Should" expresses advice and "would" can express polite requests. Both are followed by the base form of the verb.',
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
        'Conditional sentences express that the action in the main clause can only take place if a certain condition (expressed in the if-clause) is fulfilled. English has several types of conditionals, each used for different situations and levels of probability.',
    rules: [
      GrammarRule(
        title: 'Zero Conditional',
        description:
            'Used for general truths and scientific facts. Structure: If + present simple, present simple.',
      ),
      GrammarRule(
        title: 'First Conditional',
        description:
            'Used for real and possible situations in the future. Structure: If + present simple, will + infinitive.',
      ),
      GrammarRule(
        title: 'Second Conditional',
        description:
            'Used for unreal or improbable situations in the present or future. Structure: If + past simple, would + infinitive.',
      ),
      GrammarRule(
        title: 'Third Conditional',
        description:
            'Used for impossible situations in the past (hypothetical past). Structure: If + past perfect, would have + past participle.',
      ),
      GrammarRule(
        title: 'Mixed Conditionals',
        description:
            'Combine different types of conditionals when the time reference in the if-clause is different from the time reference in the main clause.',
      ),
      GrammarRule(
        title: 'Unless, As Long As, Provided That',
        description:
            'These can be used instead of "if" in conditional sentences, with slightly different meanings.',
      ),
    ],
    examples: [
      GrammarExample(
        title: 'Zero Conditional',
        correct: 'If you heat water to 100°C, it boils.',
        incorrect: 'If you heat water to 100°C, it will boil.',
        explanation:
            'Zero conditional uses present simple in both clauses to express general truths.',
      ),
      GrammarExample(
        title: 'First Conditional',
        correct: 'If it rains tomorrow, we will cancel the picnic.',
        incorrect: 'If it will rain tomorrow, we will cancel the picnic.',
        explanation:
            'First conditional uses present simple in the if-clause (not future) and will + infinitive in the main clause.',
      ),
      GrammarExample(
        title: 'Second Conditional',
        correct: 'If I won the lottery, I would buy a house.',
        incorrect: 'If I would win the lottery, I would buy a house.',
        explanation:
            'Second conditional uses past simple in the if-clause (not would) and would + infinitive in the main clause.',
      ),
      GrammarExample(
        title: 'Third Conditional',
        correct: 'If you had told me earlier, I would have helped you.',
        incorrect:
            'If you would have told me earlier, I would have helped you.',
        explanation:
            'Third conditional uses past perfect in the if-clause (not would have) and would have + past participle in the main clause.',
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
        'The passive voice is used when the focus is on the action rather than who or what is performing the action. In passive sentences, the subject receives the action expressed by the verb, rather than performing it. The passive voice is particularly common in formal, scientific, and academic writing.',
    rules: [
      GrammarRule(
        title: 'Basic Passive Structure',
        description:
            'Form: be (in the appropriate tense) + past participle. The object of the active sentence becomes the subject of the passive sentence.',
      ),
      GrammarRule(
        title: 'Agent (By Phrase)',
        description:
            'The agent (doer of the action) can be mentioned using "by" but is often omitted if it\'s unknown or unimportant.',
      ),
      GrammarRule(
        title: 'Tenses in Passive Voice',
        description:
            'All tenses can be used in the passive voice by changing the form of "be" to the appropriate tense.',
      ),
      GrammarRule(
        title: 'When to Use Passive Voice',
        description:
            'Use passive when: the doer is unknown, unimportant, or obvious; you want to emphasize the action or the receiver; in formal or scientific writing; or to avoid mentioning who is responsible.',
      ),
      GrammarRule(
        title: 'Verbs with Two Objects',
        description:
            'When an active sentence has two objects (direct and indirect), either can become the subject of the passive sentence.',
      ),
    ],
    examples: [
      GrammarExample(
        title: 'Basic Transformation',
        correct:
            'Active: The chef prepared the meal. / Passive: The meal was prepared by the chef.',
        incorrect: 'The meal was prepare by the chef.',
        explanation:
            'In passive voice, the object of the active sentence becomes the subject, and we use "be" + past participle.',
      ),
      GrammarExample(
        title: 'Different Tenses',
        correct:
            'Present: The house is cleaned weekly. / Past: The house was cleaned yesterday. / Future: The house will be cleaned tomorrow.',
        incorrect: 'The house cleaned weekly. / The house is clean yesterday.',
        explanation:
            'The form of "be" changes according to the tense, but the past participle remains the same.',
      ),
      GrammarExample(
        title: 'Omitting the Agent',
        correct: 'My car was stolen last night.',
        incorrect: 'My car was stolen by someone last night.',
        explanation:
            'The agent is omitted because it\'s unknown who stole the car.',
      ),
      GrammarExample(
        title: 'Verbs with Two Objects',
        correct:
            'Active: She gave me a book. / Passive: I was given a book (by her). OR A book was given to me (by her).',
        incorrect: 'A book was given me by her.',
        explanation:
            'Either the indirect object ("me") or the direct object ("a book") can become the subject of the passive sentence.',
      ),
    ],
  );
}

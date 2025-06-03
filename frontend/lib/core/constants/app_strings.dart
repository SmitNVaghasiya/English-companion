/// Centralized string constants for the English Companion app.
library;

// App information and titles.
class AppInfo {
  static const title = 'English Companion';
  static const chatScreenTitle = 'English Companion';
}

// UI messages and prompts.
class Messages {
  static const initial =
      "Hello! I'm your English Companion. Let's practice your English together. What do you like to do in your free time?";
  static const placeholderNoMessages =
      'Start a conversation with your English companion';
  static const assistantTyping = 'Assistant is typing...';
  static const promptAskAnything = 'Ask anything';
  static const dailyLifeGreeting =
      "Welcome to Daily Life Conversations! Here, you'll practice casual chats with friends and family. Start with prompts like 'How was your day?' to improve your fluency and natural expressions. Let's get talking!";
  static const beginnersHelperGreeting =
      "Hi there! This is the Beginners Helper. Use the Text Chat to practice simple sentences like 'I like to eat rice.' It's perfect for building confidence if you're new to English. Don't forget to check the feedback to improve!";
  static const professionalConversationGreeting =
      "Hello! In this module, you'll practice formal conversations with professionals. First, choose the role of the person you'll be speaking to: senior colleague, manager, client, or executive. For example, to discuss a project with a manager, you might say, 'I'd like to discuss the project timeline.' Select your scenario to start.";
  static const everydaySituationsGreeting =
      "Hey! Ready to tackle everyday situations in English? In this module, you can role-play scenarios like shopping, traveling, or dining out using either text or voice chat. Select a situation and your preferred mode to start practicing!";
  static const initialMessage =
      "Hello! How can I help you practice English today?";
  static const askAnything = "Ask anything";
}

// Connection status messages.
class Connection {
  static const connecting = 'Connecting...';
  static const connected = 'Connected';
  static const failed = 'Connection failed';
  static const serverNotResponding =
      'Server not responding. Please check your connection.';
  static const networkError =
      'Network error. Please check your internet connection.';
}

// Voice recording messages.
class Voice {
  static const recordingError = 'Failed to record voice. Please try again.';
  static const processingError =
      'Failed to process voice input. Please try again.';
  static const permissionDenied =
      'Permission denied. Please enable microphone access.';
}

// Action labels.
class Actions {
  static const retry = 'Retry';
}

// Conversation mode data class
class ConversationModeData {
  final String title;
  final String description;
  final String greeting;
  final bool isLegacy;

  const ConversationModeData({
    required this.title,
    required this.description,
    required this.greeting,
    this.isLegacy = false,
  });
}

// Conversation modes for different practice scenarios.
// Renamed to AppConversationMode to avoid conflict with chat_provider.dart
enum AppConversationMode {
  dailyLife,
  beginnersHelper,
  professional,
  everydaySituations,
  formal,
  informal,
  custom;

  static final Map<AppConversationMode, ConversationModeData> data = {
    AppConversationMode.dailyLife: ConversationModeData(
      title: 'Daily Life Conversation',
      description: 'Practice casual conversations with friends & family',
      greeting: Messages.dailyLifeGreeting,
    ),
    AppConversationMode.beginnersHelper: ConversationModeData(
      title: 'Beginners Helper',
      description: 'Practice simple sentences for beginners',
      greeting: Messages.beginnersHelperGreeting,
    ),
    AppConversationMode.professional: ConversationModeData(
      title: 'Professional Conversation',
      description: 'Practice formal conversations with professionals',
      greeting: Messages.professionalConversationGreeting,
    ),
    AppConversationMode.everydaySituations: ConversationModeData(
      title: 'Everyday Situations',
      description: 'Role-play real-life scenarios like shopping or dining',
      greeting: Messages.everydaySituationsGreeting,
    ),
    AppConversationMode.formal: ConversationModeData(
      title: 'Formal Conversation',
      description: 'Talk with higher position people at work',
      greeting: '',
      isLegacy: true,
    ),
    AppConversationMode.informal: ConversationModeData(
      title: 'Informal Conversation',
      description: 'Chat with friends or strangers',
      greeting: '',
      isLegacy: true,
    ),
    AppConversationMode.custom: ConversationModeData(
      title: 'Custom Conversation',
      description: 'Talk about any topic you choose',
      greeting: '',
      isLegacy: true,
    ),
  };

  String get title => data[this]!.title;
  String get description => data[this]!.description;
  String get greeting => data[this]!.greeting;
  bool get isLegacy => data[this]!.isLegacy;
}

// Conversation mode titles and descriptions
class ConversationStrings {
  static const dailyLifeTitle = 'Daily Life Conversation';
  static const dailyLifeDesc =
      'Practice casual conversations with friends & family';
  static const beginnersHelperTitle = 'Beginners Helper';
  static const beginnersHelperDesc = 'Practice simple sentences for beginners';
  static const professionalTitle = 'Professional Conversation';
  static const professionalDesc =
      'Practice formal conversations with professionals';
  static const everydaySituationsTitle = 'Everyday Situations';
  static const everydaySituationsDesc =
      'Role-play real-life scenarios like shopping or dining';
  static const customConversationTitle = 'Custom Conversation';
  static const customConversationDesc = 'Talk about any topic you choose';
}

/// Main AppStrings class for backward compatibility
class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // Direct static access to all string constants
  static const String appTitle = AppInfo.title;
  static const String chatScreenTitle = AppInfo.chatScreenTitle;

  // Messages
  static const String initial = Messages.initial;
  static const String placeholderNoMessages = Messages.placeholderNoMessages;
  static const String assistantTyping = Messages.assistantTyping;
  static const String promptAskAnything = Messages.promptAskAnything;
  static const String dailyLifeGreeting = Messages.dailyLifeGreeting;
  static const String beginnersHelperGreeting =
      Messages.beginnersHelperGreeting;
  static const String professionalConversationGreeting =
      Messages.professionalConversationGreeting;
  static const String everydaySituationsGreeting =
      Messages.everydaySituationsGreeting;
  static const String initialMessage = Messages.initialMessage;
  static const String askAnything = Messages.askAnything;

  // Connection
  static const String connecting = Connection.connecting;
  static const String connected = Connection.connected;
  static const String connectionFailed = Connection.failed;
  static const String serverNotResponding = Connection.serverNotResponding;
  static const String networkError = Connection.networkError;

  // Voice
  static const String recordingError = Voice.recordingError;
  static const String processingError = Voice.processingError;
  static const String permissionDenied = Voice.permissionDenied;

  // Actions
  static const String retry = Actions.retry;

  // Conversation Strings
  static const String dailyLifeTitle = ConversationStrings.dailyLifeTitle;
  static const String dailyLifeDesc = ConversationStrings.dailyLifeDesc;
  static const String beginnersHelperTitle =
      ConversationStrings.beginnersHelperTitle;
  static const String beginnersHelperDesc =
      ConversationStrings.beginnersHelperDesc;
  static const String professionalTitle = ConversationStrings.professionalTitle;
  static const String professionalDesc = ConversationStrings.professionalDesc;
  static const String everydaySituationsTitle =
      ConversationStrings.everydaySituationsTitle;
  static const String everydaySituationsDesc =
      ConversationStrings.everydaySituationsDesc;
  static const String customConversationTitle =
      ConversationStrings.customConversationTitle;
  static const String customConversationDesc =
      ConversationStrings.customConversationDesc;
}

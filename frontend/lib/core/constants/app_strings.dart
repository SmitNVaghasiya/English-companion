class AppStrings {
  // App Info
  static const String appTitle = 'English Companion';
  static const String chatScreenTitle = 'English Companion';

  // Messages
  static const String initialMessage =
      "Hello! I'm your English Companion. Let's practice your English together. What do you like to do in your free time?";
  static const String noMessagesPlaceholder =
      'Start a conversation with your English companion';
  static const String assistantTyping = 'Assistant is typing...';
  static const String askAnything = 'Ask anything';

  // Connection Status
  static const String connecting = 'Connecting...';
  static const String connected = 'Connected';
  static const String connectionFailed = 'Connection failed';
  static const String serverNotResponding =
      'Server not responding. Please check your connection.';
  static const String networkError =
      'Network error. Please check your internet connection.';

  // Voice Recording
  static const String voiceRecordingError =
      'Failed to record voice. Please try again.';
  static const String voiceProcessingError =
      'Failed to process voice input. Please try again.';
  static const String permissionDenied =
      'Permission denied. Please enable microphone access.';

  // Actions
  static const String retry = 'Retry';

  // Conversation Modes - New Modules
  static const String dailyLifeConversationTitle = 'Daily Life Conversation';
  static const String dailyLifeConversationDesc = 'Practice casual conversations with friends & family';
  static const String dailyLifeGreeting = "Welcome to Daily Life Conversations! Here, you'll practice casual chats with friends and family. Start with prompts like 'How was your day?' to improve your fluency and natural expressions. Let's get talking!";
  
  static const String beginnersHelperTitle = 'Beginners Helper';
  static const String beginnersHelperDesc = 'Practice simple sentences for beginners';
  static const String beginnersHelperGreeting = "Hi there! This is the Beginners Helper. Use the Text Chat to practice simple sentences like 'I like to eat rice.' It's perfect for building confidence if you're new to English. Don't forget to check the feedback to improve!";
  
  static const String professionalConversationTitle = 'Professional Conversation';
  static const String professionalConversationDesc = 'Practice formal conversations with professionals';
  static const String professionalConversationGreeting = "Hello! In this module, you'll practice formal conversations with professionals. First, choose the role of the person you'll be speaking to: senior colleague, manager, client, or executive. For example, to discuss a project with a manager, you might say, 'I'd like to discuss the project timeline.' Select your scenario to start.";
  
  static const String everydaySituationsTitle = 'Everyday Situations';
  static const String everydaySituationsDesc = 'Role-play real-life scenarios like shopping or dining';
  static const String everydaySituationsGreeting = "Hey! Ready to tackle everyday situations in English? In this module, you can role-play scenarios like shopping, traveling, or dining out using either text or voice chat. Select a situation and your preferred mode to start practicing!";
  
  // Legacy Conversation Modes (keeping for backward compatibility)
  static const String formalConversationTitle = 'Formal Conversation';
  static const String formalConversationDesc =
      'Talk with higher position people at work';
  static const String informalConversationTitle = 'Informal Conversation';
  static const String informalConversationDesc =
      'Chat with friends or strangers';
  static const String customConversationTitle = 'Custom Conversation';
  static const String customConversationDesc =
      'Talk about any topic you choose';
}

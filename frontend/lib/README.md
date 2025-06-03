# English Companion - Flutter Frontend

## Project Structure Overview
english_companion/
├── core/
│   ├── config/
│   │   ├── api_config.dart
│   │   └── env_config.dart
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_endpoints.dart
│   │   ├── app_strings.dart
│   │   └── progress_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_theme_mode.dart
│   │   └── theme_provider.dart
│   ├── utils/
│   │   ├── chat_utils.dart
│   │   ├── connection_utils.dart
│   │   └── string_utils.dart
├── data/
│   ├── models/
│   │   ├── chat_response.dart
│   │   ├── grammar_topic.dart
│   │   ├── message_model.dart
│   │   ├── notification_model.dart
│   │   ├── practice_model.dart
│   │   └── progress_model.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── chat_service.dart
│   │   ├── grammar_service.dart
│   │   ├── notification_service.dart
│   │   ├── practice_service.dart
│   │   └── progress_service.dart
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── chat_provider.dart
│   │   ├── notification_provider.dart
│   │   └── progress_provider.dart
│   ├── screens/
│   │   ├── chat_screen.dart
│   │   ├── conversation_mode_screen.dart
│   │   ├── grammar_screen.dart
│   │   ├── grammar_topic_screen.dart
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   ├── notification_settings_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── practice_session_screen.dart
│   │   ├── practice_sessions_screen.dart
│   │   ├── progress_screen.dart
│   │   ├── registration_screen.dart
│   │   └── voice_chat_screen.dart
│   ├── widgets/
│   │   ├── app_drawer.dart
│   │   ├── app_logo.dart
│   │   ├── badge_card.dart
│   │   ├── chat_header.dart
│   │   ├── chat_input_field.dart
│   │   ├── conversation_mode_card.dart
│   │   ├── feature_card.dart
│   │   ├── info_box.dart
│   │   ├── message_bubble.dart
│   │   ├── notification_card.dart
│   │   ├── progress_chart.dart
│   │   ├── settings_tile.dart
│   │   ├── skill_progress_card.dart
│   │   ├── theme_switch.dart
│   │   └── typing_indicator.dart
├── main.dart
└── main_backup.md


### Core Directory (`/core/`)
Contains the fundamental building blocks and configurations of the application.

#### Configuration (`/core/config/`)
- `api_config.dart`: Manages API endpoints, service discovery, and network configurations.
- `env_config.dart`: Handles environment-specific configurations and variables.

#### Constants (`/core/constants/`)
- `app_colors.dart`: Defines the application's color palette.
- `app_endpoints.dart`: Contains all API endpoint URLs.
- `app_strings.dart`: Stores all static strings used in the application for easy localization.

#### Theme (`/core/theme/`)
- `app_theme.dart`: Defines the application's visual theme.
- `app_theme_mode.dart`: Manages light/dark theme modes.
- `theme_provider.dart`: Provider for theme state management.

#### Utils (`/core/utils/`)
- `chat_utils.dart`: Helper functions for chat functionality.
- `connection_utils.dart`: Handles network connectivity checks.

### Data Layer (`/data/`)

#### Models (`/data/models/`)
- `chat_response.dart`: Data model for chat responses.
- `grammar_topic.dart`: Defines grammar topic structure.
- `message_model.dart`: Represents chat messages.
- `notification_model.dart`: Defines notification data structure.
- `practice_model.dart`: Models for practice exercises.
- `progress_model.dart`: Tracks user progress and achievements.

#### Services (`/data/services/`)
- `api_service.dart`: Base service for API communications.
- `chat_service.dart`: Handles chat functionality including text and voice chat.
- `grammar_service.dart`: Manages grammar checking and related operations.
- `notification_service.dart`: Handles push notifications and in-app messages.
- `practice_service.dart`: Manages practice sessions and exercises.
- `progress_service.dart`: Tracks and manages user progress, achievements, and statistics.

### Presentation Layer (`/presentation/`)

#### Providers (`/presentation/providers/`)
- `auth_provider.dart`: Manages authentication state.
- `chat_provider.dart`: Manages chat state and logic.
- `notification_provider.dart`: Handles notification state.
- `progress_provider.dart`: Manages user progress state.

#### Screens (`/presentation/screens/`)
- `chat_screen.dart`: Main chat interface.
- `conversation_mode_screen.dart`: Conversation practice mode.
- `grammar_screen.dart`: Displays grammar topics.
- `grammar_topic_screen.dart`: Shows details of a specific grammar topic.
- `home_screen.dart`: Main dashboard of the app.
- `login_screen.dart`: User authentication screen.
- `notification_settings_screen.dart`: Notification preferences.
- `notifications_screen.dart`: Displays user notifications.
- `practice_session_screen.dart`: Practice exercise interface.
- `practice_sessions_screen.dart`: Lists available practice sessions.
- `progress_screen.dart`: Shows user progress and achievements.
- `registration_screen.dart`: New user registration.
- `voice_chat_screen.dart`: Voice-based chat interface.

#### Widgets (`/presentation/widgets/`)
- `app_drawer.dart`: Application navigation drawer.
- `app_logo.dart`: Reusable app logo component.
- `badge_card.dart`: Displays achievement badges.
- `chat_header.dart`: Header for chat screens.
- `chat_input_field.dart`: Input field for chat messages.
- `conversation_mode_card.dart`: UI component for conversation modes.
- `feature_card.dart`: Displays app features.
- `info_box.dart`: Information display component.
- `message_bubble.dart`: Chat message bubble UI.
- `notification_card.dart`: Displays notification items.
- `progress_chart.dart`: Visualizes user progress.
- `settings_tile.dart`: Settings menu item component.
- `theme_switch.dart`: Toggle for light/dark mode.
- `typing_indicator.dart`: Shows typing status in chat.

### Root Files
- `main.dart`: Application entry point and root widget.
- `main_backup.md`: Backup of important configuration.

## Key Features

1. **Chat Functionality**
   - Text and voice-based chat
   - Real-time messaging
   - Conversation history

2. **Grammar Assistance**
   - Grammar checking
   - Topic-based learning
   - Detailed explanations

3. **Practice Sessions**
   - Interactive exercises
   - Progress tracking
   - Performance analytics

4. **User Progress**
   - Achievement badges
   - Learning statistics
   - Performance metrics

5. **Notifications**
   - In-app notifications
   - Customizable settings
   - Activity reminders

## Technical Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Local Storage**: Shared Preferences
- **Networking**: HTTP Client
- **Audio**: Flutter TTS, Record
- **Theming**: Custom theme with light/dark mode

## Setup Instructions

1. Ensure Flutter SDK is installed
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Configure environment variables in `lib/core/config/env_config.dart`
5. Run the app using `flutter run`

## Dependencies

- flutter_tts: ^3.8.3
- record: ^4.4.0
- http: ^1.1.0
- provider: ^6.1.1
- shared_preferences: ^2.2.2
- permission_handler: ^10.4.3
- path_provider: ^2.1.1
- multicast_dns: ^0.3.2
- intl: ^0.18.1
- flutter_local_notifications: ^16.2.0

## Important Notes

- The application follows a layered architecture with clear separation of concerns
- Services are responsible for business logic and API communication
- The UI layer is separated from business logic
- Configuration and constants are centralized for easier maintenance

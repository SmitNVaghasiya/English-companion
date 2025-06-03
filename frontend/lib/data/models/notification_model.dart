import 'package:flutter/material.dart';

/// Represents a notification in the English Companion app with metadata for display and interaction.
class AppNotification {
  /// Unique identifier for the notification.
  final String id;

  /// Title of the notification.
  final String title;

  /// Detailed message content.
  final String message;

  /// Time the notification was created.
  final DateTime timestamp;

  /// Type of notification (e.g., reminder, achievement).
  final NotificationType type;

  /// Whether the notification has been read.
  final bool isRead;

  /// Optional additional data (e.g., deep link or metadata).
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.data,
  }) {
    if (id.isEmpty) {
      throw ArgumentError('Notification ID cannot be empty');
    }
    if (title.isEmpty) {
      throw ArgumentError('Notification title cannot be empty');
    }
    if (message.isEmpty) {
      throw ArgumentError('Notification message cannot be empty');
    }
  }

  /// Creates a copy of this notification with updated fields.
  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  /// Converts the notification to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'type': type.name,
    'isRead': isRead,
    'data': data,
  };

  /// Creates a notification from a JSON map.
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    try {
      return AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        type: NotificationType.values.byName(json['type'] as String),
        isRead: json['isRead'] as bool? ?? false,
        data: json['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      throw FormatException('Failed to parse AppNotification: $e');
    }
  }

  @override
  String toString() =>
      'AppNotification(id: $id, title: $title, type: $type, isRead: $isRead)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotification &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          message == other.message &&
          timestamp == other.timestamp &&
          type == other.type &&
          isRead == other.isRead &&
          data == other.data;

  @override
  int get hashCode =>
      Object.hash(id, title, message, timestamp, type, isRead, data);
}

/// Enum defining notification types with associated icons and colors.
enum NotificationType {
  reminder(Icons.alarm, Colors.blue),
  achievement(Icons.emoji_events, Colors.amber),
  progress(Icons.trending_up, Colors.green),
  system(Icons.info, Colors.grey),
  tip(Icons.lightbulb_outline, Colors.purple);

  final IconData icon;
  final Color color;

  const NotificationType(this.icon, this.color);
}

/// Settings for managing notification preferences in the app.
class NotificationSettings {
  /// Whether notifications are enabled globally.
  final bool enableNotifications;

  /// Whether daily reminders are enabled.
  final bool enableDailyReminders;

  /// Whether achievement notifications are enabled.
  final bool enableAchievementNotifications;

  /// Whether progress update notifications are enabled.
  final bool enableProgressUpdates;

  /// Whether tip notifications are enabled.
  final bool enableTips;

  /// Time of day for daily reminders, if set.
  final TimeOfDay? dailyReminderTime;

  NotificationSettings({
    this.enableNotifications = true,
    this.enableDailyReminders = true,
    this.enableAchievementNotifications = true,
    this.enableProgressUpdates = true,
    this.enableTips = true,
    TimeOfDay? dailyReminderTime,
  }) : dailyReminderTime = dailyReminderTime ?? const TimeOfDay(hour: 20, minute: 0);

  /// Creates a copy of this settings object with updated fields.
  NotificationSettings copyWith({
    bool? enableNotifications,
    bool? enableDailyReminders,
    bool? enableAchievementNotifications,
    bool? enableProgressUpdates,
    bool? enableTips,
    TimeOfDay? dailyReminderTime,
  }) {
    return NotificationSettings(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableDailyReminders: enableDailyReminders ?? this.enableDailyReminders,
      enableAchievementNotifications:
          enableAchievementNotifications ?? this.enableAchievementNotifications,
      enableProgressUpdates:
          enableProgressUpdates ?? this.enableProgressUpdates,
      enableTips: enableTips ?? this.enableTips,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
    );
  }

  /// Converts the settings to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'enableNotifications': enableNotifications,
    'enableDailyReminders': enableDailyReminders,
    'enableAchievementNotifications': enableAchievementNotifications,
    'enableProgressUpdates': enableProgressUpdates,
    'enableTips': enableTips,
    'dailyReminderTime':
        dailyReminderTime != null
            ? {
              'hour': dailyReminderTime!.hour,
              'minute': dailyReminderTime!.minute,
            }
            : null,
  };

  /// Creates settings from a JSON map.
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationSettings(
        enableNotifications: json['enableNotifications'] as bool? ?? true,
        enableDailyReminders: json['enableDailyReminders'] as bool? ?? true,
        enableAchievementNotifications:
            json['enableAchievementNotifications'] as bool? ?? true,
        enableProgressUpdates: json['enableProgressUpdates'] as bool? ?? true,
        enableTips: json['enableTips'] as bool? ?? true,
        dailyReminderTime:
            json['dailyReminderTime'] != null
                ? TimeOfDay(
                  hour: json['dailyReminderTime']['hour'] as int,
                  minute: json['dailyReminderTime']['minute'] as int,
                )
                : const TimeOfDay(hour: 20, minute: 0),
      );
    } catch (e) {
      throw FormatException('Failed to parse NotificationSettings: $e');
    }
  }

  @override
  String toString() =>
      'NotificationSettings(enableNotifications: $enableNotifications, dailyReminderTime: $dailyReminderTime)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettings &&
          runtimeType == other.runtimeType &&
          enableNotifications == other.enableNotifications &&
          enableDailyReminders == other.enableDailyReminders &&
          enableAchievementNotifications ==
              other.enableAchievementNotifications &&
          enableProgressUpdates == other.enableProgressUpdates &&
          enableTips == other.enableTips &&
          dailyReminderTime == other.dailyReminderTime;

  @override
  int get hashCode => Object.hash(
    enableNotifications,
    enableDailyReminders,
    enableAchievementNotifications,
    enableProgressUpdates,
    enableTips,
    dailyReminderTime,
  );
}

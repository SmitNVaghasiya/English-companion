import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/notification_model.dart';

class NotificationService {
  static const String _notificationsKey = 'app_notifications';
  static const String _notificationSettingsKey = 'notification_settings';

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Motivational messages for daily reminders
  static const List<String> _motivationalMessages = [
    "Time for your daily English practice! Keep building your skills!",
    "Ready to improve your English today? Let's practice together!",
    "Your daily English session is waiting for you. Keep up the good work!",
    "Consistency is key to language mastery. Time for today's practice!",
    "Every day of practice brings you closer to fluency. Let's go!",
    "Your English skills are growing with every practice. Time for today's session!",
    "A few minutes of practice today will make a big difference tomorrow!",
    "Language learning is a journey. Take another step forward today!",
    "Your future self will thank you for practicing today. Let's get started!",
    "Small daily improvements lead to amazing results. Time to practice!",
  ];

  // Initialize notifications
  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final IOSFlutterLocalNotificationsPlugin? iOSPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    if (iOSPlugin != null) {
      await iOSPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
    // This can be expanded to navigate to specific screens based on the payload
  }

  // Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_notificationSettingsKey);

      if (settingsJson != null) {
        try {
          final settings = NotificationSettings.fromJson(
            jsonDecode(settingsJson) as Map<String, dynamic>
          );
          return settings;
        } catch (e) {
          debugPrint('Error parsing notification settings: $e');
          // Return default settings if parsing fails
        }
      }

      // Default settings with explicit values
      return NotificationSettings(
        enableNotifications: true,
        enableDailyReminders: true,
        enableAchievementNotifications: true,
        enableProgressUpdates: true,
        enableTips: true,
        dailyReminderTime: const TimeOfDay(hour: 20, minute: 0), // 8:00 PM
      );
    } catch (e) {
      debugPrint('Error getting notification settings: $e');
      // Return default settings with explicit values
      return NotificationSettings(
        enableNotifications: true,
        enableDailyReminders: true,
        enableAchievementNotifications: true,
        enableProgressUpdates: true,
        enableTips: true,
        dailyReminderTime: const TimeOfDay(hour: 20, minute: 0),
      );
    }
  }

  // Save notification settings
  Future<bool> saveNotificationSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _notificationSettingsKey,
        jsonEncode(settings.toJson()),
      );

      // Update scheduled notifications based on new settings
      await _updateScheduledNotifications(settings);

      return true;
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
      return false;
    }
  }

  // Schedule daily reminder notification
  Future<void> _updateScheduledNotifications(
    NotificationSettings settings,
  ) async {
    try {
      // Cancel all existing notifications
      await flutterLocalNotificationsPlugin.cancelAll();

      // If notifications are disabled, don't schedule new ones
      if (!settings.enableNotifications) {
        return;
      }

      // Schedule daily reminder if enabled and time is set
      if (settings.enableDailyReminders) {
        final reminderTime = settings.dailyReminderTime ?? const TimeOfDay(hour: 20, minute: 0);
        await _scheduleDailyReminder(reminderTime);
      }
    } catch (e) {
      debugPrint('Error updating scheduled notifications: $e');
      // Re-throw to be handled by the caller
      rethrow;
    }
  }

  Future<void> _scheduleDailyReminder(TimeOfDay reminderTime) async {
    final random = Random();
    final message =
        _motivationalMessages[random.nextInt(_motivationalMessages.length)];

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription: 'Daily reminders to practice English',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID
      'English Companion',
      message,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_reminder',
    );
  }

  // Show achievement notification
  Future<void> showAchievementNotification(String title, String message) async {
    final settings = await getNotificationSettings();

    if (!settings.enableNotifications ||
        !settings.enableAchievementNotifications) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'achievements',
          'Achievements',
          channelDescription: 'Notifications for new achievements',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      1, // Different ID from daily reminder
      title,
      message,
      notificationDetails,
      payload: 'achievement',
    );

    // Also save to in-app notifications
    await _saveNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        timestamp: DateTime.now(),
        type: NotificationType.achievement,
      ),
    );
  }

  // Show progress update notification
  Future<void> showProgressNotification(String title, String message) async {
    final settings = await getNotificationSettings();

    if (!settings.enableNotifications || !settings.enableProgressUpdates) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'progress',
          'Progress Updates',
          channelDescription: 'Notifications for progress updates',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      2, // Different ID
      title,
      message,
      notificationDetails,
      payload: 'progress',
    );

    // Also save to in-app notifications
    await _saveNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        timestamp: DateTime.now(),
        type: NotificationType.progress,
      ),
    );
  }

  // Show tip notification
  Future<void> showTipNotification(String title, String message) async {
    final settings = await getNotificationSettings();

    if (!settings.enableNotifications || !settings.enableTips) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tips',
          'Learning Tips',
          channelDescription: 'Helpful tips for language learning',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showWhen: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      3, // Different ID
      title,
      message,
      notificationDetails,
      payload: 'tip',
    );

    // Also save to in-app notifications
    await _saveNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        timestamp: DateTime.now(),
        type: NotificationType.tip,
      ),
    );
  }

  // Get all in-app notifications
  Future<List<AppNotification>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> notificationsList = jsonDecode(notificationsJson);
        return notificationsList
            .map((item) => AppNotification.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      return [];
    }
  }

  // Save a notification to storage
  Future<bool> _saveNotification(AppNotification notification) async {
    try {
      final notifications = await getNotifications();
      notifications.insert(
        0,
        notification,
      ); // Add new notification at the beginning

      // Limit to 50 notifications to prevent excessive storage use
      final limitedNotifications =
          notifications.length > 50
              ? notifications.sublist(0, 50)
              : notifications;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _notificationsKey,
        jsonEncode(limitedNotifications.map((n) => n.toJson()).toList()),
      );

      return true;
    } catch (e) {
      debugPrint('Error saving notification: $e');
      return false;
    }
  }

  // Mark a notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications =
          notifications.map((notification) {
            if (notification.id == notificationId) {
              return notification.copyWith(isRead: true);
            }
            return notification;
          }).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _notificationsKey,
        jsonEncode(updatedNotifications.map((n) => n.toJson()).toList()),
      );

      return true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllNotificationsAsRead() async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications =
          notifications.map((notification) {
            return notification.copyWith(isRead: true);
          }).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _notificationsKey,
        jsonEncode(updatedNotifications.map((n) => n.toJson()).toList()),
      );

      return true;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications =
          notifications
              .where((notification) => notification.id != notificationId)
              .toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _notificationsKey,
        jsonEncode(updatedNotifications.map((n) => n.toJson()).toList()),
      );

      return true;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  // Clear all notifications
  Future<bool> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationsKey, jsonEncode([]));

      return true;
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
      return false;
    }
  }
}

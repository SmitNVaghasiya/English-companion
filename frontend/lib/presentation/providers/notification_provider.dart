import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<AppNotification> _notifications = [];
  NotificationSettings _settings = NotificationSettings();
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<AppNotification> get notifications => _notifications;
  NotificationSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  // Initialize notifications
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Initialize notification service
      await _notificationService.initialize();
      
      // Load notification settings
      _settings = await _notificationService.getNotificationSettings();
      
      // Load notifications
      await loadNotifications();
      
      _setLoading(false);
    } catch (e) {
      _setError('Error initializing notifications: $e');
    }
  }
  
  // Load notifications
  Future<void> loadNotifications() async {
    _setLoading(true);
    try {
      _notifications = await _notificationService.getNotifications();
      _setLoading(false);
    } catch (e) {
      _setError('Error loading notifications: $e');
    }
  }
  
  // Update notification settings
  Future<bool> updateSettings(NotificationSettings newSettings) async {
    _setLoading(true);
    try {
      final success = await _notificationService.saveNotificationSettings(newSettings);
      
      if (success) {
        _settings = newSettings;
        _setLoading(false);
      }
      
      return success;
    } catch (e) {
      _setError('Error updating notification settings: $e');
      return false;
    }
  }
  
  // Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markNotificationAsRead(notificationId);
      
      if (success) {
        // Update local notification list
        _notifications = _notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Error marking notification as read: $e');
      return false;
    }
  }
  
  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final success = await _notificationService.markAllNotificationsAsRead();
      
      if (success) {
        // Update local notification list
        _notifications = _notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();
        
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Error marking all notifications as read: $e');
      return false;
    }
  }
  
  // Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      
      if (success) {
        // Update local notification list
        _notifications = _notifications
            .where((notification) => notification.id != notificationId)
            .toList();
        
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Error deleting notification: $e');
      return false;
    }
  }
  
  // Clear all notifications
  Future<bool> clearAllNotifications() async {
    try {
      final success = await _notificationService.clearAllNotifications();
      
      if (success) {
        _notifications = [];
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Error clearing notifications: $e');
      return false;
    }
  }
  
  // Show achievement notification
  Future<void> showAchievementNotification(String title, String message) async {
    await _notificationService.showAchievementNotification(title, message);
    await loadNotifications(); // Reload notifications to include the new one
  }
  
  // Show progress notification
  Future<void> showProgressNotification(String title, String message) async {
    await _notificationService.showProgressNotification(title, message);
    await loadNotifications(); // Reload notifications to include the new one
  }
  
  // Show tip notification
  Future<void> showTipNotification(String title, String message) async {
    await _notificationService.showTipNotification(title, message);
    await loadNotifications(); // Reload notifications to include the new one
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? errorMessage) {
    _error = errorMessage;
    _isLoading = false;
    notifyListeners();
  }
}

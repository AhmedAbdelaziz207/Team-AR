import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/common/exceptions/notification_exceptions.dart';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_settings_model.dart';
import '../../../core/constants/notification_constants.dart';

class NotificationStorage {
  static const String _notificationsKey = 'notifications';
  static const String _settingsKey = 'notification_settings';
  static const String _unreadCountKey = 'unread_count';

  // Save single notification
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getNotifications();

      // Add new notification to beginning of list
      notifications.insert(0, notification);

      // Keep only last 100 notifications to prevent storage overflow
      if (notifications.length > NotificationConstants.maxStoredNotifications) {
        notifications.removeRange(NotificationConstants.maxStoredNotifications, notifications.length);
      }

      // Save to storage
      final notificationJsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(notificationJsonList));

      // Update unread count
      await _updateUnreadCount();

    } catch (e) {
      throw NotificationStorageException('فشل في حفظ الإشعار: ${e.toString()}');
    }
  }

  // Update existing notification
  Future<void> updateNotification(NotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getNotifications();

      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = notification;

        // Save to storage
        final notificationJsonList = notifications.map((n) => n.toJson()).toList();
        await prefs.setString(_notificationsKey, jsonEncode(notificationJsonList));

        // Update unread count
        await _updateUnreadCount();
      }
    } catch (e) {
      throw NotificationStorageException('فشل في تحديث الإشعار: ${e.toString()}');
    }
  }

  // Get notification by ID
  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      final notifications = await getNotifications();
      try {
        return notifications.firstWhere((n) => n.id == id);
      } catch (e) {
        return null; // Return null if not found
      }
    } catch (e) {
      throw NotificationStorageException(
        'فشل في الحصول على الإشعار من التخزين المحلي: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Get all notifications
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson == null) {
        return [];
      }

      final List<dynamic> notificationsList = jsonDecode(notificationsJson);
      return notificationsList
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw NotificationStorageException('فشل في تحميل الإشعارات: ${e.toString()}');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);

      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        await _saveNotifications(notifications);
        await _updateUnreadCount();
      }
    } catch (e) {
      throw NotificationStorageException('فشل في تحديث حالة الإشعار: ${e.toString()}');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications = notifications.map((n) => n.copyWith(isRead: true)).toList();

      await _saveNotifications(updatedNotifications);
      await _updateUnreadCount();
    } catch (e) {
      throw NotificationStorageException('فشل في تحديث حالة جميع الإشعارات: ${e.toString()}');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      notifications.removeWhere((n) => n.id == notificationId);

      await _saveNotifications(notifications);
      await _updateUnreadCount();
    } catch (e) {
      throw NotificationStorageException('فشل في حذف الإشعار: ${e.toString()}');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
      await prefs.setInt(_unreadCountKey, 0);
    } catch (e) {
      throw NotificationStorageException('فشل في مسح جميع الإشعارات: ${e.toString()}');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_unreadCountKey) ?? 0;
    } catch (e) {
      throw NotificationStorageException('فشل في تحميل عدد الإشعارات غير المقروءة: ${e.toString()}');
    }
  }

  // Save notification settings
  Future<void> saveNotificationSettings(NotificationSettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    } catch (e) {
      throw NotificationStorageException('فشل في حفظ إعدادات الإشعارات: ${e.toString()}');
    }
  }

  // Get notification settings
  Future<NotificationSettingsModel> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson == null) {
        return const NotificationSettingsModel();
      }

      final settingsMap = jsonDecode(settingsJson);
      return NotificationSettingsModel.fromJson(settingsMap);
    } catch (e) {
      throw NotificationStorageException('فشل في تحميل إعدادات الإشعارات: ${e.toString()}');
    }
  }

  // Get notifications by type
  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => n.type.name == type).toList();
    } catch (e) {
      throw NotificationStorageException('فشل في تحميل الإشعارات من النوع المحدد: ${e.toString()}');
    }
  }

  // Get unread notifications
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).toList();
    } catch (e) {
      throw NotificationStorageException('فشل في تحميل الإشعارات غير المقروءة: ${e.toString()}');
    }
  }

  // Get notifications in date range
  Future<List<NotificationModel>> getNotificationsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) {
        return n.createdAt.isAfter(startDate) && n.createdAt.isBefore(endDate);
      }).toList();
    } catch (e) {
      throw NotificationStorageException('فشل في تحميل الإشعارات في الفترة المحددة: ${e.toString()}');
    }
  }

  // Delete old notifications (older than specified days)
  Future<void> deleteOldNotifications({int olderThanDays = 30}) async {
    try {
      final notifications = await getNotifications();
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));

      final filteredNotifications = notifications.where((n) {
        return n.createdAt.isAfter(cutoffDate);
      }).toList();

      await _saveNotifications(filteredNotifications);
      await _updateUnreadCount();
    } catch (e) {
      throw NotificationStorageException('فشل في حذف الإشعارات القديمة: ${e.toString()}');
    }
  }

  // Private helper methods
  Future<void> _saveNotifications(List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationJsonList = notifications.map((n) => n.toJson()).toList();
    await prefs.setString(_notificationsKey, jsonEncode(notificationJsonList));
  }

  Future<void> _updateUnreadCount() async {
    final notifications = await getNotifications();
    final unreadCount = notifications.where((n) => !n.isRead).length;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unreadCountKey, unreadCount);
  }
}
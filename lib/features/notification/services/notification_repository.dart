import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/common/exceptions/notification_exceptions.dart';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_settings_model.dart';
import '../../../core/common/notification_type_enum.dart';
import '../../../core/constants/notification_constants.dart';
import 'notification_storage.dart';

class NotificationRepository {
  final NotificationStorage _storage;

  NotificationRepository({required NotificationStorage storage})
      : _storage = storage;

  // Save notification
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      await _storage.saveNotification(notification);
    } catch (e) {
      throw NotificationStorageException(
        'فشل في حفظ الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Get notification by ID
  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      return await _storage.getNotificationById(id);
    } catch (e) {
      throw NotificationStorageException(
        'فشل في الحصول على الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      return await _storage.getNotifications();
    } catch (e) {
      throw NotificationStorageException(
        'فشل في الحصول على جميع الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Get unread notifications
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      return await _storage.getUnreadNotifications();
    } catch (e) {
      throw NotificationStorageException(
        'فشل في الحصول على الإشعارات غير المقروءة: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Get notifications by type
  Future<List<NotificationModel>> getNotificationsByType(
      NotificationType type,
      ) async {
    try {
      final allNotifications = await _storage.getNotifications();
      return allNotifications.where((n) => n.type == type).toList();
    } catch (e) {
      throw NotificationStorageException(
        'فشل في الحصول على الإشعارات حسب النوع: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Get notifications by date range
  Future<List<NotificationModel>> getNotificationsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _storage.getNotificationsInRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw NotificationStorageException(
        'فشل في الحصول على الإشعارات حسب النطاق الزمني: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _storage.markAsRead(notificationId);
    } catch (e) {
      throw NotificationStorageException(
        'فشل في تحديث حالة الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _storage.markAllAsRead();
    } catch (e) {
      throw NotificationStorageException(
        'فشل في تحديث جميع الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _storage.deleteNotification(notificationId);
    } catch (e) {
      throw NotificationStorageException(
        'فشل في حذف الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _storage.clearAllNotifications();
    } catch (e) {
      throw NotificationStorageException(
        'فشل في مسح جميع الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      return await _storage.getUnreadCount();
    } catch (e) {
      throw NotificationStorageException(
        'فشل في الحصول على عدد الإشعارات غير المقروءة: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Clean old notifications
  Future<void> cleanOldNotifications({int maxAge = 30}) async {
    try {
      await _storage.deleteOldNotifications(olderThanDays: maxAge);
    } catch (e) {
      throw NotificationStorageException(
        'فشل في تنظيف الإشعارات القديمة: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Save notification settings
  Future<void> saveNotificationSettings(NotificationSettingsModel settings) async {
    try {
      await _storage.saveNotificationSettings(settings);
    } catch (e) {
      throw NotificationStorageException(
        'فشل في حفظ إعدادات الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Get notification settings
  Future<NotificationSettingsModel> getNotificationSettings() async {
    try {
      return await _storage.getNotificationSettings();
    } catch (e) {
      throw NotificationStorageException(
        'فشل في الحصول على إعدادات الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Get notification statistics
  Future<Map<String, dynamic>> getNotificationStatistics() async {
    try {
      final allNotifications = await _storage.getNotifications();
      final unreadCount = allNotifications.where((n) => !n.isRead).length;
      final readCount = allNotifications.where((n) => n.isRead).length;

      final Map<String, int> typeStats = {};
      for (final notification in allNotifications) {
        final typeKey = notification.type.name;
        typeStats[typeKey] = (typeStats[typeKey] ?? 0) + 1;
      }

      final today = DateTime.now();
      final todayNotifications = allNotifications.where((n) {
        return n.createdAt.year == today.year &&
            n.createdAt.month == today.month &&
            n.createdAt.day == today.day;
      }).length;

      final thisWeekNotifications = allNotifications.where((n) {
        final weekAgo = today.subtract(const Duration(days: 7));
        return n.createdAt.isAfter(weekAgo);
      }).length;

      return {
        'total': allNotifications.length,
        'unread': unreadCount,
        'read': readCount,
        'today': todayNotifications,
        'this_week': thisWeekNotifications,
        'by_type': typeStats,
        'oldest': allNotifications.isNotEmpty
            ? allNotifications.map((n) => n.createdAt).reduce((a, b) => a.isBefore(b) ? a : b)
            : null,
        'newest': allNotifications.isNotEmpty
            ? allNotifications.map((n) => n.createdAt).reduce((a, b) => a.isAfter(b) ? a : b)
            : null,
      };
    } catch (e) {
      throw NotificationStorageException(
        'فشل في الحصول على إحصائيات الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Search notifications
  Future<List<NotificationModel>> searchNotifications(String query) async {
    try {
      final allNotifications = await _storage.getNotifications();
      final lowercaseQuery = query.toLowerCase();

      return allNotifications.where((n) {
        return n.title.toLowerCase().contains(lowercaseQuery) ||
            n.body.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw NotificationStorageException(
        'فشل في البحث في الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Export notifications
  Future<List<Map>> exportNotifications() async {
    try {
      final allNotifications = await _storage.getNotifications();
      return allNotifications.map((n) => n.toJson()).toList();
    } catch (e) {
      throw NotificationStorageException(
        'فشل في تصدير الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Import notifications
  Future<void> importNotifications(List<Map<String, dynamic>> notificationsData) async {
    try {
      for (final notificationData in notificationsData) {
        final notification = NotificationModel.fromJson(notificationData);
        await _storage.saveNotification(notification);
      }
    } catch (e) {
      throw NotificationStorageException(
        'فشل في استيراد الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Stream of notifications (for real-time updates)
  Stream<List<NotificationModel>> watchNotifications() async* {
    while (true) {
      try {
        final notifications = await _storage.getNotifications();
        yield notifications;
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        yield [];
      }
    }
  }

  // Stream of unread count
  Stream<int> watchUnreadCount() async* {
    while (true) {
      try {
        final count = await _storage.getUnreadCount();
        yield count;
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        yield 0;
      }
    }
  }
}
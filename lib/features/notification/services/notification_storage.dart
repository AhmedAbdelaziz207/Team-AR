import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/common/exceptions/notification_exceptions.dart';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_settings_model.dart';

class NotificationStorage {
  static const String _notificationsKey = 'notifications';
  static const String _settingsKey = 'notification_settings';
  static const String _unreadCountKey = 'unread_count';
  static const String _lastCleanupKey = 'last_cleanup_date';
  static const int _maxStoredNotifications = 100;
  static const int _cleanupIntervalDays = 7;

  // حفظ إشعار واحد
  Future saveNotification(NotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getNotifications();

      final existingIndex =
      notifications.indexWhere((n) => n.id == notification.id);
      if (existingIndex != -1) {
        notifications[existingIndex] = notification;
      } else {
        notifications.insert(0, notification);
      }

      if (notifications.length > _maxStoredNotifications) {
        notifications.removeRange(
            _maxStoredNotifications, notifications.length);
      }

      final notificationJsonList =
      notifications.map((n) => n.toJson()).toList();
      await prefs.setString(
          _notificationsKey, jsonEncode(notificationJsonList));

      await _updateUnreadCount();
      await _performPeriodicCleanup();
    } catch (e) {
      throw NotificationStorageException(
        'فشل في حفظ الإشعار: ${e.toString()}',
      );
    }
  }

  // تحديث إشعار موجود
  Future updateNotification(NotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getNotifications();

      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = notification;

        final notificationJsonList =
        notifications.map((n) => n.toJson()).toList();
        await prefs.setString(
            _notificationsKey, jsonEncode(notificationJsonList));

        await _updateUnreadCount();
      } else {
        throw NotificationStorageException('الإشعار غير موجود: ${notification.id}');
      }
    } catch (e) {
      throw NotificationStorageException('فشل في تحديث الإشعار: ${e.toString()}');
    }
  }

  // الحصول على إشعار بالمعرف
  Future getNotificationById(String id) async {
    try {
      final notifications = await getNotifications();
      final index = notifications.indexWhere((n) => n.id == id);
      return index != -1 ? notifications[index] : null;
    } catch (e) {
      throw NotificationStorageException(
        'فشل في الحصول على الإشعار من التخزين المحلي: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // الحصول على جميع الإشعارات
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson == null) return [];

      final List decodedList = jsonDecode(notificationsJson);
      final notifications = decodedList
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } catch (e) {
      throw NotificationStorageException('فشل في تحميل الإشعارات: ${e.toString()}');
    }
  }

  // تحديد إشعار كمقروء
  Future markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);

      if (index != -1) {
        notifications[index] =
            notifications[index].copyWith(isRead: true);
        await _saveNotifications(notifications);
        await _updateUnreadCount();
      } else {
        throw NotificationStorageException('الإشعار غير موجود: $notificationId');
      }
    } catch (e) {
      throw NotificationStorageException('فشل في تحديث حالة الإشعار: ${e.toString()}');
    }
  }

  // تحديد جميع الإشعارات كمقروءة
  Future markAllAsRead() async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications =
      notifications.map((n) => n.copyWith(isRead: true)).toList();

      await _saveNotifications(updatedNotifications);
      await _updateUnreadCount();
    } catch (e) {
      throw NotificationStorageException('فشل في تحديث حالة جميع الإشعارات: ${e.toString()}');
    }
  }

  // حذف إشعار
  Future deleteNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final originalLength = notifications.length;
      notifications.removeWhere((n) => n.id == notificationId);

      if (notifications.length == originalLength) {
        throw NotificationStorageException('الإشعار غير موجود: $notificationId');
      }

      await _saveNotifications(notifications);
      await _updateUnreadCount();
    } catch (e) {
      throw NotificationStorageException('فشل في حذف الإشعار: ${e.toString()}');
    }
  }

  // مسح جميع الإشعارات
  Future clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
      await prefs.setInt(_unreadCountKey, 0);
    } catch (e) {
      throw NotificationStorageException('فشل في مسح جميع الإشعارات: ${e.toString()}');
    }
  }

  // الحصول على عدد الإشعارات غير المقروءة
  Future<int> getUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_unreadCountKey) ?? 0;
    } catch (e) {
      throw NotificationStorageException(
        'فشل في تحميل عدد الإشعارات غير المقروءة: ${e.toString()}',
      );
    }
  }

  // حفظ إعدادات الإشعارات
  Future saveNotificationSettings(NotificationSettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    } catch (e) {
      throw NotificationStorageException('فشل في حفظ إعدادات الإشعارات: ${e.toString()}');
    }
  }

  // الحصول على إعدادات الإشعارات
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

  // الحصول على الإشعارات حسب النوع
  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => n.type.name == type).toList();
    } catch (e) {
      throw NotificationStorageException('فشل في تحميل الإشعارات من النوع المحدد: ${e.toString()}');
    }
  }

  // الحصول على الإشعارات غير المقروءة
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).toList();
    } catch (e) {
      throw NotificationStorageException('فشل في تحميل الإشعارات غير المقروءة: ${e.toString()}');
    }
  }

  // الحصول على الإشعارات في نطاق تاريخ محدد
  Future<List<NotificationModel>> getNotificationsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final notifications = await getNotifications();
      return notifications
          .where((n) =>
      n.createdAt.isAfter(startDate) &&
          n.createdAt.isBefore(endDate))
          .toList();
    } catch (e) {
      throw NotificationStorageException('فشل في تحميل الإشعارات في الفترة المحددة: ${e.toString()}');
    }
  }

  // حذف الإشعارات القديمة
  Future deleteOldNotifications({int olderThanDays = 30}) async {
    try {
      final notifications = await getNotifications();
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));

      final filteredNotifications = notifications
          .where((n) => n.createdAt.isAfter(cutoffDate))
          .toList();

      if (filteredNotifications.length != notifications.length) {
        await _saveNotifications(filteredNotifications);
        await _updateUnreadCount();
        print(
            'Deleted ${notifications.length - filteredNotifications.length} old notifications');
      }
    } catch (e) {
      throw NotificationStorageException('فشل في حذف الإشعارات القديمة: ${e.toString()}');
    }
  }

  // البحث في الإشعارات
  Future<List<NotificationModel>> searchNotifications(String query) async {
    try {
      final notifications = await getNotifications();
      final lowerQuery = query.toLowerCase();

      return notifications.where((n) {
        return n.title.toLowerCase().contains(lowerQuery) ||
            n.body.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw NotificationStorageException('فشل في البحث في الإشعارات: ${e.toString()}');
    }
  }

  // الحصول على إحصائيات الإشعارات
  Future<Map<String, dynamic>> getNotificationStatistics() async {
    try {
      final notifications = await getNotifications();
      final Map<String, dynamic> stats = {};

      stats['total'] = notifications.length;
      stats['unread'] = notifications.where((n) => !n.isRead).length;

      for (final notification in notifications) {
        final type = notification.type.name;
        stats[type] = (stats[type] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw NotificationStorageException('فشل في الحصول على إحصائيات الإشعارات: ${e.toString()}');
    }
  }

  // حفظ قائمة الإشعارات
  Future _saveNotifications(List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationJsonList =
    notifications.map((n) => n.toJson()).toList();
    await prefs.setString(
        _notificationsKey, jsonEncode(notificationJsonList));
  }

  // تحديث عدد الإشعارات غير المقروءة
  Future _updateUnreadCount() async {
    final notifications = await getNotifications();
    final unreadCount = notifications.where((n) => !n.isRead).length;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unreadCountKey, unreadCount);
  }

  // تنظيف دوري
  Future _performPeriodicCleanup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCleanupString = prefs.getString(_lastCleanupKey);
      final now = DateTime.now();

      DateTime? lastCleanup;
      if (lastCleanupString != null) {
        lastCleanup = DateTime.tryParse(lastCleanupString);
      }

      if (lastCleanup == null ||
          now.difference(lastCleanup).inDays >= _cleanupIntervalDays) {
        await deleteOldNotifications(olderThanDays: 30);
        await prefs.setString(_lastCleanupKey, now.toIso8601String());
        print('Periodic cleanup completed');
      }
    } catch (e) {
      print('Error in periodic cleanup: $e');
    }
  }
}

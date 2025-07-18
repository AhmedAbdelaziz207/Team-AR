import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_ar/core/common/notification_type_enum.dart';
import '../../../core/network/api_service.dart';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_settings_model.dart';
import 'notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiService _apiService;
  final SharedPreferences _sharedPreferences;

  static const String _notificationsKey = 'notifications';
  static const String _settingsKey = 'notification_settings';

  NotificationRepositoryImpl(this._apiService, this._sharedPreferences);

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final notificationsJson = _sharedPreferences.getString(_notificationsKey);
      if (notificationsJson == null) return [];

      final List<dynamic> notificationsList = json.decode(notificationsJson);
      return notificationsList
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading notifications: $e');
      return [];
    }
  }

  @override
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      final notifications = await getAllNotifications();

      // تحديث الإشعار إذا كان موجوداً، أو إضافة جديد
      final existingIndex = notifications.indexWhere((n) => n.id == notification.id);
      if (existingIndex >= 0) {
        notifications[existingIndex] = notification;
      } else {
        notifications.insert(0, notification);
      }

      // حفظ القائمة المحدثة
      final notificationsJson = json.encode(
        notifications.map((n) => n.toJson()).toList(),
      );
      await _sharedPreferences.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      print('Error saving notification: $e');
      throw Exception('Failed to save notification: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final notifications = await getAllNotifications();
      notifications.removeWhere((n) => n.id == notificationId);

      final notificationsJson = json.encode(
        notifications.map((n) => n.toJson()).toList(),
      );
      await _sharedPreferences.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      print('Error deleting notification: $e');
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await getAllNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);

      if (index >= 0) {
        notifications[index] = notifications[index].copyWith(isRead: true);

        final notificationsJson = json.encode(
          notifications.map((n) => n.toJson()).toList(),
        );
        await _sharedPreferences.setString(_notificationsKey, notificationsJson);
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final notifications = await getAllNotifications();
      final updatedNotifications = notifications.map((n) => n.copyWith(isRead: true)).toList();

      final notificationsJson = json.encode(
        updatedNotifications.map((n) => n.toJson()).toList(),
      );
      await _sharedPreferences.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      print('Error marking all notifications as read: $e');
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    try {
      await _sharedPreferences.remove(_notificationsKey);
    } catch (e) {
      print('Error clearing notifications: $e');
      throw Exception('Failed to clear notifications: $e');
    }
  }

  @override
  Future<NotificationSettingsModel> getNotificationSettings() async {
    try {
      final settingsJson = _sharedPreferences.getString(_settingsKey);
      if (settingsJson == null) {
        // إرجاع إعدادات افتراضية
        return const NotificationSettingsModel(
          enableNotifications: true,
          enableWorkoutReminders: true,
          enableMotivationalMessages: true,
          enablePromotions: true,
          enableSystemNotifications: true,
          preferredTime: '09:00',
          reminderDays: [1, 2, 3, 4, 5], // من الاثنين إلى الجمعة
        );
      }

      final settingsMap = json.decode(settingsJson);
      return NotificationSettingsModel.fromJson(settingsMap);
    } catch (e) {
      print('Error loading notification settings: $e');
      // إرجاع إعدادات افتراضية في حالة الخطأ
      return const NotificationSettingsModel(
        enableNotifications: true,
        enableWorkoutReminders: true,
        enableMotivationalMessages: true,
        enablePromotions: true,
        enableSystemNotifications: true,
        preferredTime: '09:00',
        reminderDays: [1, 2, 3, 4, 5],
      );
    }
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettingsModel settings) async {
    try {
      final settingsJson = json.encode(settings.toJson());
      await _sharedPreferences.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving notification settings: $e');
      throw Exception('Failed to save notification settings: $e');
    }
  }


  @override
  Future<NotificationModel?> getNotificationById(String id) async {
    final notifications = await getAllNotifications();
    try {
      return notifications.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }


  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    final notifications = await getAllNotifications();
    return notifications.where((n) => !n.isRead).toList();
  }

  @override
  Future<List<NotificationModel>> getNotificationsByType(NotificationType type) async {
    final notifications = await getAllNotifications();
    return notifications.where((n) => n.type == type).toList();
  }

  @override
  Future<List<NotificationModel>> getNotificationsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final notifications = await getAllNotifications();
    return notifications.where((n) {
      return n.createdAt.isAfter(startDate) && n.createdAt.isBefore(endDate);
    }).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final notifications = await getAllNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  @override
  Future<void> cleanOldNotifications({int maxAge = 30}) async {
    final notifications = await getAllNotifications();
    final cutoffDate = DateTime.now().subtract(Duration(days: maxAge));
    final updated = notifications.where((n) => n.createdAt.isAfter(cutoffDate)).toList();

    final updatedJson = json.encode(updated.map((n) => n.toJson()).toList());
    await _sharedPreferences.setString(_notificationsKey, updatedJson);
  }

  @override
  Future<List<Map>> exportNotifications() async {
    final notifications = await getAllNotifications();
    return notifications.map((n) => n.toJson()).toList();
  }

  @override
  Future<void> importNotifications(List<Map<String, dynamic>> notificationsData) async {
    final imported = notificationsData.map((json) => NotificationModel.fromJson(json)).toList();
    final current = await getAllNotifications();

    // Avoid duplicates by ID
    for (final newNotification in imported) {
      final existingIndex = current.indexWhere((n) => n.id == newNotification.id);
      if (existingIndex >= 0) {
        current[existingIndex] = newNotification;
      } else {
        current.add(newNotification);
      }
    }

    final updatedJson = json.encode(current.map((n) => n.toJson()).toList());
    await _sharedPreferences.setString(_notificationsKey, updatedJson);
  }

  @override
  Future<List<NotificationModel>> searchNotifications(String query) async {
    final notifications = await getAllNotifications();
    final lower = query.toLowerCase();
    return notifications.where((n) =>
    n.title.toLowerCase().contains(lower) ||
        n.body.toLowerCase().contains(lower)
    ).toList();
  }

  @override
  Future<Map<String, dynamic>> getNotificationStatistics() async {
    final notifications = await getAllNotifications();

    final unread = notifications.where((n) => !n.isRead).length;
    final read = notifications.where((n) => n.isRead).length;
    final now = DateTime.now();

    final today = notifications.where((n) =>
    n.createdAt.year == now.year &&
        n.createdAt.month == now.month &&
        n.createdAt.day == now.day).length;

    final thisWeek = notifications.where((n) =>
        n.createdAt.isAfter(now.subtract(Duration(days: 7)))).length;

    final byType = <String, int>{};
    for (var n in notifications) {
      final key = n.type.name;
      byType[key] = (byType[key] ?? 0) + 1;
    }

    final oldest = notifications.isNotEmpty
        ? notifications.map((n) => n.createdAt).reduce((a, b) => a.isBefore(b) ? a : b)
        : null;

    final newest = notifications.isNotEmpty
        ? notifications.map((n) => n.createdAt).reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    return {
      'total': notifications.length,
      'unread': unread,
      'read': read,
      'today': today,
      'this_week': thisWeek,
      'by_type': byType,
      'oldest': oldest?.toIso8601String(),
      'newest': newest?.toIso8601String(),
    };
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() async* {
    while (true) {
      final notifications = await getAllNotifications();
      yield notifications;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Stream<int> watchUnreadCount() async* {
    while (true) {
      final count = await getUnreadCount();
      yield count;
      await Future.delayed(Duration(seconds: 1));
    }
  }

}
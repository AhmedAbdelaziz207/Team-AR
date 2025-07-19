import 'dart:async';
import 'package:team_ar/core/common/notification_model.dart';
import 'package:team_ar/features/notification/services/notification_storage.dart';
import 'package:team_ar/features/notification/services/local_notification_service.dart';
import 'package:team_ar/features/notification/services/push_notifications_services.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final NotificationStorage _storage = NotificationStorage();
  final LocalNotificationService _localService = LocalNotificationService();

  bool _isInitialized = false;
  StreamController<NotificationModel>? _notificationStreamController;

  Stream<NotificationModel> get notificationStream =>
      _notificationStreamController?.stream ?? const Stream.empty();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _notificationStreamController = StreamController<NotificationModel>.broadcast();

      // تهيئة الخدمات
      await _localService.initialize(
        onNotificationTap: _handleNotificationTap,
      );

      await FirebaseNotificationsServices.init();

      _isInitialized = true;
      print("NotificationManager initialized successfully");
    } catch (e) {
      print("Error initializing NotificationManager: $e");
    }
  }

  Future<void> handleIncomingNotification(NotificationModel notification) async {
    try {
      // حفظ الإشعار
      await _storage.saveNotification(notification);

      // إشعار المستمعين
      _notificationStreamController?.add(notification);

      // عرض الإشعار المحلي
      await _localService.showNotification(notification);

      print("Notification handled successfully: ${notification.id}");
    } catch (e) {
      print("Error handling notification: $e");
    }
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    return await _storage.getNotifications();
  }

  Future<List<NotificationModel>> getUnreadNotifications() async {
    return await _storage.getUnreadNotifications();
  }

  Future<int> getUnreadCount() async {
    return await _storage.getUnreadCount();
  }

  Future<void> markAsRead(String notificationId) async {
    await _storage.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    await _storage.markAllAsRead();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _storage.deleteNotification(notificationId);
    await _localService.cancelNotification(notificationId);
  }

  Future<void> clearAllNotifications() async {
    await _storage.clearAllNotifications();
    await _localService.cancelAllNotifications();
  }

  void _handleNotificationTap(String payload) async {
    try {
      // العثور على الإشعار وتحديده كمقروء
      final notifications = await _storage.getNotifications();
      final notification = notifications.firstWhere(
            (n) => n.payload == payload,
        // orElse: () => null,
      );

      if (!notification.isRead) {
        await _storage.markAsRead(notification.id);
      }

      print("Notification tapped and marked as read: ${notification?.id}");
    } catch (e) {
      print("Error handling notification tap: $e");
    }
  }

  void dispose() {
    _notificationStreamController?.close();
  }
}

import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notification_service.dart';
import 'notification_storage.dart';

import '../../../core/common/notification_model.dart';
import 'package:team_ar/core/common/notification_model.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/home/admin/repos/trainees_repository.dart';
import '../../../core/common/notification_type_enum.dart';
import '../../../core/prefs/shared_pref_manager.dart';
import '../../../core/utils/app_constants.dart';
import '../../../firebase_options.dart';

class FirebaseNotificationsServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static LocalNotificationService localNotificationService =
  LocalNotificationService();
  static NotificationStorage notificationStorage = NotificationStorage();

  static String firebaseScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  static Future init() async {
    try {
      await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      final token = await messaging.getToken();
      log("FCM token: $token");

      await _saveTokenLocally(token);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        onMessaging(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        onMessageOpenedApp(message);
      });

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        onMessageOpenedApp(initialMessage);
      }

      listenToTokenRefresh();

      // ملاحظة: background message handler يتم تسجيله في main.dart
      log("Firebase Messaging initialized successfully");
    } catch (e) {
      log("Error initializing Firebase Messaging: $e");
      throw Exception("فشل في تهيئة خدمة Firebase: $e");
    }
  }

  static Future onMessageOpenedApp(RemoteMessage message) async {
    try {
      log("Message opened app: ${message.notification?.title ?? "No title"}");

      final notification = _createNotificationFromRemoteMessage(message);

      await notificationStorage.saveNotification(notification);
      await notificationStorage.markAsRead(notification.id);

      log("Notification saved and marked as read: ${notification.id}");
    } catch (e) {
      log("Error handling message opened app: $e");
    }
  }

  static Future onMessaging(RemoteMessage message) async {
    try {
      log("Received foreground message: ${message.notification?.title ?? "No title"}");

      final notification = _createNotificationFromRemoteMessage(message);

      await notificationStorage.saveNotification(notification);
      await localNotificationService.showNotification(notification);

      log("Notification saved and displayed: ${notification.id}");
    } catch (e) {
      log("Error handling foreground message: $e");
    }
  }

  static NotificationModel _createNotificationFromRemoteMessage(RemoteMessage message) {
    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? "إشعار جديد",
      body: message.notification?.body ?? "لديك إشعار جديد",
      type: _getNotificationTypeFromData(message.data),
      createdAt: message.sentTime ?? DateTime.now(),
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      isRead: false,
      customData: message.data.isNotEmpty ? message.data : null,
    );
  }

  static NotificationType _getNotificationTypeFromData(Map data) {
    final type = data['type']?.toString().toLowerCase();
    switch (type) {
      case 'workout_reminder':
        return NotificationType.workoutReminder;
      case 'subscription_expiry':
      case 'subscription_expiring':
        return NotificationType.subscriptionExpiry;
      case 'promotion':
        return NotificationType.promotion;
      case 'booking_confirmation':
        return NotificationType.bookingConfirmation;
      case 'payment_confirmation':
        return NotificationType.paymentConfirmation;
      case 'new_content':
        return NotificationType.newContent;
      case 'maintenance':
        return NotificationType.maintenance;
      default:
        return NotificationType.system;
    }
  }

  static Future _saveTokenLocally(String? token) async {
    if (token != null) {
      try {
        log("Token saved locally: $token");
        // يمكنك حفظ التوكن في SharedPreferences أو قاعدة بيانات محلية
      } catch (e) {
        log("Error saving token locally: $e");
      }
    }
  }

  static Future subscribeToTopic(String topic) async {
    try {
      log("Subscribing to topic: $topic");
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      log("Successfully subscribed to topic: $topic");
    } catch (e) {
      log("Error subscribing to topic $topic: $e");
      throw Exception("فشل في الاشتراك في الموضوع: $topic");
    }
  }

  static Future unSubscribeFromTopic(String topic) async {
    try {
      log("Unsubscribing from topic: $topic");
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      log("Successfully unsubscribed from topic: $topic");
    } catch (e) {
      log("Error unsubscribing from topic $topic: $e");
      throw Exception("فشل في إلغاء الاشتراك من الموضوع: $topic");
    }
  }

  static Future unSubscribeFromAllTopics() async {
    try {
      log("Unsubscribing from all topics");
      List topics = [
        "general",
        "promotions",
        "updates",
        "workout_reminders",
        "subscription_alerts",
        "system_notifications",
      ];

      for (String topic in topics) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        log("Unsubscribed from topic: $topic");
      }
    } catch (e) {
      log("Error unsubscribing from all topics: $e");
    }
  }

  static void onMessaging(RemoteMessage message) {
    try {
      log("Received foreground message: ${message.notification?.title ?? "No title"}");

      // عرض الإشعار المحلي
      localNotificationService.showNotification(
        NotificationModel(
          id: message.messageId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: message.notification?.title ?? "إشعار جديد",
          body: message.notification?.body ?? "لديك إشعار جديد",
          type: NotificationType.system,
          createdAt: message.sentTime ?? DateTime.now(),
        ),
      );
    } catch (e) {
      log("Error handling foreground message: $e");
    }
  }

  static Future<String?> getDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      log("Device token: $token");
      return token;
    } catch (e) {
      log("Error getting device token: $e");
      return null;
    }
  }

  static void _sendFcmTokenToServer() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final userId =
          await SharedPreferencesHelper.getString(AppConstants.userId);
      if (token != null) {
        log("FCM token to send to server: $token");
        TraineesRepository traineesRepository =
            TraineesRepository(getIt<ApiService>());

        await traineesRepository.sendFcmToken({
          "id": 0,
          "userId": userId,
          "deviceToken": token,
        });
        log("FCM token ready to be sent to server");
      } else {
        log("FCM token is null");
      }
    } catch (e) {
      log("Error sending FCM token to server: $e");
    }
  }

  static void listenToTokenRefresh() {
    _sendFcmTokenToServer();
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
      log("FCM token refreshed: $newToken");
      _saveTokenLocally(newToken);
      sendFcmTokenToServer();
    });
  }

  static Future sendTestNotification() async {
    try {
      final testNotification = NotificationModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        title: '🔔 إشعار تجريبي',
        body: 'هذا إشعار تجريبي للتأكد من عمل النظام بشكل صحيح',
        type: NotificationType.system,
        createdAt: DateTime.now(),
        isRead: false,
      );

      await notificationStorage.saveNotification(testNotification);
      await localNotificationService.showNotification(testNotification);

      log("Test notification sent successfully");
    } catch (e) {
      log("Error sending test notification: $e");
    }
  }
      _sendFcmTokenToServer();
    });
  }
}

import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:team_ar/core/common/notification_model.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/home/admin/repos/trainees_repository.dart';
import '../../../core/common/notification_type_enum.dart';
import '../../../core/prefs/shared_pref_manager.dart';
import '../../../core/utils/app_constants.dart';
import '../../../firebase_options.dart';
import 'local_notification_service.dart';

class FirebaseNotificationsServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static LocalNotificationService localNotificationService =
      LocalNotificationService();

  static String firebaseScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  static Future<void> init() async {
    try {
      // طلب الإذونات
      await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      // الحصول على FCM Token
      final token = await messaging.getToken();
      log("FCM token: $token");

      // إعداد foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        onMessaging(message);
      });

      // إعداد message opened app handler
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        onMessageOpenedApp(message);
      });

      // ملاحظة: background message handler يتم تسجيله في main.dart
      log("Firebase Messaging initialized successfully");
    } catch (e) {
      log("Error initializing Firebase Messaging: $e");
    }
  }

  static Future<void> onMessageOpenedApp(RemoteMessage message) async {
    try {
      log("Message opened app: ${message.notification?.title ?? "No title"}");

      // معالجة الإشعار عند فتح التطبيق
      final data = message.data;
      if (data.isNotEmpty) {
        final notification = NotificationModel.fromJson(data);
        // يمكنك هنا إضافة منطق للتنقل للشاشة المناسبة
        log("Notification data: ${notification.toString()}");
      }
    } catch (e) {
      log("Error handling message opened app: $e");
    }
  }

  static void subscribeToTopic(String topic) async {
    try {
      log("Subscribing to topic: $topic");
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      log("Successfully subscribed to topic: $topic");
    } catch (e) {
      log("Error subscribing to topic $topic: $e");
    }
  }

  static void unSubscribeFromTopic(String topic) async {
    try {
      log("Unsubscribing from topic: $topic");
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      log("Successfully unsubscribed from topic: $topic");
    } catch (e) {
      log("Error unsubscribing from topic $topic: $e");
    }
  }

  static void unSubscribeFromAllTopics() async {
    try {
      log("Unsubscribing from all topics");
      // قائمة الموضوعات التي تريد إلغاء الاشتراك منها
      List<String> topics = [
        "general",
        "promotions",
        "updates",
        // أضف المواضيع الأخرى حسب الحاجة
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
      _sendFcmTokenToServer();
    });
  }
}

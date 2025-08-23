import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:team_ar/app.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/utils/app_constants.dart';

import 'package:team_ar/features/notification/services/push_notifications_services.dart';
import 'package:team_ar/features/notification/services/local_notification_service.dart';
import 'package:team_ar/features/notification/services/notification_storage.dart';
import 'package:team_ar/features/notification/services/subscription_monitor_service.dart';

import 'features/auth/login/model/user_role.dart';
import 'core/common/notification_model.dart';
import 'core/common/notification_type_enum.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
final localNotificationService = LocalNotificationService();

@pragma('vm:entry-point')
Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    final storage = NotificationStorage();
    final notification = _createNotificationFromRemoteMessage(message);
    await storage.saveNotification(notification);
    debugPrint("Background notification saved: ${notification.title}");

    await LocalNotificationService().initialize();
    await LocalNotificationService().showNotification(notification);
  } catch (e) {
    debugPrint("Error saving background notification: $e");
  }

  debugPrint('Handling background message: ${message.notification?.title}');
}

NotificationModel _createNotificationFromRemoteMessage(RemoteMessage message) {
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
  );
}

NotificationType _getNotificationTypeFromData(Map data) {
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await EasyLocalization.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await requestNotificationPermissions();
    await FirebaseNotificationsServices.init();
    await initializeNotifications();

    await localNotificationService.initialize(
      onNotificationTap: _handleNotificationTap,
    );

    SubscriptionMonitorService().startMonitoring();
    await setupServiceLocator();

    final token = await SharedPreferencesHelper.getString(AppConstants.token);
    final userRole = await SharedPreferencesHelper.getString(AppConstants.userRole);
    final isDataCompleted = await SharedPreferencesHelper.getBool(AppConstants.dataCompleted);

    String initialRoute;
    if (token != null && userRole != null) {
      if (userRole.toLowerCase() == UserRole.Admin.name.toLowerCase()) {
        initialRoute = Routes.adminLanding;
      } else {
        // Check if trainer user needs to complete data
        if (userRole.toLowerCase() == 'trainer' && !isDataCompleted) {
          initialRoute = Routes.completeData;
        } else {
          initialRoute = Routes.rootScreen;
        }
      }
    } else if (await SharedPreferencesHelper.getString(AppConstants.language) != null) {
      initialRoute = Routes.login;
    } else {
      initialRoute = Routes.onboarding;
    }

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: AppAssets.translationsPath,
        fallbackLocale: const Locale('en'),
        child: App(initialRoute: initialRoute),
      ),
    );
  } catch (e) {
    debugPrint('Error in main: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('حدث خطأ في تشغيل التطبيق'),
                Text(e.toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future initializeNotifications() async {
  try {
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
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    await createNotificationChannel();
  } catch (e) {
    debugPrint('Error initializing notifications: $e');
  }
}

Future createNotificationChannel() async {
  try {
    final List channels = [
      const AndroidNotificationChannel(
        'gym_general',
        'إشعارات عامة',
        description: 'الإشعارات العامة للتطبيق',
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        'gym_workout',
        'تذكيرات التمرين',
        description: 'تذكيرات التمارين والأنشطة',
        importance: Importance.high,
      ),
      const AndroidNotificationChannel(
        'gym_subscription',
        'إشعارات الاشتراك',
        description: 'إشعارات انتهاء وتجديد الاشتراك',
        importance: Importance.high,
      ),
      const AndroidNotificationChannel(
        'gym_system',
        'إشعارات النظام',
        description: 'إشعارات مهمة من النظام',
        importance: Importance.max,
      ),
    ];

    final androidPlugin =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      for (final channel in channels) {
        await androidPlugin.createNotificationChannel(channel);
      }
    }
  } catch (e) {
    debugPrint('Error creating notification channels: $e');
  }
}

void onDidReceiveNotificationResponse(NotificationResponse response) async {
  final payload = response.payload;
  if (payload != null) {
    debugPrint('Notification payload: $payload');

    try {
      final storage = NotificationStorage();
      final notifications = await storage.getNotifications();

      final notificationIndex = notifications.indexWhere(
            (n) => n.payload == payload,
      );

      if (notificationIndex != -1) {
        final notification = notifications[notificationIndex];
        if (!notification.isRead) {
          await storage.markAsRead(notification.id);
        }
      }
    } catch (e) {
      debugPrint("Error handling notification tap: $e");
    }
  }
}

void _handleNotificationTap(String payload) async {
  try {
    final storage = NotificationStorage();
    final notifications = await storage.getNotifications();

    final notificationIndex = notifications.indexWhere(
          (n) => n.payload == payload,
    );

    if (notificationIndex != -1) {
      final notification = notifications[notificationIndex];
      if (!notification.isRead) {
        await storage.markAsRead(notification.id);
      }
      debugPrint("Notification tapped and marked as read: ${notification.id}");
    }
  } catch (e) {
    debugPrint("Error handling notification tap: $e");
  }
}

Future requestNotificationPermissions() async {
  try {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      debugPrint('Notification permission granted');
    } else if (status.isDenied) {
      debugPrint('Notification permission denied');
      await Permission.notification.request();
    } else if (status.isPermanentlyDenied) {
      debugPrint('Notification permission permanently denied');
    }
  } catch (e) {
    debugPrint('Error requesting notification permissions: $e');
  }
}

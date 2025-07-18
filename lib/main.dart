import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/app_assets.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // EasyLocalization init
  await EasyLocalization.ensureInitialized();

  // Dependency Injection
  await setupServiceLocator();

  // إشعارات
  await initializeNotifications();
  await requestNotificationPermissions();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: AppAssets.translationsPath,
      fallbackLocale: const Locale('en'),
      child: const App(),
    ),
  );
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  );

  await createNotificationChannel();
}

Future<void> createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'gym_notifications',
    'Gym Notifications',
    description: 'Notifications for gym app',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void onDidReceiveNotificationResponse(NotificationResponse response) {
  final payload = response.payload;
  if (payload != null) {
    debugPrint('Notification payload: $payload');
  }
}

Future<void> requestNotificationPermissions() async {
  final status = await Permission.notification.request();

  if (status.isGranted) {
    debugPrint('Notification permission granted');
  } else {
    debugPrint('Notification permission denied');
  }

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}



/*
   Generation Commands :::
     -- dart run build_runner build

   Pull Updates To Your Branch :::
     -- git pull origin master


 */

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:team_ar/app.dart';
import 'package:flutter/material.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/features/notification/services/push_notifications_services.dart';
import 'core/prefs/shared_pref_manager.dart';
import 'core/routing/routes.dart';
import 'core/utils/app_constants.dart';
import 'features/auth/login/model/user_role.dart';
import 'package:permission_handler/permission_handler.dart';

import 'features/notification/services/local_notification_service.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final localNotificationService = LocalNotificationService();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await ScreenUtil.ensureScreenSize();
  // Easy Localization init

  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseNotificationsServices.init();
  initializeNotifications();
  localNotificationService.initialize();

  // Dependency Injection
  await setupServiceLocator();

  final token = await SharedPreferencesHelper.getString(AppConstants.token);
  final userRole =
      await SharedPreferencesHelper.getString(AppConstants.userRole);

  String initialRoute;
  if (token != null && userRole != null) {
    if (userRole.toLowerCase() == UserRole.Admin.name.toLowerCase()) {
      initialRoute = Routes.adminLanding;
    } else {
      initialRoute = Routes.rootScreen;
    }
  } else if (await SharedPreferencesHelper.getString(AppConstants.language) !=
      null) {
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
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
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
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
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

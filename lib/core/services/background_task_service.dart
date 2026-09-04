import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/follow_up/services/follow_up_service.dart';
import 'package:team_ar/features/home/admin/repos/trainees_repository.dart';

const String _kLastNotificationTimeKey = 'last_follow_up_notification_time';
const int _kFollowUpNotificationId = 1001;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Role Guard: ONLY Admins are allowed to receive follow-up notifications!
      final role = prefs.getString(AppConstants.userRole)?.toLowerCase().trim();
      final isAdmin =
          role == 'admin' || role == 'adimn' || role == 'administrator';
      final token = prefs.getString(AppConstants.token);

      if (!isAdmin || token == null || token.isEmpty) {
        log('BackgroundTask: Current user is not an admin. Canceling follow_up_task.');
        try {
          await Workmanager().cancelByUniqueName('follow_up_task');
        } catch (_) {}
        return Future.value(true);
      }

      // 2. Rate-Limiting / Cooldown: Do not send more than once per 24 hours
      final lastNotificationStr = prefs.getString(_kLastNotificationTimeKey);
      if (lastNotificationStr != null) {
        final lastNotificationTime = DateTime.tryParse(lastNotificationStr);
        if (lastNotificationTime != null) {
          final hoursDiff =
              DateTime.now().difference(lastNotificationTime).inHours;
          if (hoursDiff < 24) {
            log('BackgroundTask: Notification already sent $hoursDiff hours ago (cooldown 24h). Skipping.');
            return Future.value(true);
          }
        }
      }

      // 3. Supabase initialization (safe)
      if (inputData != null && inputData['supabaseUrl'] != null) {
        try {
          await Supabase.initialize(
            url: inputData['supabaseUrl'],
            anonKey: inputData['supabaseKey'],
          );
        } catch (_) {
          // Already initialized in this isolate
        }
      }

      // 4. Fetch the TRUE count of delayed trainees using ApiService & TraineesRepository
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      dio.options.headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final apiService = ApiService(dio);
      final traineesRepo = TraineesRepository(apiService);
      final followUpService = FollowUpService();

      final delayedTrainees =
          await followUpService.getFollowUpTraineesWithDetails(traineesRepo);

      if (delayedTrainees.isNotEmpty) {
        final count = delayedTrainees.length;
        final payload = jsonEncode({
          'type': 'follow_up',
          'count': count,
          'trainee_id':
              count == 1 ? delayedTrainees.first.trainee.id : null,
        });

        await _showLocalNotification(
          'تذكير بمتابعة المتدربين ⏰',
          count == 1
              ? 'تأخرت متابعة متدرب لأكثر من 14 يوماً، اضغط للمتابعة الآن'
              : 'يوجد $count متدربين تأخرت متابعتهم لأكثر من 14 يوماً!',
          payload: payload,
        );

        // Update last sent timestamp to enforce 24-hour cooldown
        await prefs.setString(
          _kLastNotificationTimeKey,
          DateTime.now().toIso8601String(),
        );
        log('BackgroundTask: Sent follow-up notification for $count trainees.');
      }
    } catch (e) {
      log('BackgroundTask error: $e');
      return Future.value(false);
    }
    return Future.value(true);
  });
}

Future<void> _showLocalNotification(String title, String body,
    {String? payload}) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_notification');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      'follow_up_channel',
      'Follow Up Reminders',
      channelDescription: 'Reminders for trainees needing follow up',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: const Color(0xFFC62828),
      enableLights: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Team AR',
      ),
    ),
  );

  await flutterLocalNotificationsPlugin.show(
    _kFollowUpNotificationId,
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
}

class BackgroundTaskService {
  static void initialize(String supabaseUrl, String supabaseKey) {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    Workmanager().registerPeriodicTask(
      'follow_up_task',
      'checkFollowUps',
      frequency: const Duration(hours: 24),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      inputData: {
        'supabaseUrl': supabaseUrl,
        'supabaseKey': supabaseKey,
      },
    );
  }

  static Future<void> cancel() async {
    try {
      await Workmanager().cancelByUniqueName('follow_up_task');
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.cancel(_kFollowUpNotificationId);
      await flutterLocalNotificationsPlugin.cancel(0);
      debugPrint('BackgroundTaskService: Successfully canceled follow_up_task and cleared notifications');
    } catch (e) {
      debugPrint('Error canceling background task: $e');
    }
  }
}

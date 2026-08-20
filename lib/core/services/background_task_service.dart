import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:team_ar/features/follow_up/services/follow_up_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (inputData != null && inputData['supabaseUrl'] != null) {
        await Supabase.initialize(
          url: inputData['supabaseUrl'],
          anonKey: inputData['supabaseKey'],
        );

        final followUpService = FollowUpService();
        final trainees = await followUpService.getTraineesNeedingFollowUp();

        if (trainees.isNotEmpty) {
          final count = trainees.length;
          await _showLocalNotification(
              'تذكير بمتابعة المتدربين ⏰', 
              'يوجد $count متدرب تأخرت متابعتهم لأكثر من 14 يوماً!'
          );
        }
      }
    } catch (e) {
      return Future.value(false);
    }
    return Future.value(true);
  });
}

Future<void> _showLocalNotification(String title, String body) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'follow_up_channel',
    'Follow Up Reminders',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
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
      initialDelay: const Duration(minutes: 15),
      inputData: {
        'supabaseUrl': supabaseUrl,
        'supabaseKey': supabaseKey,
      },
    );
  }
}

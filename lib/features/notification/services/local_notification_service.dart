
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../../core/common/exceptions/notification_exceptions.dart';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_type_enum.dart';
import '../../../core/constants/notification_constants.dart';
import '../../../core/utils/notification_helper.dart';


class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Function(String)? _onNotificationTap;

  // Initialize the service
   initialize({
    Function(String)? onNotificationTap,
  }) async {
    if (_isInitialized) return;

    try {
      _onNotificationTap = onNotificationTap;

      // Initialize timezone
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosInitializationSettings =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        // onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      await _createNotificationChannels();

      _isInitialized = true;
    } catch (e) {
      throw NotificationServiceException(
        'فشل في تهيئة خدمة الإشعارات المحلية: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Create notification channels
  _createNotificationChannels() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final List<AndroidNotificationChannel> channels = [
        const AndroidNotificationChannel(
          NotificationConstants.workoutChannelId,
          NotificationConstants.workoutChannelName,
          description: NotificationConstants.workoutChannelDescription,
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          ledColor: NotificationConstants.workoutNotificationColor,
        ),
        const AndroidNotificationChannel(
          NotificationConstants.generalChannelId,
          NotificationConstants.generalChannelName,
          description: NotificationConstants.generalChannelDescription,
          importance: Importance.defaultImportance,
          enableVibration: true,
          enableLights: true,
          ledColor: NotificationConstants.generalNotificationColor,
        ),
        const AndroidNotificationChannel(
          NotificationConstants.adminChannelId,
          NotificationConstants.adminChannelName,
          description: NotificationConstants.adminChannelDescription,
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          ledColor: NotificationConstants.adminNotificationColor,
        ),
        const AndroidNotificationChannel(
          NotificationConstants.systemChannelId,
          NotificationConstants.systemChannelName,
          description: NotificationConstants.systemChannelDescription,
          importance: Importance.max,
          enableVibration: true,
          enableLights: true,
          ledColor: NotificationConstants.systemNotificationColor,
        ),
      ];

      for (final channel in channels) {
        await androidPlugin.createNotificationChannel(channel);
      }
    }
  }


  // Show instant notification
   showNotification(NotificationModel notification) async {
    if (!_isInitialized) {
      throw const NotificationServiceException(
        'خدمة الإشعارات غير مهيئة',
        code: 'NOT_INITIALIZED',
      );
    }

    try {
      final int id = NotificationHelper.generateIntId();
      final channelId = NotificationHelper.getChannelId(notification.type);

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: _getImportance(notification.type),
        priority: Priority.high,
        showWhen: true,
        when: notification.createdAt.millisecondsSinceEpoch,
        icon: '@mipmap/ic_launcher',
        color: NotificationHelper.getNotificationColor(notification.type),
        enableVibration: true,
        enableLights: true,
        ledColor: NotificationHelper.getNotificationColor(notification.type),
        ticker: notification.title,
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: notification.payload,
      );
    } catch (e) {
      throw NotificationServiceException(
        'فشل في عرض الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Schedule notification
   scheduleNotification(
      NotificationModel notification,
      DateTime scheduledTime,
      ) async {
    if (!_isInitialized) {
      throw const NotificationServiceException(
        'خدمة الإشعارات غير مهيئة',
        code: 'NOT_INITIALIZED',
      );
    }

    try {
      final int id = NotificationHelper.generateIntId();
      final channelId = NotificationHelper.getChannelId(notification.type);

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: _getImportance(notification.type),
        priority: Priority.high,
        showWhen: true,
        when: scheduledTime.millisecondsSinceEpoch,
        icon: '@mipmap/ic_launcher',
        color: NotificationHelper.getNotificationColor(notification.type),
        enableVibration: true,
        enableLights: true,
        ledColor: NotificationHelper.getNotificationColor(notification.type),
        ticker: notification.title,
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        notification.title,
        notification.body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformChannelSpecifics,
        payload: notification.payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      throw NotificationSchedulingException(
        'فشل في جدولة الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Schedule periodic notification
   schedulePeriodicNotification(
      NotificationModel notification,
      RepeatInterval repeatInterval,
      ) async {
    if (!_isInitialized) {
      throw const NotificationServiceException(
        'خدمة الإشعارات غير مهيئة',
        code: 'NOT_INITIALIZED',
      );
    }

    try {
      final int id = NotificationHelper.generateIntId();
      final channelId = NotificationHelper.getChannelId(notification.type);

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: _getImportance(notification.type),
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: NotificationHelper.getNotificationColor(notification.type),
        enableVibration: true,
        enableLights: true,
        ledColor: NotificationHelper.getNotificationColor(notification.type),
        ticker: notification.title,
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        notification.title,
        notification.body,
        repeatInterval,
        platformChannelSpecifics,
        payload: notification.payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      throw NotificationSchedulingException(
        'فشل في جدولة الإشعار الدوري: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Cancel notification
   cancelNotification(String notificationId) async {
    try {
      final int id = int.tryParse(notificationId) ?? 0;
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      throw NotificationServiceException(
        'فشل في إلغاء الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Cancel all notifications
   cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      throw NotificationServiceException(
        'فشل في إلغاء جميع الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Check if notifications are enabled
  //  areNotificationsEnabled() async {
  //   try {
  //     if (defaultTargetPlatform == TargetPlatform.android) {
  //       final bool? result = await _flutterLocalNotificationsPlugin
  //           .resolvePlatformSpecificImplementation()
  //           ?.areNotificationsEnabled();
  //       return result ?? false;
  //     } else if (defaultTargetPlatform == TargetPlatform.iOS) {
  //       final bool? result = await _flutterLocalNotificationsPlugin
  //           .resolvePlatformSpecificImplementation()
  //           ?.requestPermissions(
  //         alert: true,
  //         badge: true,
  //         sound: true,
  //       );
  //       return result ?? false;
  //     }
  //     return false;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // Request permissions
   requestPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        // final bool? granted = await androidImplementation?.requestPermission();
        // return granted ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

        final bool? granted = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      return false;
    } catch (e) {
      throw NotificationPermissionException(
        'فشل في طلب صلاحيات الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Get pending notifications
   getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      throw NotificationServiceException(
        'فشل في الحصول على الإشعارات المعلقة: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Helper methods
  String _getChannelName(String channelId) {
    switch (channelId) {
      case NotificationConstants.workoutChannelId:
        return NotificationConstants.workoutChannelName;
      case NotificationConstants.adminChannelId:
        return NotificationConstants.adminChannelName;
      case NotificationConstants.systemChannelId:
        return NotificationConstants.systemChannelName;
      default:
        return NotificationConstants.generalChannelName;
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case NotificationConstants.workoutChannelId:
        return NotificationConstants.workoutChannelDescription;
      case NotificationConstants.adminChannelId:
        return NotificationConstants.adminChannelDescription;
      case NotificationConstants.systemChannelId:
        return NotificationConstants.systemChannelDescription;
      default:
        return NotificationConstants.generalChannelDescription;
    }
  }

  Importance _getImportance(NotificationType type) {
    switch (type) {
      case NotificationType.workoutReminder:
      case NotificationType.subscriptionExpiry:
        return Importance.high;
      case NotificationType.system:
      case NotificationType.maintenance:
        return Importance.max;
      default:
        return Importance.defaultImportance;
    }
  }

  // Notification response handlers
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null && _onNotificationTap != null) {
      _onNotificationTap!(response.payload!);
    }
  }

  void _onDidReceiveLocalNotification(
      int id,
      String? title,
      String? body,
      String? payload,
      ) {
    if (payload != null && _onNotificationTap != null) {
      _onNotificationTap!(payload);
    }
  }
}
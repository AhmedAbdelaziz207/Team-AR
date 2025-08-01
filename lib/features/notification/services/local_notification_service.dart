import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../../../core/common/exceptions/notification_exceptions.dart';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_type_enum.dart';
import 'notification_storage.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final NotificationStorage _storage = NotificationStorage();

  bool _isInitialized = false;
  Function(String)? _onNotificationTap;

  // تهيئة الخدمة
  Future initialize({Function(String)? onNotificationTap}) async {
    if (_isInitialized) return;

    try {
      _onNotificationTap = onNotificationTap;

      tz.initializeTimeZones();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const settings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      await _createNotificationChannels();

      _isInitialized = true;
      debugPrint('LocalNotificationService initialized successfully');
    } catch (e) {
      throw NotificationServiceException(
        'فشل في تهيئة خدمة الإشعارات المحلية: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // إنشاء قنوات الإشعارات
  Future _createNotificationChannels() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final List<AndroidNotificationChannel> channels = [
        const AndroidNotificationChannel(
          'gym_general',
          'إشعارات عامة',
          description: 'الإشعارات العامة للتطبيق',
          importance: Importance.defaultImportance,
          enableVibration: true,
          enableLights: true,
        ),
        const AndroidNotificationChannel(
          'gym_workout',
          'تذكيرات التمرين',
          description: 'تذكيرات التمارين والأنشطة',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
        ),
        const AndroidNotificationChannel(
          'gym_subscription',
          'إشعارات الاشتراك',
          description: 'إشعارات انتهاء وتجديد الاشتراك',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
        ),
        const AndroidNotificationChannel(
          'gym_system',
          'إشعارات النظام',
          description: 'إشعارات مهمة من النظام',
          importance: Importance.max,
          enableVibration: true,
          enableLights: true,
        ),
      ];

      for (final channel in channels) {
        await androidPlugin.createNotificationChannel(channel);
      }
    }
  }

  String _getChannelIdForType(NotificationType type) {
    switch (type) {
      case NotificationType.workoutReminder:
        return 'gym_workout';
      case NotificationType.subscriptionExpiry:
        return 'gym_subscription';
      case NotificationType.system:
      case NotificationType.maintenance:
        return 'gym_system';
      default:
        return 'gym_general';
    }
  }

  // عرض إشعار فوري
  Future showNotification(NotificationModel notification) async {
    if (!_isInitialized) {
      throw const NotificationServiceException(
        'خدمة الإشعارات غير مهيئة',
        code: 'NOT_INITIALIZED',
      );
    }

    try {
      final existing = await _storage.getNotificationById(notification.id);
      if (existing == null) {
        await _storage.saveNotification(notification);
      }

      final int id = int.tryParse(notification.id) ??
          DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final channelId = _getChannelIdForType(notification.type);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: _getImportance(notification.type),
        priority: Priority.high,
        showWhen: true,
        when: notification.createdAt.millisecondsSinceEpoch,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        enableLights: true,
        ticker: notification.title,
        styleInformation: notification.body.length > 50
            ? BigTextStyleInformation(
          notification.body,
          contentTitle: notification.title,
          summaryText: 'إشعار جديد',
        )
            : null,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        notification.title,
        notification.body,
        platformDetails,
        payload: notification.payload ?? notification.id,
      );

      debugPrint("Local notification displayed: ${notification.id}");
    } catch (e) {
      throw NotificationServiceException(
        'فشل في عرض الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // جدولة إشعار
  Future scheduleNotification(NotificationModel notification, DateTime time) async {
    if (!_isInitialized) {
      throw const NotificationServiceException(
        'خدمة الإشعارات غير مهيئة',
        code: 'NOT_INITIALIZED',
      );
    }

    try {
      if (time.isBefore(DateTime.now())) {
        throw const NotificationServiceException(
          'لا يمكن جدولة إشعار في الماضي',
          code: 'INVALID_SCHEDULE_TIME',
        );
      }

      await _storage.saveNotification(notification.copyWith(scheduledAt: time));

      final int id = int.tryParse(notification.id) ??
          DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final channelId = _getChannelIdForType(notification.type);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: _getImportance(notification.type),
        priority: Priority.high,
        showWhen: true,
        when: time.millisecondsSinceEpoch,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        enableLights: true,
        ticker: notification.title,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        notification.title,
        notification.body,
        tz.TZDateTime.from(time, tz.local),
        platformDetails,
        payload: notification.payload ?? notification.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint("Notification scheduled for: $time");
    } catch (e) {
      throw NotificationSchedulingException(
        'فشل في جدولة الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future cancelNotification(String notificationId) async {
    try {
      final int id = int.tryParse(notificationId) ?? 0;
      await _flutterLocalNotificationsPlugin.cancel(id);
      debugPrint("Notification cancelled: $notificationId");
    } catch (e) {
      throw NotificationServiceException(
        'فشل في إلغاء الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint("All notifications cancelled");
    } catch (e) {
      throw NotificationServiceException(
        'فشل في إلغاء جميع الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<bool> requestPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Android لا يحتاج طلب إذن (حتى Android 12)
        // يمكن هنا تفصيل Android 13+ بشكل منفصل إن أردت (من SDK 33)
        return true;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        final granted = await ios?.requestPermissions(
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


  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      throw NotificationServiceException(
        'فشل في الحصول على الإشعارات المعلقة: ${e.toString()}',
        originalError: e,
      );
    }
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'gym_workout':
        return 'تذكيرات التمرين';
      case 'gym_subscription':
        return 'إشعارات الاشتراك';
      case 'gym_system':
        return 'إشعارات النظام';
      default:
        return 'إشعارات عامة';
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'gym_workout':
        return 'تذكيرات التمارين والأنشطة';
      case 'gym_subscription':
        return 'إشعارات انتهاء وتجديد الاشتراك';
      case 'gym_system':
        return 'إشعارات مهمة من النظام';
      default:
        return 'الإشعارات العامة للتطبيق';
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

  void _onDidReceiveNotificationResponse(NotificationResponse response) async {
    if (response.payload != null) {
      try {
        final notifications = await _storage.getNotifications();
        final index = notifications.indexWhere(
              (n) => n.payload == response.payload || n.id == response.payload,
        );

        if (index != -1 && !notifications[index].isRead) {
          await _storage.markAsRead(notifications[index].id);
        }

        if (_onNotificationTap != null) {
          _onNotificationTap!(response.payload!);
        }
      } catch (e) {
        debugPrint("Error handling notification tap: $e");
      }
    }
  }
}

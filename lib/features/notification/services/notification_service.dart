import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/common/exceptions/notification_exceptions.dart';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_settings_model.dart';
import '../../../core/common/notification_type_enum.dart';
import '../../../core/constants/notification_constants.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../core/utils/notification_validator.dart';
import 'local_notification_service.dart';
import 'notification_repository.dart';


class NotificationService {
  final LocalNotificationService _localNotificationService;
  final NotificationRepository _repository;

  // Stream controllers
  final StreamController _notificationStreamController =
  StreamController.broadcast();
  final StreamController _notificationActionStreamController =
  StreamController.broadcast();

  // Streams
  Stream get notificationStream => _notificationStreamController.stream;
  Stream get notificationActionStream => _notificationActionStreamController.stream;

  NotificationService({
    required LocalNotificationService localNotificationService,
    required NotificationRepository repository,
  })  : _localNotificationService = localNotificationService,
        _repository = repository;

  // Initialize service
  Future initialize() async {
    try {
      await _localNotificationService.initialize(
        onNotificationTap: _handleNotificationTap,
      );
    } catch (e) {
      throw NotificationServiceException(
        'فشل في تهيئة خدمة الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Send instant notification
  Future sendNotification(NotificationModel notification) async {
    try {
      NotificationValidator.validateNotification(notification);

      // Check if notifications are enabled
      final settings = await _repository.getNotificationSettings();
      if (!settings.enableNotifications) {
        if (kDebugMode) {
          print('الإشعارات معطلة، لن يتم إرسال الإشعار');
        }
        return;
      }

      // Check if specific notification type is enabled
      if (!NotificationHelper.shouldShowNotification(
        type: notification.type,
        enableNotifications: settings.enableNotifications,
        enableWorkoutReminders: settings.enableWorkoutReminders,
        enableMotivationalMessages: settings.enableMotivationalMessages,
        enablePromotions: settings.enablePromotions,
        enableSystemNotifications: settings.enableSystemNotifications,
      )) {
        if (kDebugMode) {
          print('نوع الإشعار ${notification.type} معطل، لن يتم إرسال الإشعار');
        }
        return;
      }

      // Save to repository
      await _repository.saveNotification(notification);

      // Show local notification
      await _localNotificationService.showNotification(notification);

      // Emit to stream
      _notificationStreamController.add(notification);

      if (kDebugMode) {
        print('تم إرسال الإشعار بنجاح: ${notification.title}');
      }
    } catch (e) {
      throw NotificationServiceException(
        'فشل في إرسال الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required NotificationModel notification,
    required DateTime scheduledTime,
  }) async {
    try {
      NotificationValidator.validateNotification(notification);
      NotificationValidator.validateScheduleTime(scheduledTime);

      final scheduledNotification = notification.copyWith(
        scheduledAt: scheduledTime,
      );

      // Save to repository
      await _repository.saveNotification(scheduledNotification);

      // Schedule local notification
      await _localNotificationService.scheduleNotification(
        scheduledNotification,
        scheduledTime,
      );

      if (kDebugMode) {
        print('تم جدولة الإشعار بنجاح: ${notification.title} في ${scheduledTime.toString()}');
      }
    } catch (e) {
      throw NotificationSchedulingException(
        'فشل في جدولة الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Schedule workout reminder
  Future scheduleWorkoutReminder({
    required String workoutName,
    required DateTime workoutTime,
    int reminderMinutesBefore = 30,
  }) async {
    try {
      final reminderTime = workoutTime.subtract(Duration(minutes: reminderMinutesBefore));

      final notification = NotificationHelper.createWorkoutReminder(
        title: 'تذكير: موعد التمرين',
        body: 'تمرين $workoutName يبدأ خلال $reminderMinutesBefore دقيقة',
        scheduledAt: reminderTime,
        customData: {
          'workout_name': workoutName,
          'workout_time': workoutTime.toIso8601String(),
          'reminder_minutes_before': reminderMinutesBefore,
        },
      );

      await scheduleNotification(
        notification: notification,
        scheduledTime: reminderTime,
      );
    } catch (e) {
      print (e.toString());
      throw NotificationSchedulingException(
        'فشل في جدولة تذكير التمرين: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Schedule daily motivational notifications
  Future scheduleDailyMotivationalNotifications({
    required int hour,
    required int minute,
    required List weekDays,
  }) async {
    try {
      final settings = await _repository.getNotificationSettings();
      if (!settings.enableMotivationalMessages) {
        if (kDebugMode) {
          print('الرسائل التحفيزية معطلة');
        }
        return;
      }

      // Cancel existing motivational notifications
      await _localNotificationService.cancelNotification(
        NotificationConstants.motivationalId.toString(),
      );

      // Schedule new motivational notifications
      for (int i = 0; i < 7; i++) {
        final now = DateTime.now();
        final targetDate = now.add(Duration(days: i));

        if (weekDays.contains(targetDate.weekday % 7)) {
          final scheduledTime = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
            hour,
            minute,
          );

          if (scheduledTime.isAfter(now)) {
            final notification = NotificationHelper.createMotivationalNotification(
              customData: {
                'scheduled_for': scheduledTime.toIso8601String(),
                'day_of_week': targetDate.weekday,
              },
            );

            await scheduleNotification(
              notification: notification,
              scheduledTime: scheduledTime,
            );
          }
        }
      }
    } catch (e) {
      throw NotificationSchedulingException(
        'فشل في جدولة الرسائل التحفيزية: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Send subscription expiry notification
  Future sendSubscriptionExpiryNotification({
    required int daysLeft,
    required String subscriptionType,
  }) async {
    try {
      final notification = NotificationHelper.createSubscriptionExpiryNotification(
        daysLeft: daysLeft,
        customData: {
          'subscription_type': subscriptionType,
          'days_left': daysLeft,
          'expiry_date': DateTime.now().add(Duration(days: daysLeft)).toIso8601String(),
        },
      );

      await sendNotification(notification);
    } catch (e) {
      throw NotificationServiceException(
        'فشل في إرسال إشعار انتهاء الاشتراك: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Send admin notification
  Future sendAdminNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map? customData,
  }) async {
    try {
      if (!type.isAdminNotification) {
        throw const NotificationValidationException(
          'نوع الإشعار المحدد ليس من إشعارات الإدارة',
        );
      }

      final notification = NotificationHelper.createAdminNotification(
        title: title,
        body: body,
        type: type,
        customData: customData,
      );

      await sendNotification(notification);
    } catch (e) {
      throw NotificationServiceException(
        'فشل في إرسال إشعار الإدارة: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Cancel notification
  Future cancelNotification(String notificationId) async {
    try {
      await _localNotificationService.cancelNotification(notificationId);
      await _repository.deleteNotification(notificationId);

      if (kDebugMode) {
        print('تم إلغاء الإشعار: $notificationId');
      }
    } catch (e) {
      throw NotificationServiceException(
        'فشل في إلغاء الإشعار: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Cancel all notifications
  Future cancelAllNotifications() async {
    try {
      await _localNotificationService.cancelAllNotifications();
      await _repository.clearAllNotifications();

      if (kDebugMode) {
        print('تم إلغاء جميع الإشعارات');
      }
    } catch (e) {
      throw NotificationServiceException(
        'فشل في إلغاء جميع الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Check permissions
  // Future checkPermissions() async {
  //   try {
  //     return await _localNotificationService.areNotificationsEnabled();
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // Request permissions
  Future requestPermissions() async {
    try {
      return await _localNotificationService.requestPermissions();
    } catch (e) {
      throw NotificationPermissionException(
        'فشل في طلب صلاحيات الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Get pending notifications
  Future getPendingNotificationsCount() async {
    try {
      final pendingNotifications = await _localNotificationService.getPendingNotifications();
      return pendingNotifications.length;
    } catch (e) {
      return 0;
    }
  }

  // Handle notification tap
  void _handleNotificationTap(String payload) {
    try {
      _notificationActionStreamController.add(payload);

      if (kDebugMode) {
        print('تم النقر على الإشعار: $payload');
      }
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في معالجة النقر على الإشعار: ${e.toString()}');
      }
    }
  }

  // Update notification settings
  Future updateNotificationSettings(NotificationSettingsModel settings) async {
    try {
      await _repository.saveNotificationSettings(settings);

      // Reschedule notifications based on new settings
      if (settings.enableWorkoutReminders) {
        await _rescheduleWorkoutReminders(settings);
      }

      if (settings.enableMotivationalMessages) {
        await _rescheduleMotivationalMessages(settings);
      }

      if (kDebugMode) {
        print('تم تحديث إعدادات الإشعارات');
      }
    } catch (e) {
      throw NotificationServiceException(
        'فشل في تحديث إعدادات الإشعارات: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Reschedule workout reminders
  Future _rescheduleWorkoutReminders(NotificationSettingsModel settings) async {
    try {
      // Cancel existing workout reminders
      await _localNotificationService.cancelNotification(
        NotificationConstants.workoutReminderId.toString(),
      );

      // Schedule new workout reminders based on settings
      await scheduleDailyMotivationalNotifications(
        hour: int.parse(settings.preferredTime.split(':')[0]),
        minute: int.parse(settings.preferredTime.split(':')[1]),
        weekDays: settings.reminderDays,
      );
    } catch (e) {
      if (kDebugMode) {
        print('فشل في إعادة جدولة تذكيرات التمرين: ${e.toString()}');
      }
    }
  }

  // Reschedule motivational messages
  Future _rescheduleMotivationalMessages(NotificationSettingsModel settings) async {
    try {
      // Cancel existing motivational messages
      await _localNotificationService.cancelNotification(
        NotificationConstants.motivationalId.toString(),
      );

      // Schedule new motivational messages based on settings
      await scheduleDailyMotivationalNotifications(
        hour: int.parse(settings.preferredTime.split(':')[0]),
        minute: int.parse(settings.preferredTime.split(':')[1]),
        weekDays: settings.reminderDays,
      );
    } catch (e) {
      if (kDebugMode) {
        print('فشل في إعادة جدولة الرسائل التحفيزية: ${e.toString()}');
      }
    }
  }

  // Dispose
  void dispose() {
    _notificationStreamController.close();
    _notificationActionStreamController.close();
  }
}
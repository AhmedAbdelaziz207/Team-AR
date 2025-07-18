import 'package:flutter/material.dart';

class NotificationConstants {
  // Channel IDs
  static const String workoutChannelId = 'workout_notifications';
  static const String generalChannelId = 'general_notifications';
  static const String adminChannelId = 'admin_notifications';
  static const String systemChannelId = 'system_notifications';

  // Limits
  static const int maxStoredNotifications = 100;
  static const int defaultOldNotificationDays = 30;

  // Channel Names
  static const String workoutChannelName = 'إشعارات التمرين';
  static const String generalChannelName = 'إشعارات عامة';
  static const String adminChannelName = 'إشعارات الإدارة';
  static const String systemChannelName = 'إشعارات النظام';

  // Channel Descriptions
  static const String workoutChannelDescription = 'إشعارات مواعيد التمرين والتذكيرات';
  static const String generalChannelDescription = 'إشعارات عامة للتطبيق';
  static const String adminChannelDescription = 'إشعارات خاصة بالإدارة';
  static const String systemChannelDescription = 'إشعارات النظام والصيانة';

  // Notification IDs
  static const int workoutReminderId = 1000;
  static const int motivationalId = 2000;
  static const int subscriptionExpiryId = 3000;
  static const int systemMaintenanceId = 4000;

  // Default Values
  static const Duration defaultNotificationTimeout = Duration(seconds: 5);
  static const int maxNotificationsInStorage = 100;
  static const int defaultReminderHour = 9;
  static const int defaultReminderMinute = 0;

  // Storage Keys
  static const String notificationStorageKey = 'gym_notifications';
  static const String notificationSettingsKey = 'notification_settings';
  static const String lastNotificationIdKey = 'last_notification_id';

  // Action IDs
  static const String acceptActionId = 'accept_action';
  static const String declineActionId = 'decline_action';
  static const String viewActionId = 'view_action';
  static const String snoozeActionId = 'snooze_action';

  // Motivational Messages
  static const List motivationalMessages = [
    'حان وقت التمرين! 💪',
    'اليوم هو يوم رائع للتمرين! 🌟',
    'قوتك تنمو مع كل تمرين! 🔥',
    'لا تستسلم، أنت أقوى مما تتخيل! ⚡',
    'كل خطوة تقربك من هدفك! 🎯',
    'التمرين اليوم يعني صحة أفضل غداً! 🏃‍♂️',
    'اجعل اليوم مميزاً بتمرين رائع! ✨',
    'قوة الإرادة تبدأ بخطوة واحدة! 🚀',
    'تمرينك المفضل ينتظرك! 🎵',
    'استثمر في صحتك اليوم! 💎',
  ];

  // Workout Reminders
  static const List workoutReminders = [
    'تذكير: موعد تمرينك خلال ساعة',
    'لا تنس تمرين اليوم!',
    'حان وقت الذهاب للجيم',
    'تمرينك المجدول يبدأ قريباً',
    'استعد لتمرين رائع!',
  ];

  // Error Messages
  static const String permissionDeniedMessage = 'يرجى السماح بالإشعارات من إعدادات التطبيق';
  static const String schedulingFailedMessage = 'فشل في جدولة الإشعار';
  static const String storageErrorMessage = 'خطأ في حفظ الإشعار';
  static const String networkErrorMessage = 'خطأ في الاتصال بالشبكة';
  static const String validationErrorMessage = 'بيانات الإشعار غير صحيحة';

  // Success Messages
  static const String notificationScheduledMessage = 'تم جدولة الإشعار بنجاح';
  static const String notificationSentMessage = 'تم إرسال الإشعار بنجاح';
  static const String settingsUpdatedMessage = 'تم تحديث إعدادات الإشعارات';

  // Colors
  static const Color workoutNotificationColor = Color(0xFF4CAF50);
  static const Color generalNotificationColor = Color(0xFF2196F3);
  static const Color adminNotificationColor = Color(0xFFFF9800);
  static const Color systemNotificationColor = Color(0xFF9C27B0);
  static const Color errorNotificationColor = Color(0xFFF44336);

  // Icons
  static const String workoutIcon = 'assets/icons/workout.png';
  static const String generalIcon = 'assets/icons/notification.png';
  static const String adminIcon = 'assets/icons/admin.png';
  static const String systemIcon = 'assets/icons/system.png';

  // Sounds
  static const String workoutSound = 'workout_notification.mp3';
  static const String generalSound = 'general_notification.mp3';
  static const String adminSound = 'admin_notification.mp3';
  static const String systemSound = 'system_notification.mp3';
}
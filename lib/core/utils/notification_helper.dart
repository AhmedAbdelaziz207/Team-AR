import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../common/notification_model.dart';
import '../common/notification_type_enum.dart';
import '../constants/notification_constants.dart';

class NotificationHelper {
  static const _uuid = Uuid();
  static final _random = Random();

  // Generate unique notification ID
  static String generateId() => _uuid.v4();

  // Generate unique integer ID for local notifications
  static int generateIntId() => _random.nextInt(1000000);

  // Get channel ID based on notification type
  static String getChannelId(NotificationType type) {
    switch (type) {
      case NotificationType.workoutReminder:
      case NotificationType.workoutPlan:
        return NotificationConstants.workoutChannelId;
      case NotificationType.newMember:
      case NotificationType.bookingRequest:
      case NotificationType.newReview:
      case NotificationType.technicalIssue:
        return NotificationConstants.adminChannelId;
      case NotificationType.system:
      case NotificationType.maintenance:
        return NotificationConstants.systemChannelId;
      default:
        return NotificationConstants.generalChannelId;
    }
  }

  // Get notification color based on type
  static Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.workoutReminder:
      case NotificationType.workoutPlan:
        return NotificationConstants.workoutNotificationColor;
      case NotificationType.newMember:
      case NotificationType.bookingRequest:
      case NotificationType.newReview:
      case NotificationType.technicalIssue:
        return NotificationConstants.adminNotificationColor;
      case NotificationType.system:
      case NotificationType.maintenance:
        return NotificationConstants.systemNotificationColor;
      default:
        return NotificationConstants.generalNotificationColor;
    }
  }

  // Format notification time
  static String formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  // Create workout reminder notification
  static NotificationModel createWorkoutReminder({
    required String title,
    required String body,
    DateTime? scheduledAt,
    Map<String, dynamic>? customData,
  }) {
    return NotificationModel(
      id: generateId(),
      title: title,
      body: body,
      type: NotificationType.workoutReminder,
      createdAt: DateTime.now(),
      scheduledAt: scheduledAt,
      customData: customData,
    );
  }

  // Create motivational notification
  static NotificationModel createMotivationalNotification({
    String? customMessage,
    Map<String, dynamic>? customData,
  }) {
    final message = customMessage ??
        NotificationConstants.motivationalMessages[
        _random.nextInt(NotificationConstants.motivationalMessages.length)
        ];

    return NotificationModel(
      id: generateId(),
      title: 'رسالة تحفيزية',
      body: message,
      type: NotificationType.motivational,
      createdAt: DateTime.now(),
      customData: customData,
    );
  }

  // Create subscription expiry notification
  static NotificationModel createSubscriptionExpiryNotification({
    required int daysLeft,
    Map<String, dynamic>? customData,
  }) {
    String title;
    String body;

    if (daysLeft <= 0) {
      title = 'انتهى اشتراكك';
      body = 'اشتراكك في الجيم انتهى. جدد الآن للاستمرار!';
    } else if (daysLeft == 1) {
      title = 'ينتهي اشتراكك غداً';
      body = 'اشتراكك في الجيم ينتهي غداً. جدد الآن!';
    } else {
      title = 'تذكير: انتهاء الاشتراك';
      body = 'ينتهي اشتراكك خلال $daysLeft أيام. جدد الآن!';
    }

    return NotificationModel(
      id: generateId(),
      title: title,
      body: body,
      type: NotificationType.subscriptionExpiry,
      createdAt: DateTime.now(),
      customData: customData,
    );
  }

  // Create admin notification
  static NotificationModel createAdminNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? customData,
  }) {
    return NotificationModel(
      id: generateId(),
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      customData: customData,
    );
  }

  // Calculate next reminder time
  static DateTime calculateNextReminderTime({
    required int hour,
    required int minute,
    required List reminderDays,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, hour, minute);

    // If today's time hasn't passed and today is in reminder days
    if (today.isAfter(now) && reminderDays.contains(now.weekday % 7)) {
      return today;
    }

    // Find next reminder day
    for (int i = 1; i <= 7; i++) {
      final nextDay = now.add(Duration(days: i));
      if (reminderDays.contains(nextDay.weekday % 7)) {
        return DateTime(nextDay.year, nextDay.month, nextDay.day, hour, minute);
      }
    }

    // Fallback to tomorrow
    return DateTime(now.year, now.month, now.day + 1, hour, minute);
  }

  // Check if notification should be shown based on settings
  static bool shouldShowNotification({
    required NotificationType type,
    required bool enableNotifications,
    required bool enableWorkoutReminders,
    required bool enableMotivationalMessages,
    required bool enablePromotions,
    required bool enableSystemNotifications,
  }) {
    if (!enableNotifications) return false;

    switch (type) {
      case NotificationType.workoutReminder:
      case NotificationType.workoutPlan:
        return enableWorkoutReminders;
      case NotificationType.motivational:
        return enableMotivationalMessages;
      case NotificationType.promotion:
        return enablePromotions;
      case NotificationType.system:
      case NotificationType.maintenance:
        return enableSystemNotifications;
      default:
        return true;
    }
  }

  // Get notification icon based on type
  static String getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.workoutReminder:
      case NotificationType.workoutPlan:
        return NotificationConstants.workoutIcon;
      case NotificationType.newMember:
      case NotificationType.bookingRequest:
      case NotificationType.newReview:
      case NotificationType.technicalIssue:
        return NotificationConstants.adminIcon;
      case NotificationType.system:
      case NotificationType.maintenance:
        return NotificationConstants.systemIcon;
      default:
        return NotificationConstants.generalIcon;
    }
  }

  // Get notification sound based on type
  static String getNotificationSound(NotificationType type) {
    switch (type) {
      case NotificationType.workoutReminder:
      case NotificationType.workoutPlan:
        return NotificationConstants.workoutSound;
      case NotificationType.newMember:
      case NotificationType.bookingRequest:
      case NotificationType.newReview:
      case NotificationType.technicalIssue:
        return NotificationConstants.adminSound;
      case NotificationType.system:
      case NotificationType.maintenance:
        return NotificationConstants.systemSound;
      default:
        return NotificationConstants.generalSound;
    }
  }

  // Parse notification payload
  static Map? parsePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    try {
      return Map.from(
          Uri.splitQueryString(payload)
      );
    } catch (e) {
      return null;
    }
  }

  // Create notification payload
  static String createPayload(Map data) {
    return Uri(queryParameters: data.map((key, value) => MapEntry(key, value.toString()))).query;
  }
}
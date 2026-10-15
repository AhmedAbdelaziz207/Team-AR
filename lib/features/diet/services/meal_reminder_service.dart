import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:team_ar/core/common/notification_model.dart';
import 'package:team_ar/core/common/notification_type_enum.dart';
import 'package:team_ar/core/utils/meal_time_defaults.dart';
import 'package:team_ar/features/notification/services/local_notification_service.dart';

class MealReminderService {
  final LocalNotificationService _localNotificationService;

  MealReminderService(this._localNotificationService);

  static int getNotificationId(int mealId) => 2000 + mealId;

  static String getMealTitle(int mealId) {
    switch (mealId) {
      case 1:
        return 'الوجبة الأولى 🍳';
      case 2:
        return 'الوجبة الثانية 🥪';
      case 3:
        return 'الوجبة الثالثة (الغداء) 🥗';
      case 4:
        return 'الوجبة الرابعة (سناك) 🍎';
      case 5:
        return 'الوجبة الخامسة (العشاء) 🍗';
      case 6:
        return 'وجبة ما قبل النوم 🥛';
      default:
        return 'وجبة اليوم 🍽️';
    }
  }

  /// فحص هل الوقت يقع ضمن ساعات الهدوء (Quiet Hours)
  bool _isInQuietHours(
    DateTime time, {
    String quietStart = '23:00',
    String quietEnd = '07:00',
  }) {
    final startParts = quietStart.split(':').map(int.parse).toList();
    final endParts = quietEnd.split(':').map(int.parse).toList();

    final startMinutes = startParts[0] * 60 + startParts[1];
    final endMinutes = endParts[0] * 60 + endParts[1];
    final currentMinutes = time.hour * 60 + time.minute;

    if (startMinutes > endMinutes) {
      // عبر منتصف الليل: مثلاً 23:00 إلى 07:00
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    } else {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
  }

  /// جدولة التذكيرات لجميع الوجبات غير المؤكدة
  Future<void> scheduleRemindersForDiet({
    required Set<int> presentMealIds,
    required Map<int, bool> todayDoneStatus,
    Map<int, TimeOfDay>? customTimes,
    bool remindersEnabled = true,
    String quietStart = '23:00',
    String quietEnd = '07:00',
  }) async {
    if (!remindersEnabled) {
      // إلغاء كل إشعارات الوجبات إذا كانت معطلة
      for (final mealId in presentMealIds) {
        await cancelReminder(mealId);
      }
      return;
    }

    final now = DateTime.now();

    for (final mealId in presentMealIds) {
      final isDone = todayDoneStatus[mealId] ?? false;

      // إذا كانت الوجبة مكتملة، نلغي التذكير
      if (isDone) {
        await cancelReminder(mealId);
        continue;
      }

      // تحديد وقت الوجبة
      final mealTimeOfDay =
          MealTimeDefaults.getTimeForMeal(mealId, customTimes);

      // موعد التذكير = وقت الوجبة + 60 دقيقة
      var reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        mealTimeOfDay.hour,
        mealTimeOfDay.minute,
      ).add(const Duration(minutes: 60));

      // إذا كان وقت اليوم قد مر بالفعل، لا نجدوله لليوم
      if (reminderDateTime.isBefore(now)) {
        continue;
      }

      // فحص ساعات الهدوء
      if (_isInQuietHours(reminderDateTime,
          quietStart: quietStart, quietEnd: quietEnd)) {
        log('MealReminderService: Meal $mealId falls in quiet hours ($reminderDateTime). Skipping.');
        continue;
      }

      final mealName = getMealTitle(mealId);
      final notifId = getNotificationId(mealId);

      final notif = NotificationModel(
        id: notifId.toString(),
        title: 'تذكير بالوجبة 🍽️',
        body: 'هل تناولت $mealName؟ لا تنسَ تسجيلها ومواصلة خطتك!',
        type: NotificationType.dietPlan,
        createdAt: now,
        scheduledAt: reminderDateTime,
        payload: 'meal_$mealId',
      );

      try {
        await _localNotificationService.scheduleNotification(
          notif,
          reminderDateTime,
        );
        log('MealReminderService: Scheduled reminder for meal $mealId at $reminderDateTime');
      } catch (e) {
        log('MealReminderService: Error scheduling meal $mealId: $e');
      }
    }
  }

  /// إلغاء تذكير وجبة معينة
  Future<void> cancelReminder(int mealId) async {
    try {
      final notifId = getNotificationId(mealId);
      await _localNotificationService.cancelNotification(notifId.toString());
      log('MealReminderService: Cancelled reminder for meal $mealId');
    } catch (e) {
      log('MealReminderService: Error cancelling reminder for meal $mealId: $e');
    }
  }
}

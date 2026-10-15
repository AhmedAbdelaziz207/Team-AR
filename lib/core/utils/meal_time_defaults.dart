import 'package:flutter/material.dart';

class MealTimeDefaults {
  /// الأوقات الافتراضية مبنية على منطق تغذوي منطقي
  static const Map<int, TimeOfDay> defaultTimes = {
    1: TimeOfDay(hour: 8, minute: 0),   // الفطار
    2: TimeOfDay(hour: 11, minute: 0),  // وجبة منتصف النهار
    3: TimeOfDay(hour: 14, minute: 0),  // الغداء
    4: TimeOfDay(hour: 17, minute: 0),  // سناك مسائي
    5: TimeOfDay(hour: 20, minute: 0),  // العشاء
    6: TimeOfDay(hour: 22, minute: 0),  // ما قبل النوم
  };

  /// يجمع إعداد المستخدم مع الافتراضي
  /// الأولوية: إعداد المستخدم > الافتراضي > 12:00 ظهرًا
  static TimeOfDay getTimeForMeal(
      int foodType, Map<int, TimeOfDay>? userSettings) {
    return userSettings?[foodType] ??
        defaultTimes[foodType] ??
        const TimeOfDay(hour: 12, minute: 0);
  }

  /// تحويل TimeOfDay إلى نص للتخزين في JSONB
  static String timeToString(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// تحويل نص JSONB إلى TimeOfDay
  static TimeOfDay? timeFromString(String? s) {
    if (s == null || s.isEmpty) return null;
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// تحقق من ساعات الهدوء (لا إشعارات بين 23:00 و 07:00)
  static bool isQuietHour(DateTime dt) {
    final hour = dt.hour;
    return hour >= 23 || hour < 7;
  }

  /// هل الإشعار مسموح به الآن؟
  static bool canSendReminder(DateTime scheduledTime) {
    return !isQuietHour(scheduledTime);
  }
}

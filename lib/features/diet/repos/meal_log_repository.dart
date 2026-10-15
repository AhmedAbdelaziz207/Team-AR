import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealLogRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _getTodayString() => DateTime.now().toIso8601String().split('T').first;

  String _cacheKey(String userId) => 'cached_meal_logs_${userId}_${_getTodayString()}';
  String _settingsCacheKey(String userId) => 'cached_reminder_settings_$userId';

  // ─── جلب سجل وجبات اليوم ────────────────────────────────────
  Future<Map<int, bool>> getTodayMealLogs(String userId) async {
    final today = _getTodayString();
    final prefs = await SharedPreferences.getInstance();

    // 1. فحص الكاش أولاً للاستجابة الفورية
    final cached = prefs.getString(_cacheKey(userId));
    Map<int, bool> result = {};
    if (cached != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cached);
        result = decoded.map((k, v) => MapEntry(int.parse(k), v as bool));
      } catch (_) {}
    }

    // 2. مزامنة من Supabase
    try {
      final res = await _supabase
          .from('meal_logs')
          .select()
          .eq('user_id', userId)
          .eq('date', today);

      final fresh = <int, bool>{};
      for (final row in res as List) {
        final mealId = (row['meal_id'] as num).toInt();
        final completed = row['completed'] as bool? ?? false;
        fresh[mealId] = completed;
      }

      // تحديث الكاش
      await prefs.setString(
        _cacheKey(userId),
        jsonEncode(fresh.map((k, v) => MapEntry(k.toString(), v))),
      );

      return fresh;
    } catch (e) {
      log('MealLogRepository.getTodayMealLogs error: $e');
      return result; // ارجع الكاش عند انقطاع الاتصال
    }
  }

  // ─── تبديل حالة الوجبة (Done / Undo) ──────────────────────────
  Future<bool> toggleMealDone({
    required String userId,
    required int mealId,
    required bool completed,
  }) async {
    final today = _getTodayString();
    final prefs = await SharedPreferences.getInstance();

    // 1. تحديث الكاش المحلي فوراً (Optimistic UI)
    try {
      final cached = prefs.getString(_cacheKey(userId));
      final Map<String, dynamic> decoded =
          cached != null ? jsonDecode(cached) : {};
      decoded[mealId.toString()] = completed;
      await prefs.setString(_cacheKey(userId), jsonEncode(decoded));
    } catch (_) {}

    // 2. تحديث Supabase
    try {
      await _supabase.from('meal_logs').upsert(
        {
          'user_id': userId,
          'meal_id': mealId,
          'date': today,
          'completed': completed,
          'completed_at': completed ? DateTime.now().toIso8601String() : null,
        },
        onConflict: 'user_id,meal_id,date',
      );
      log('MealLogRepository: Meal $mealId set to $completed for $userId');
      return true;
    } catch (e) {
      log('MealLogRepository.toggleMealDone error: $e');
      return false;
    }
  }

  // ─── إعدادات التذكيرات للمستخدم ──────────────────────────────
  Future<Map<String, dynamic>?> getReminderSettings(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final res = await _supabase
          .from('reminder_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (res != null) {
        await prefs.setString(_settingsCacheKey(userId), jsonEncode(res));
        return res;
      }
    } catch (e) {
      log('MealLogRepository.getReminderSettings error: $e');
    }

    final cached = prefs.getString(_settingsCacheKey(userId));
    if (cached != null) {
      try {
        return jsonDecode(cached) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  // ─── حفظ إعدادات التذكيرات ──────────────────────────────────
  Future<bool> saveReminderSettings({
    required String userId,
    required Map<int, String> mealReminders,
    bool enabled = true,
    String quietStart = '23:00',
    String quietEnd = '07:00',
  }) async {
    final data = {
      'user_id': userId,
      'meal_reminders': mealReminders.map((k, v) => MapEntry(k.toString(), v)),
      'quiet_hours_start': quietStart,
      'quiet_hours_end': quietEnd,
      'enabled': enabled,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsCacheKey(userId), jsonEncode(data));

    try {
      await _supabase.from('reminder_settings').upsert(
            data,
            onConflict: 'user_id',
          );
      return true;
    } catch (e) {
      log('MealLogRepository.saveReminderSettings error: $e');
      return false;
    }
  }

  // ─── نسبة الالتزام الأسبوعية (للمدرب والمتدرب) ────────────────
  Future<Map<int, int>> getWeeklyCompliance(String userId) async {
    try {
      final sevenDaysAgo = DateTime.now()
          .subtract(const Duration(days: 7))
          .toIso8601String()
          .split('T')
          .first;

      final res = await _supabase
          .from('meal_logs')
          .select('meal_id, completed')
          .eq('user_id', userId)
          .gte('date', sevenDaysAgo)
          .eq('completed', true);

      final Map<int, int> counts = {};
      for (final row in res as List) {
        final mealId = (row['meal_id'] as num).toInt();
        counts[mealId] = (counts[mealId] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      log('MealLogRepository.getWeeklyCompliance error: $e');
      return {};
    }
  }

  // ─── حساب سلسلة الأيام المتتالية (Streak) ─────────────────────
  Future<int> calculateStreak(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String()
          .split('T')
          .first;

      // هات كل الأيام التي كان فيها وجبة مكتملة أو جلسة تمرين
      final mealDaysRes = await _supabase
          .from('meal_logs')
          .select('date')
          .eq('user_id', userId)
          .gte('date', thirtyDaysAgo)
          .eq('completed', true);

      final workoutDaysRes = await _supabase
          .from('workout_sessions')
          .select('date')
          .eq('user_id', userId)
          .gte('date', thirtyDaysAgo);

      final Set<String> activeDates = {};
      for (final row in (mealDaysRes as List)) {
        activeDates.add(row['date'].toString());
      }
      for (final row in (workoutDaysRes as List)) {
        activeDates.add(row['date'].toString());
      }

      int streak = 0;
      var checkDate = DateTime.now();

      // إذا لم يسجل اليوم بعد، نبدأ الفحص من أمس
      final todayStr = checkDate.toIso8601String().split('T').first;
      if (!activeDates.contains(todayStr)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      while (true) {
        final dateStr = checkDate.toIso8601String().split('T').first;
        if (activeDates.contains(dateStr)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      log('MealLogRepository.calculateStreak error: $e');
      return 0;
    }
  }
}

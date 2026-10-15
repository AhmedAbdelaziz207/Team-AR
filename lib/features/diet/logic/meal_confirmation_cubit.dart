import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/diet/logic/meal_confirmation_state.dart';
import 'package:team_ar/features/diet/repos/meal_log_repository.dart';
import 'package:team_ar/features/diet/services/meal_reminder_service.dart';

class MealConfirmationCubit extends Cubit<MealConfirmationState> {
  final MealLogRepository _repo;
  final MealReminderService _reminderService;

  MealConfirmationCubit(this._repo, this._reminderService)
      : super(const MealConfirmationState());

  Future<String> _getUserId() async {
    return await SharedPreferencesHelper.getString(AppConstants.userId) ?? '';
  }

  // ─── تحميل بيانات اليوم + الإعدادات + الـ Streak ────────────
  Future<void> loadStatus({Set<int>? presentMealIds}) async {
    emit(state.copyWith(isLoading: true));
    final userId = await _getUserId();
    if (userId.isEmpty) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    try {
      final logsFuture = _repo.getTodayMealLogs(userId);
      final streakFuture = _repo.calculateStreak(userId);
      final settingsFuture = _repo.getReminderSettings(userId);

      final results = await Future.wait([logsFuture, streakFuture, settingsFuture]);

      final todayLogs = results[0] as Map<int, bool>;
      final streak = results[1] as int;
      final settings = results[2] as Map<String, dynamic>?;

      // قراءة مواعيد الوجبات المخصصة
      final Map<int, TimeOfDay> customTimes = {};
      bool remindersEnabled = true;
      String quietStart = '23:00';
      String quietEnd = '07:00';

      if (settings != null) {
        remindersEnabled = settings['enabled'] as bool? ?? true;
        quietStart = settings['quiet_hours_start'] as String? ?? '23:00';
        quietEnd = settings['quiet_hours_end'] as String? ?? '07:00';

        final mealReminders = settings['meal_reminders'] as Map<String, dynamic>? ?? {};
        mealReminders.forEach((key, val) {
          final mId = int.tryParse(key);
          if (mId != null && val is String) {
            final parts = val.split(':');
            if (parts.length == 2) {
              final h = int.tryParse(parts[0]);
              final m = int.tryParse(parts[1]);
              if (h != null && m != null) {
                customTimes[mId] = TimeOfDay(hour: h, minute: m);
              }
            }
          }
        });
      }

      emit(state.copyWith(
        todayLogs: todayLogs,
        streak: streak,
        customMealTimes: customTimes,
        remindersEnabled: remindersEnabled,
        quietHoursStart: quietStart,
        quietHoursEnd: quietEnd,
        isLoading: false,
      ));

      // جدولة التذكيرات إذا كانت الوجبات متوفرة
      if (presentMealIds != null && presentMealIds.isNotEmpty) {
        await _reminderService.scheduleRemindersForDiet(
          presentMealIds: presentMealIds,
          todayDoneStatus: todayLogs,
          customTimes: customTimes,
          remindersEnabled: remindersEnabled,
          quietStart: quietStart,
          quietEnd: quietEnd,
        );
      }
    } catch (e) {
      log('MealConfirmationCubit.loadStatus error: $e');
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  // ─── تبديل حالة الوجبة (Done / Undo) ──────────────────────────
  Future<void> toggleMeal(int mealId, {Set<int>? allMealIds}) async {
    final currentDone = state.isMealDone(mealId);
    final newDone = !currentDone;

    // 1. Optimistic Update في الـ UI
    final updatedLogs = Map<int, bool>.from(state.todayLogs);
    updatedLogs[mealId] = newDone;
    emit(state.copyWith(todayLogs: updatedLogs));

    // 2. تحديث التذكيرات
    if (newDone) {
      await _reminderService.cancelReminder(mealId);
    } else if (allMealIds != null) {
      await _reminderService.scheduleRemindersForDiet(
        presentMealIds: {mealId},
        todayDoneStatus: updatedLogs,
        customTimes: state.customMealTimes,
        remindersEnabled: state.remindersEnabled,
        quietStart: state.quietHoursStart,
        quietEnd: state.quietHoursEnd,
      );
    }

    // 3. الحفظ في Supabase
    final userId = await _getUserId();
    final success = await _repo.toggleMealDone(
      userId: userId,
      mealId: mealId,
      completed: newDone,
    );

    // إذا فشل الحفظ، نتراجع عن الحالة
    if (!success) {
      final revertedLogs = Map<int, bool>.from(state.todayLogs);
      revertedLogs[mealId] = currentDone;
      emit(state.copyWith(todayLogs: revertedLogs));
    } else {
      // إعادة حساب الـ streak في الخلفية
      _repo.calculateStreak(userId).then((newStreak) {
        if (!isClosed) {
          emit(state.copyWith(streak: newStreak));
        }
      });
    }
  }

  // ─── تعديل وقت وجبة ──────────────────────────────────────────
  Future<void> updateMealTime(
    int mealId,
    TimeOfDay newTime, {
    Set<int>? presentMealIds,
  }) async {
    final updated = Map<int, TimeOfDay>.from(state.customMealTimes);
    updated[mealId] = newTime;
    emit(state.copyWith(customMealTimes: updated));

    final userId = await _getUserId();
    final stringMap = <int, String>{};
    updated.forEach((k, v) {
      final hh = v.hour.toString().padLeft(2, '0');
      final mm = v.minute.toString().padLeft(2, '0');
      stringMap[k] = '$hh:$mm';
    });

    await _repo.saveReminderSettings(
      userId: userId,
      mealReminders: stringMap,
      enabled: state.remindersEnabled,
      quietStart: state.quietHoursStart,
      quietEnd: state.quietHoursEnd,
    );

    if (presentMealIds != null) {
      await _reminderService.scheduleRemindersForDiet(
        presentMealIds: presentMealIds,
        todayDoneStatus: state.todayLogs,
        customTimes: updated,
        remindersEnabled: state.remindersEnabled,
        quietStart: state.quietHoursStart,
        quietEnd: state.quietHoursEnd,
      );
    }
  }

  // ─── تفعيل/تعطيل التذكيرات ──────────────────────────────────
  Future<void> toggleReminders(
    bool enabled, {
    Set<int>? presentMealIds,
  }) async {
    emit(state.copyWith(remindersEnabled: enabled));
    final userId = await _getUserId();

    final stringMap = <int, String>{};
    state.customMealTimes.forEach((k, v) {
      final hh = v.hour.toString().padLeft(2, '0');
      final mm = v.minute.toString().padLeft(2, '0');
      stringMap[k] = '$hh:$mm';
    });

    await _repo.saveReminderSettings(
      userId: userId,
      mealReminders: stringMap,
      enabled: enabled,
      quietStart: state.quietHoursStart,
      quietEnd: state.quietHoursEnd,
    );

    if (presentMealIds != null) {
      await _reminderService.scheduleRemindersForDiet(
        presentMealIds: presentMealIds,
        todayDoneStatus: state.todayLogs,
        customTimes: state.customMealTimes,
        remindersEnabled: enabled,
        quietStart: state.quietHoursStart,
        quietEnd: state.quietHoursEnd,
      );
    }
  }
}

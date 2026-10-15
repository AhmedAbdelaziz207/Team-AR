import 'package:flutter/material.dart';

class MealConfirmationState {
  final Map<int, bool> todayLogs; // mealId -> completed
  final bool isLoading;
  final int streak;
  final Map<int, TimeOfDay> customMealTimes;
  final bool remindersEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;
  final String? errorMessage;

  const MealConfirmationState({
    this.todayLogs = const {},
    this.isLoading = false,
    this.streak = 0,
    this.customMealTimes = const {},
    this.remindersEnabled = true,
    this.quietHoursStart = '23:00',
    this.quietHoursEnd = '07:00',
    this.errorMessage,
  });

  bool isMealDone(int mealId) => todayLogs[mealId] ?? false;

  MealConfirmationState copyWith({
    Map<int, bool>? todayLogs,
    bool? isLoading,
    int? streak,
    Map<int, TimeOfDay>? customMealTimes,
    bool? remindersEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? errorMessage,
  }) {
    return MealConfirmationState(
      todayLogs: todayLogs ?? this.todayLogs,
      isLoading: isLoading ?? this.isLoading,
      streak: streak ?? this.streak,
      customMealTimes: customMealTimes ?? this.customMealTimes,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      errorMessage: errorMessage,
    );
  }
}

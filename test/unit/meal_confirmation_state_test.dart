import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/features/diet/logic/meal_confirmation_state.dart';

void main() {
  group('MealConfirmationState Tests', () {
    test('default state has empty logs and 0 streak', () {
      const state = MealConfirmationState();

      expect(state.todayLogs, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.streak, equals(0));
      expect(state.remindersEnabled, isTrue);
      expect(state.isMealDone(1), isFalse);
    });

    test('isMealDone returns true if meal completed', () {
      const state = MealConfirmationState(
        todayLogs: {1: true, 2: false},
      );

      expect(state.isMealDone(1), isTrue);
      expect(state.isMealDone(2), isFalse);
      expect(state.isMealDone(3), isFalse);
    });

    test('copyWith updates state correctly', () {
      const state = MealConfirmationState();
      final updated = state.copyWith(
        todayLogs: {1: true},
        streak: 5,
        remindersEnabled: false,
        customMealTimes: {1: const TimeOfDay(hour: 9, minute: 0)},
      );

      expect(updated.todayLogs[1], isTrue);
      expect(updated.streak, equals(5));
      expect(updated.remindersEnabled, isFalse);
      expect(updated.customMealTimes[1]?.hour, equals(9));
    });
  });
}

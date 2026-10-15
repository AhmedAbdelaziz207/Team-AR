import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/core/utils/meal_time_defaults.dart';

void main() {
  group('MealTimeDefaults Tests', () {
    test('defaultTimes contains 6 distinct meals', () {
      expect(MealTimeDefaults.defaultTimes.length, equals(6));
      expect(MealTimeDefaults.defaultTimes[1]?.hour, equals(8));
      expect(MealTimeDefaults.defaultTimes[3]?.hour, equals(14));
      expect(MealTimeDefaults.defaultTimes[6]?.hour, equals(22));
    });

    test('getTimeForMeal returns custom time if provided by user', () {
      final customTimes = {
        1: const TimeOfDay(hour: 9, minute: 30),
      };

      final time = MealTimeDefaults.getTimeForMeal(1, customTimes);
      expect(time.hour, equals(9));
      expect(time.minute, equals(30));
    });

    test('getTimeForMeal falls back to default if no user custom time exists', () {
      final time = MealTimeDefaults.getTimeForMeal(2, null);
      expect(time.hour, equals(11));
      expect(time.minute, equals(0));
    });

    test('getTimeForMeal returns fallback for unknown meal number', () {
      final time = MealTimeDefaults.getTimeForMeal(99, null);
      expect(time.hour, equals(12));
      expect(time.minute, equals(0));
    });
  });
}

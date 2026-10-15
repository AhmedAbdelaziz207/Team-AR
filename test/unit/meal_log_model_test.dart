import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/features/diet/model/meal_log.dart';

void main() {
  group('MealLog Model Tests', () {
    test('MealLog fromJson and toJson serialization', () {
      final json = {
        'id': 'meal-log-789',
        'user_id': 'user-123',
        'meal_id': 1,
        'date': '2026-10-05',
        'completed': true,
        'completed_at': '2026-10-05T08:30:00.000Z',
      };

      final mealLog = MealLog.fromJson(json);

      expect(mealLog.id, equals('meal-log-789'));
      expect(mealLog.userId, equals('user-123'));
      expect(mealLog.mealId, equals(1));
      expect(mealLog.date, equals('2026-10-05'));
      expect(mealLog.completed, isTrue);
      expect(mealLog.completedAt, isNotNull);

      final serialized = mealLog.toJson();
      expect(serialized['user_id'], equals('user-123'));
      expect(serialized['meal_id'], equals(1));
      expect(serialized['completed'], isTrue);
      expect(serialized['date'], equals('2026-10-05'));
    });
  });
}

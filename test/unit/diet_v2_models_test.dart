import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/features/diet_v2/models/diet_plan_model.dart';
import 'package:team_ar/features/diet_v2/models/meal_ingredient_model.dart';
import 'package:team_ar/features/diet_v2/models/meal_model.dart';
import 'package:team_ar/features/diet_v2/models/trainee_meal_log_model.dart';

void main() {
  group('Diet V2 Models Tests', () {
    test('MealIngredientModel serialization and quantity/calories', () {
      final json = {
        'id': 'ing_1',
        'meal_id': 'm_1',
        'name': 'صدور دجاج مشوية',
        'quantity_unit': '150 جم',
        'calories': 247.5,
      };

      final ing = MealIngredientModel.fromJson(json);

      expect(ing.id, 'ing_1');
      expect(ing.name, 'صدور دجاج مشوية');
      expect(ing.quantityUnit, '150 جم');
      expect(ing.calories, 247.5);

      final serialized = ing.toJson();
      expect(serialized['name'], 'صدور دجاج مشوية');
      expect(serialized['quantity_unit'], '150 جم');
    });

    test('MealModel serialization with ingredients calculation', () {
      final json = {
        'id': 'meal_1',
        'diet_plan_id': 'dp_1',
        'meal_type': 'lunch',
        'total_calories': 650.0,
        'total_protein': 55.0,
        'total_carbs': 70.0,
        'total_fats': 15.0,
      };

      final meal = MealModel.fromJson(json, ingredients: [
        const MealIngredientModel(
          id: 'ing_1',
          mealId: 'meal_1',
          name: 'أرز بسمتي مسلوق',
          quantityUnit: '200 جم',
          calories: 260.0,
        )
      ]);

      expect(meal.id, 'meal_1');
      expect(meal.mealType, 'lunch');
      expect(meal.totalCalories, 650.0);
      expect(meal.ingredients.length, 1);
      expect(meal.ingredients.first.name, 'أرز بسمتي مسلوق');
    });

    test('DietPlanModel daily target macros serialization', () {
      final json = {
        'id': 'dp_1',
        'trainee_id': 'user_123',
        'coach_id': 'coach_77',
        'plan_type': 'Moderate Carb Day',
        'target_calories': 2400.0,
        'target_protein': 180.0,
        'target_carbs': 250.0,
        'target_fats': 65.0,
        'water_target_liters': 4.0,
        'created_at': '2026-10-05T10:00:00.000Z',
      };

      final plan = DietPlanModel.fromJson(json);

      expect(plan.id, 'dp_1');
      expect(plan.targetCalories, 2400.0);
      expect(plan.targetProtein, 180.0);
      expect(plan.targetCarbs, 250.0);
      expect(plan.targetFats, 65.0);
      expect(plan.waterTargetLiters, 4.0);
    });

    test('TraineeMealLogModel toggle consumed state', () {
      final json = {
        'id': 'log_1',
        'trainee_id': 'user_123',
        'meal_id': 'meal_1',
        'logged_at': '2026-10-05T12:00:00.000Z',
        'is_consumed': true,
      };

      final log = TraineeMealLogModel.fromJson(json);

      expect(log.isConsumed, isTrue);
      expect(log.traineeId, 'user_123');

      final unconsumed = log.copyWith(isConsumed: false);
      expect(unconsumed.isConsumed, isFalse);
    });
  });
}

import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/diet_plan_model.dart';
import '../models/meal_ingredient_model.dart';
import '../models/meal_model.dart';

class DietRepositoryV2 {
  final SupabaseClient _supabase;

  DietRepositoryV2([SupabaseClient? client])
      : _supabase = client ?? Supabase.instance.client;

  /// جلب الخطة الغذائية النشطة للمتدرب مع الوجبات ومكوناتها وحالة استهلاك اليوم
  Future<DietPlanModel?> getDietPlanForTrainee(String traineeId) async {
    try {
      final planRes = await _supabase
          .from('diet_plans')
          .select()
          .eq('trainee_id', traineeId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (planRes == null) return null;

      final planId = planRes['id'] as String;

      // جلب الوجبات
      final mealsRes = await _supabase
          .from('meals')
          .select()
          .eq('diet_plan_id', planId);

      // جلب سجلات استهلاك اليوم للمتدرب
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      final logsRes = await _supabase
          .from('trainee_meal_logs')
          .select()
          .eq('trainee_id', traineeId)
          .gte('logged_at', todayStart)
          .lte('logged_at', todayEnd);

      final consumedMealIds = (logsRes as List)
          .where((l) => (l['is_consumed'] as bool?) == true)
          .map((l) => l['meal_id'] as String)
          .toSet();

      final List<MealModel> meals = [];
      for (final m in mealsRes as List) {
        final mealId = m['id'] as String;

        // جلب مكونات الوجبة
        final ingredientsRes = await _supabase
            .from('meal_ingredients')
            .select()
            .eq('meal_id', mealId);

        final ingredients = (ingredientsRes as List)
            .map((i) => MealIngredientModel.fromJson(i as Map<String, dynamic>))
            .toList();

        final isConsumed = consumedMealIds.contains(mealId);

        meals.add(MealModel.fromJson(
          m as Map<String, dynamic>,
          ingredients: ingredients,
          isConsumed: isConsumed,
        ));
      }

      return DietPlanModel.fromJson(planRes, meals: meals);
    } catch (e) {
      log('Error getting diet plan for trainee: $e');
      return null;
    }
  }

  /// تسجيل أو إلغاء استهلاك وجبة اليوم
  Future<bool> toggleMealConsumed({
    required String mealId,
    required String traineeId,
    required bool isConsumed,
  }) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      // فحص هل مسجلة مسبقاً اليوم
      final existing = await _supabase
          .from('trainee_meal_logs')
          .select()
          .eq('meal_id', mealId)
          .eq('trainee_id', traineeId)
          .gte('logged_at', todayStart)
          .lte('logged_at', todayEnd)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('trainee_meal_logs')
            .update({'is_consumed': isConsumed})
            .eq('id', existing['id']);
      } else {
        await _supabase.from('trainee_meal_logs').insert({
          'meal_id': mealId,
          'trainee_id': traineeId,
          'is_consumed': isConsumed,
          'logged_at': now.toIso8601String(),
        });
      }

      return true;
    } catch (e) {
      log('Error toggling meal consumed: $e');
      return false;
    }
  }

  /// إنشاء خطة غذائية جديدة من المدرب
  Future<String?> createDietPlan(DietPlanModel plan) async {
    try {
      final res = await _supabase
          .from('diet_plans')
          .insert(plan.toJson())
          .select('id')
          .single();

      return res['id'] as String?;
    } catch (e) {
      log('Error creating diet plan: $e');
      return null;
    }
  }

  /// إضافة وجبة مع مكوناتها
  Future<bool> addMealWithIngredients({
    required MealModel meal,
    required List<MealIngredientModel> ingredients,
  }) async {
    try {
      final mealRes = await _supabase
          .from('meals')
          .insert(meal.toJson())
          .select('id')
          .single();

      final mealId = mealRes['id'] as String;

      if (ingredients.isNotEmpty) {
        final ingredientsData = ingredients.map((i) {
          final json = i.toJson();
          json['meal_id'] = mealId;
          return json;
        }).toList();

        await _supabase.from('meal_ingredients').insert(ingredientsData);
      }

      return true;
    } catch (e) {
      log('Error adding meal with ingredients: $e');
      return false;
    }
  }

  /// حذف خطة غذائية كاملة مع وجباتها ومكوناتها
  Future<bool> deleteDietPlan(String planId) async {
    try {
      // 1. جلب وجبات الخطة
      final mealsRes = await _supabase
          .from('meals')
          .select('id')
          .eq('diet_plan_id', planId);

      for (final m in (mealsRes as List)) {
        final mId = m['id'] as String;
        await _supabase.from('meal_ingredients').delete().eq('meal_id', mId);
        await _supabase.from('trainee_meal_logs').delete().eq('meal_id', mId);
      }

      await _supabase.from('meals').delete().eq('diet_plan_id', planId);
      await _supabase.from('diet_plans').delete().eq('id', planId);
      log('✅ [DietRepositoryV2] Diet plan deleted: $planId');
      return true;
    } catch (e) {
      log('❌ [DietRepositoryV2] Error deleting diet plan: $e');
      return false;
    }
  }

  /// حذف وجبة مفردة مع مكوناتها
  Future<bool> deleteMeal(String mealId) async {
    try {
      await _supabase.from('meal_ingredients').delete().eq('meal_id', mealId);
      await _supabase.from('trainee_meal_logs').delete().eq('meal_id', mealId);
      await _supabase.from('meals').delete().eq('id', mealId);
      log('✅ [DietRepositoryV2] Meal deleted: $mealId');
      return true;
    } catch (e) {
      log('❌ [DietRepositoryV2] Error deleting meal: $e');
      return false;
    }
  }

  /// حذف كافة الخطط الغذائية لمتدرب
  Future<bool> deleteDietPlanForTrainee(String traineeId) async {
    try {
      final plans = await _supabase
          .from('diet_plans')
          .select('id')
          .eq('trainee_id', traineeId);

      for (final p in (plans as List)) {
        await deleteDietPlan(p['id'] as String);
      }
      return true;
    } catch (e) {
      log('❌ [DietRepositoryV2] Error deleting all diets for trainee: $e');
      return false;
    }
  }
}

import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/diet_meals/model/diet_meal_model.dart';

import '../../../core/network/api_error_handler.dart';

class DietMealRepository {
  final ApiService _apiService;

  DietMealRepository(this._apiService);

  Future<ApiResult<List<DietMealModel>?>> getDietMeals() async {
    try {
      final List<DietMealModel>? dietMeals = await _apiService.getDietMeals();

      return ApiResult.success(dietMeals);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  /// Look for better way to handle this for image upload
  Future<ApiResult<DietMealModel>> addDietMeal(DietMealModel meal) async {
    try {
      final DietMealModel dietMeals = await _apiService.addDietMeal(meal.toJson());

      return ApiResult.success(dietMeals);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }


  Future<ApiResult<DietMealModel>> updateDietMeal(DietMealModel meal) async {
    try {
      final DietMealModel dietMeals = await _apiService.updateDietMeal(meal.toJson());

      return ApiResult.success(dietMeals);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }





}

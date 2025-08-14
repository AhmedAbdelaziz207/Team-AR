import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/network/dio_factory.dart';
import 'package:team_ar/features/select_meals/model/user_meal_request.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/api_error_model.dart';
import '../model/meal_model.dart';

class DietMealRepository {
  final ApiService _apiService;

  DietMealRepository(this._apiService);

  Future<ApiResult<List<DietMealModel>?>> getDietMeals() async {
    try {
      final response = await _apiService.getDietMeals();

      if (response == null) {
        return ApiResult.failure(ApiErrorModel(message: "Response is null"));
      }

      print("API Response: $response"); // Debugging line

      return ApiResult.success(response);
    } catch (e, stacktrace) {
      print("Error: $e\nStackTrace: $stacktrace"); // Debugging error
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  /// Look for better way to handle this for image upload
  Future<ApiResult<void>> addDietMeal({
    required DietMealModel diet,
    required File dietImage,
  }) async {
    try {
      final Dio dio = DioFactory.getDio();
  
      // التحقق من حجم الصورة
      final fileSize = await dietImage.length();
      if (fileSize > 5 * 1024 * 1024) { // أكبر من 5 ميجابايت
        return ApiResult.failure(ApiErrorModel(message: "حجم الصورة كبير جدًا، يجب أن يكون أقل من 5 ميجابايت"));
      }
  
      // Convert the diet model to a map
      Map<String, dynamic> dietData = diet.toJson();
  
      // Create FormData for file upload
      FormData formData = FormData.fromMap({
        ...dietData, // Spread the JSON data from the model
        "image": await MultipartFile.fromFile(
          dietImage.path,
          filename: dietImage.path.split('/').last,
        ),
      });
  
      await dio.post(
        ApiEndPoints.baseUrl + ApiEndPoints.dietMeals,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      log("Success");
  
      return const ApiResult.success(null);
    } catch (e) {
      log(e.toString());
      return ApiResult.failure(ApiErrorHandler.handle(e));
    } finally {
      // تنظيف الموارد
      if (dietImage.existsSync()) {
        // تنظيف الصورة المؤقتة إذا كانت في مجلد مؤقت
        if (dietImage.path.contains('temp') || dietImage.path.contains('cache')) {
          try {
            await dietImage.delete();
          } catch (e) {
            log("Error deleting temporary image: $e");
          }
        }
      }
    }
  }

  Future<ApiResult<void>> assignDietMealToTrainee(
    UserMealRequestModel userMeal, {
    bool isUpdate = false,
  }) async {
    try {
      if (isUpdate) {
        await _apiService.updateDietMealForUser(userMeal.toJson());
      } else {
        await _apiService.assignDietMealForUser(userMeal.toJson());
      }
      log("Success Assign Diet Meal");
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<DietMealModel>> updateDietMeal(DietMealModel meal) async {
    try {
      final DietMealModel dietMeals =
          await _apiService.updateDietMeal(meal.toJson());

      return ApiResult.success(dietMeals);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> deleteMeal(int id) async {
    try {
      await _apiService.deleteDietMeal(id);
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }
}

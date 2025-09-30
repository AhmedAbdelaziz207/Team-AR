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
      
      // Check if any meals have notes
      log("=== GET MEALS DEBUG ===");
      log("Total meals received: ${response.length}");
      for (var meal in response) {
        if (meal.note != null && meal.note!.isNotEmpty) {
          log("Meal '${meal.name}' has note: '${meal.note}'");
        }
        if (meal.foodCategory == 4) {
          log("Natural supplement '${meal.name}' note: '${meal.note ?? 'null'}'");
        }
      }

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
      final Dio dio = await DioFactory.getDio();

      // التحقق من حجم الصورة
      final fileSize = await dietImage.length();
      if (fileSize > 5 * 1024 * 1024) { // أكبر من 5 ميجابايت
        return ApiResult.failure(ApiErrorModel(message: "حجم الصورة كبير جدًا، يجب أن يكون أقل من 5 ميجابايت"));
      }

      // Build FormData with PascalCase keys expected by backend
      final formMap = <String, dynamic>{
        "Name": diet.name,
        "ArabicName": diet.arabicName,
        "NumOfCalories": diet.numOfCalories,
        "NumOfCarps": diet.numOfCarbs, // note: server key uses 'Carps'
        "NumOfFats": diet.numOfFats,
        "NumOfProtein": diet.numOfProtein,
        "NumOfGrams": diet.numOfGrams,
        "FoodCategory": diet.foodCategory,
        "Note": diet.note ?? "", // Add note field for usage instructions
        "Image": await MultipartFile.fromFile(
          dietImage.path,
          filename: dietImage.path.split('/').last,
        ),
      };

      log("=== REPOSITORY DEBUG ===");
      log("Diet note from model: '${diet.note}'");
      log("FormData Note value: '${formMap["Note"]}'");
      log("Food Category: ${diet.foodCategory}");
      log("FormData keys: ${formMap.keys.toList()}");

      // Create FormData for file upload
      FormData formData = FormData.fromMap(formMap);

      log("=== FORMDATA DEBUG ===");
      log("FormData fields:");
      for (var field in formData.fields) {
        log("  ${field.key}: ${field.value}");
      }

      log("API URL: ${ApiEndPoints.baseUrl + ApiEndPoints.dietMeals}");

      final response = await dio.post(
        ApiEndPoints.baseUrl + ApiEndPoints.dietMeals,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      log("=== API RESPONSE ===");
      log("Status Code: ${response.statusCode}");
      log("Response Data: ${response.data}");
      log("Success - Meal added successfully");

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

  Future<ApiResult<void>> updateDietMeal({
    required DietMealModel diet,
    required String imageUrl, // send the image URL instead of File
  }) async {
    try {
      final Dio dio = await DioFactory.getDio();

      final body = {
        "id": diet.id,
        "name": diet.name,
        "arabicName": diet.arabicName,
        "numOfCalories": diet.numOfCalories,
        "numOfProtein": diet.numOfProtein,
        "numOfFats": diet.numOfFats,
        "numOfCarps": diet.numOfCarbs,
        "foodCategory": diet.foodCategory,
        "imageURL": imageUrl,
      };

      await dio.put(
        ApiEndPoints.baseUrl + ApiEndPoints.dietMeals,
        data: body,
        options: Options(contentType: "application/json"),
      );

      log("Success");
      return const ApiResult.success(null);
    } catch (e) {
      log(e.toString());
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

  Future<ApiResult<void>> assignDietMealToTrainee(
    UserMealRequestModel request, {
    bool isUpdate = false,
  }) async {
    try {
      if (isUpdate) {
        await _apiService.updateUserDiet(request.toJson());
      } else {
        await _apiService.assignDietMealForUser(request.toJson());
      }
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> removeAllUserFoods(String userId) async {
    try {
      await _apiService.removeAllUserFoods(userId);
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }
}

import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:team_ar/core/network/dio_factory.dart';
import 'package:team_ar/features/workout_systems/model/workout_system_model.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/api_service.dart';

class WorkoutSystemRepository {
  final ApiService _apiService;

  WorkoutSystemRepository(this._apiService);

  Future<ApiResult<WorkoutSystemModel>> getWorkout(int id ) async {
    try {
      final data = await _apiService.getWorkout(id);
      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<WorkoutSystemModel>>> getWorkoutSystems() async {
    try {
      final data = await _apiService.getWorkoutSystems();
      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> uploadWorkoutSystemFile(
      WorkoutSystemModel workoutSystem, File workoutPdf) async {
    final dio = await DioFactory.getDio();

    FormData formData = FormData.fromMap({
      "Name": workoutSystem.name, // Explicit key the server expects
      "File": await MultipartFile.fromFile(
        workoutPdf.path,
        filename: workoutPdf.path.split('/').last,
      ),
    });

    try {
      await dio.post(
        ApiEndPoints.baseUrl + ApiEndPoints.exercise,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      log("Upload Workout Success");

      return const ApiResult.success(null);
    } catch (e) {
      log(e.toString());
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<bool>> deleteWorkoutSystem(int id) async {
    try {
      await _apiService.deleteWorkoutSystem(id);
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> addWorkoutForUser({
    required int workoutId,
    required String userId,
  }) async {
    try {
      await _apiService.addWorkoutForUser(workoutId, userId);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }
}

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/core/network/dio_factory.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/user_info/model/trainee_model.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_service.dart';

class TraineesRepository {
  final ApiService apiService;

  TraineesRepository(
    this.apiService,
  );

  Future<ApiResult<List<TraineeModel>>> getAllTrainees() async {
    try {
      log("getAllTrainees ${apiService.getAllTrainees()}");

      List<TraineeModel> trainees = await apiService.getAllTrainees();

      return ApiResult.success(trainees);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<TraineeModel>>> getNewTrainees() async {
    try {
      log("getAllTrainees ${apiService.getNewTrainees()}");

      List<TraineeModel> trainees = await apiService.getNewTrainees();

      return ApiResult.success(trainees);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<TraineeModel>>> getUsersAboutToExpired() async {
    try {
      log("getAllTrainees ${apiService.getUsersAboutToExpired()}");

      List<TraineeModel> trainees = await apiService.getUsersAboutToExpired();

      return ApiResult.success(trainees);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<TraineeModel>> getLoggedUser(String id) async {
    try {
      TraineeModel trainee = await apiService.getLoggedUserData(id);

      return ApiResult.success(trainee);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<TrainerModel>> getTrainer(String id) async {
    try {
      log("trainee Response:");
      final response = await apiService.getTrainer(id);
      log("trainee Response: ${response.userName}");

      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> updateUserImage(userImage, userId) async {
    final dio = await DioFactory.getDio();
    try {
      // Prepare FormData
      final formData = FormData.fromMap({
        'Image': await MultipartFile.fromFile(
          userImage.path,
          filename: userImage.path.split('/').last,
        ),
      });

      // Make the PUT request
      final response = await dio.put(
        ApiEndPoints.baseUrl + ApiEndPoints.updateUserImage,
        queryParameters: {'UserId': userId},
        data: formData,
      );

      log("updateUserImage Response: ");
      return const ApiResult.success(null);
    } catch (e) {
      log("updateUserImage Error: $e");
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }
}

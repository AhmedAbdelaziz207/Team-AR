import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/auth/register/model/register_response.dart';
import 'package:team_ar/features/auth/register/model/user_model.dart';
import 'package:team_ar/features/auth/register/model/register_admin_request.dart';

import '../../../../core/network/api_error_handler.dart';

class RegisterRepository {
  ApiService apiService;

  RegisterRepository(this.apiService);

  Future<ApiResult<RegisterResponse>> addTrainer(UserModel trainer) async {
    final data = FormData.fromMap(trainer.toJson());
    try {
      final response = await apiService.addTrainer(data);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<RegisterResponse>> addTrainerByAdmin(
    RegisterAdminRequest request,
  ) async {
    // Backend expects multipart/form-data
    try {
      final response = await apiService.addTrainerByAdmin(request.toJson());
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> updateUserPayment(String userId) async {
    try {
      final response = await apiService.updateUserPayment(userId);
      return ApiResult.success(response);
    } catch (e) {
      log("Upadte user payment failed");
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }
}

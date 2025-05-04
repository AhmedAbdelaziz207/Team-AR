import 'package:dio/dio.dart';
import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/auth/register/model/register_response.dart';
import 'package:team_ar/features/auth/register/model/user_model.dart';

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

}

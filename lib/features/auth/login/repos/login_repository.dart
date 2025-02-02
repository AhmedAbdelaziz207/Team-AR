import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/features/auth/login/model/login_request_body.dart';
import 'package:team_ar/features/auth/login/model/login_response.dart';

import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_service.dart';

class LoginRepository {
  final ApiService _apiService;

  LoginRepository(this._apiService);

  Future<ApiResult<LoginResponse>> login(LoginRequestBody loginRequestBody) async {
    try {
      final response = await _apiService.login(loginRequestBody.toJson());
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }
}

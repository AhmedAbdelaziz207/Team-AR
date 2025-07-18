import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/core/network/api_service.dart';

import '../../../core/network/api_error_handler.dart';
import '../model/user_plan.dart';

class UserPlansRepository {
  UserPlansRepository(
    this._apiService,
  );

  final ApiService _apiService;

  Future<ApiResult<List<UserPlan>>> getPlans() async {
    try {
      final List<UserPlan> plans = await _apiService.getPlans();
      return ApiResult.success(plans);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<UserPlan>> getPlan(id) async {
    try {
      final UserPlan plans = await _apiService.getPlan(id);
      return ApiResult.success(plans);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> addPlan(UserPlan body) async {
    try {
      await _apiService.addPlan(body.toJson());
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> updatePlan(UserPlan body) async {
    try {
      await _apiService.updatePlan(body.toJson());
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> deletePlan(int id) async {
    try {
      await _apiService.deletePlan(id);
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }
}

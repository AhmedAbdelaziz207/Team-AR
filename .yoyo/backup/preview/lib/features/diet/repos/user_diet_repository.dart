import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/diet/model/user_diet.dart';

import '../../../core/network/api_error_handler.dart';
import '../../../core/prefs/shared_pref_manager.dart';

class UserDietRepository {
  final ApiService _apiService;

  UserDietRepository(this._apiService);

  Future<ApiResult<List<UserDiet>>?> getUserDiet({String? id}) async {
    try {
      final String? userId =
          id ?? await SharedPreferencesHelper.getString(AppConstants.userId);

      final response = await _apiService.getLoggedUserDiet(userId ?? "");
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }
}

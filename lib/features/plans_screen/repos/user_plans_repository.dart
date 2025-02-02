
import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/core/network/api_service.dart';

import '../../../core/network/api_error_handler.dart';
import '../model/user_plan.dart';
class UserPlansRepository {
  UserPlansRepository(this._apiService,);
  final ApiService _apiService ;


 Future<ApiResult<List<UserPlan>>> getPlans() async{

   try {
     final List<UserPlan> plans = await _apiService.getPlans();
     return ApiResult.success(plans);
   } catch (e) {
     return ApiResult.failure(ApiErrorHandler.handle(e));
   }

  }



}
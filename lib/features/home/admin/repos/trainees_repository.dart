import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';

import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_service.dart';

class TraineesRepository {
  final ApiService apiService;

  TraineesRepository(this.apiService);

  Future<ApiResult<List<TraineeModel>>> getAllTrainees() async {
    try {
      List<TraineeModel> trainees = await  apiService.getAllTrainees();

      return ApiResult.success(trainees);
    } catch (e) {
      return ApiResult.failure(ApiErrorHandler.handle(e));
    }
  }
}

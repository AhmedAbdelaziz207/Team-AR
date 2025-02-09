import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:team_ar/features/auth/login/model/login_response.dart';
import '../../features/auth/register/model/register_response.dart';
import '../../features/home/admin/data/trainee_model.dart';
import '../../features/plans_screen/model/user_plan.dart';
import 'api_endpoints.dart';
part 'api_service.g.dart';

@RestApi(baseUrl: ApiEndPoints.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST(ApiEndPoints.login)
  Future<LoginResponse> login(
    @Body() Map<String, dynamic> body,
  );

  @GET(ApiEndPoints.plans)
  Future<List<UserPlan>> getPlans();

  @POST(ApiEndPoints.plans)
  Future<UserPlan> addPlan(@Body() Map<String, dynamic> body);

  @PUT(ApiEndPoints.plans)
  Future<UserPlan> updatePlan(@Body() Map<String, dynamic> body);


  @POST(ApiEndPoints.trainerData)
  Future<RegisterResponse> addTrainer(@Body() Map<String, dynamic> body);

  @GET(ApiEndPoints.getAllUsers)
  Future<List<TraineeModel>> getAllTrainees();

}

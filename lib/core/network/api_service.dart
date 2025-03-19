import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:team_ar/features/auth/login/model/login_response.dart';
import 'package:team_ar/features/diet_meals/model/diet_meal_model.dart';
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
  Future<void> updatePlan(@Body() Map<String, dynamic> body);

  @DELETE("${ApiEndPoints.plans}/{Id}")
  Future<UserPlan> deletePlan(@Path("Id") int id);

  @POST(ApiEndPoints.trainerData)
  Future<RegisterResponse> addTrainer(@Body() Map<String, dynamic> body);

  @GET(ApiEndPoints.getAllUsers)
  Future<List<TraineeModel>> getAllTrainees();

  @GET(ApiEndPoints.dietMeals)
  Future<List<DietMealModel>?> getDietMeals();

  @POST(ApiEndPoints.dietMeals)
  Future<DietMealModel> addDietMeal(@Body() Map<String, dynamic> body);

  @PUT(ApiEndPoints.dietMeals)
  Future<DietMealModel> updateDietMeal(@Body() Map<String, dynamic> body);

  @DELETE(ApiEndPoints.dietMeals)
  Future<UserPlan> deleteDietMeal(@Path("Id") int id);
}

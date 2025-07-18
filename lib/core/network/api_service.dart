import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:team_ar/features/auth/login/model/login_response.dart';
import 'package:team_ar/features/auth/register/model/user_model.dart';
import 'package:team_ar/features/diet/model/user_diet.dart';
import '../../features/auth/register/model/register_response.dart';
import '../../features/chat/model/chat_model.dart';
import '../../features/home/admin/data/trainee_model.dart';
import '../../features/manage_meals_screen/model/meal_model.dart';
import '../../features/plans_screen/model/user_plan.dart';
import '../../features/user_info/model/trainee_model.dart';
import '../../features/workout_systems/model/workout_system_model.dart';
import 'api_endpoints.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ApiEndPoints.baseUrl)
abstract class ApiService {
  factory ApiService(
    Dio dio, {
    String baseUrl,
  }) = _ApiService;

  @POST(ApiEndPoints.login)
  Future<LoginResponse> login(
    @Body() Map<String, dynamic> body,
  );

  @GET(ApiEndPoints.plans)
  Future<List<UserPlan>> getPlans();

  @GET("${ApiEndPoints.plans}/{Id}")
  Future<UserPlan> getPlan(@Path("Id") int id);

  @POST(ApiEndPoints.plans)
  Future<UserPlan> addPlan(@Body() Map<String, dynamic> body);

  @PUT(ApiEndPoints.plans)
  Future<void> updatePlan(@Body() Map<String, dynamic> body);

  @DELETE("${ApiEndPoints.plans}/{Id}")
  Future<UserPlan> deletePlan(@Path("Id") int id);

  @POST(ApiEndPoints.trainerData)
  Future<RegisterResponse> addTrainer(@Body() FormData body);

  @GET(ApiEndPoints.trainerDataById)
  Future<TrainerModel> getTrainer(@Query("Id") String id);

  @GET(ApiEndPoints.getAllUsers)
  Future<List<TraineeModel>> getAllTrainees();

  @GET(ApiEndPoints.getNewUsers)
  Future<List<TraineeModel>> getNewTrainees();

  @GET(ApiEndPoints.getUserAboutToExpire)
  Future<List<TraineeModel>> getUsersAboutToExpired();

  @GET(ApiEndPoints.dietMeals)
  Future<List<DietMealModel>?> getDietMeals();

  @POST(ApiEndPoints.addDietMealForUser)
  Future<void> assignDietMealForUser(
    @Body() Map<String, dynamic> body,
  );

  @PUT(ApiEndPoints.updateDietMealForUser)
  Future<void> updateDietMealForUser(
    @Body() Map<String, dynamic> body,
  );

  @PUT(ApiEndPoints.dietMeals)
  Future<DietMealModel> updateDietMeal(@Body() Map<String, dynamic> body);

  @DELETE(ApiEndPoints.dietMeals)
  Future<void> deleteDietMeal(@Query("Id") int id);

  @GET(ApiEndPoints.getUserById)
  Future<TraineeModel> getLoggedUserData(@Query("userId") String id);

  @GET(ApiEndPoints.getUserDiet)
  Future<List<UserDiet>> getLoggedUserDiet(@Query("userId") String id);

  @GET(ApiEndPoints.exercise)
  Future<List<WorkoutSystemModel>> getWorkoutSystems();

  @GET("${ApiEndPoints.exercise}/{Id}")
  Future<WorkoutSystemModel> getWorkout(@Path("Id") int id);

  @DELETE(ApiEndPoints.exercise)
  Future<void> deleteWorkoutSystem(@Query("Id") int id);

  @PUT(ApiEndPoints.addExerciseForUser)
  Future<void> addWorkoutForUser(
    @Query("ExerciseId") int workoutId,
    @Query("UserId") String userId,
  );

  @GET(ApiEndPoints.allChats)
  Future<List<UserModel>> getAllChas();

  @GET(ApiEndPoints.chat)
  Future<List<ChatMessageModel>> getChat(@Query("receiverId") String id);

  @POST(ApiEndPoints.sendMessage)
  Future<void> sendMessage(@Body() Map<String, dynamic> body);

  @DELETE(ApiEndPoints.deleteChat)
  Future<void> deleteMessage({@Query("MessageID") required String id});

}

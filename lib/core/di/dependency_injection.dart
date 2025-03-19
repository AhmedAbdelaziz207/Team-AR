import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/auth/login/logic/login_cubit.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_cubit.dart';
import 'package:team_ar/features/home/admin/logic/trainees_cubit.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_cubit.dart';
import 'package:team_ar/features/plans_screen/repos/user_plans_repository.dart';
import '../../features/auth/login/repos/login_repository.dart';
import '../../features/auth/register/logic/register_cubit.dart';
import '../../features/auth/register/repos/register_repository.dart';
import '../../features/home/admin/repos/trainees_repository.dart';
import '../../features/home/user/logic/navigation/navigation_cubit.dart';
import '../../features/work_out/logic/workout_cubit.dart';
import '../network/dio_factory.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Dio and ApiService
  Dio dio = await DioFactory.getDio();
  getIt.registerLazySingleton<ApiService>(() => ApiService(dio));

  // Login
  getIt.registerLazySingleton(() => LoginRepository(getIt()));
  getIt.registerFactory(() => LoginCubit(getIt()));

  // User Plans
  getIt.registerFactory(() => UserPlansRepository(getIt()));
  getIt.registerFactory(() => UserPlansCubit(getIt()));

  // Confirm Subscription
  getIt.registerFactory(() => ConfirmSubscriptionCubit());

  // Register
  getIt.registerFactory(() => RegisterRepository(getIt()));
  getIt.registerFactory(() => RegisterCubit(getIt()));

  // Admin Home
  getIt.registerLazySingleton(() => TraineesRepository(getIt()));
  getIt.registerFactory(() => TraineeCubit(getIt()));

  // Navigation Bar
  getIt.registerFactory(() => NavigationCubit());
  //Workout
  getIt.registerFactory(() => WorkoutCubit());
}

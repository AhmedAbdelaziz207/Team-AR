import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/auth/login/logic/login_cubit.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_cubit.dart';
import 'package:team_ar/features/plans_screen/repos/user_plans_repository.dart';
import '../../features/auth/login/repos/login_repository.dart';
import '../network/dio_factory.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Dio and ApiService
  Dio dio = DioFactory.getDio();
  getIt.registerLazySingleton<ApiService>(() => ApiService(dio));

  // Login
  getIt.registerLazySingleton(() => LoginRepository(getIt()));
  getIt.registerFactory(() => LoginCubit(getIt()));

  // User Plans
  getIt.registerLazySingleton(() => UserPlansRepository(getIt()));
  getIt.registerLazySingleton(() => UserPlansCubit(getIt()));




}

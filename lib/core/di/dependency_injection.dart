import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/auth/login/logic/login_cubit.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_cubit.dart';
import 'package:team_ar/features/home/admin/logic/trainees_cubit.dart';
import '../../features/auth/login/repos/login_repository.dart';
import '../../features/auth/register/logic/register_cubit.dart';
import '../../features/auth/register/repos/register_repository.dart';
import '../../features/home/admin/repos/trainees_repository.dart';
import '../../features/home/user/logic/navigation/navigation_cubit.dart';
import '../../features/notification/logic/notification_cubit.dart';
import '../../features/notification/services/local_notification_service.dart';
import '../../features/notification/services/notification_repo_impl.dart';
import '../../features/notification/services/notification_repository.dart';
import '../../features/notification/services/notification_service.dart';
import '../../features/work_out/logic/workout_cubit.dart';
import '../network/dio_factory.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  try {
    // تهيئة SharedPreferences أولاً
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    // Dio and ApiService
    Dio dio = DioFactory.getDio();
    getIt.registerLazySingleton<Dio>(() => dio);
    getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));

    // Notification Repository - يجب تسجيله قبل الخدمات التي تعتمد عليه
    getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        getIt<ApiService>(),
        getIt<SharedPreferences>(),
      ),
    );

    // Local Notification Service
    getIt.registerLazySingleton<LocalNotificationService>(
      () => LocalNotificationService(),
    );

    // Notification Service - يعتمد على NotificationRepository و LocalNotificationService
    getIt.registerLazySingleton<NotificationService>(
      () => NotificationService(
        localNotificationService: getIt<LocalNotificationService>(),
        repository: getIt<NotificationRepository>(),
      ),
    );

    // Login
    getIt.registerLazySingleton<LoginRepository>(
        () => LoginRepository(getIt<ApiService>()));
    getIt.registerFactory<LoginCubit>(
        () => LoginCubit(getIt<LoginRepository>()));

    // Confirm Subscription
    getIt.registerFactory<ConfirmSubscriptionCubit>(
        () => ConfirmSubscriptionCubit());

    // Register
    getIt.registerLazySingleton<RegisterRepository>(
        () => RegisterRepository(getIt<ApiService>()));
    getIt.registerFactory<RegisterCubit>(
        () => RegisterCubit(getIt<RegisterRepository>()));

    // Admin Home
    getIt.registerLazySingleton<TraineesRepository>(
        () => TraineesRepository(getIt<ApiService>()));
    getIt.registerFactory<TraineeCubit>(
        () => TraineeCubit(getIt<TraineesRepository>()));

    // Navigation Bar
    getIt.registerFactory<NavigationCubit>(() => NavigationCubit());

    // Workout
    getIt.registerFactory<WorkoutCubit>(() => WorkoutCubit());

    // Notification Cubit - يجب تسجيله في النهاية بعد جميع الخدمات
    getIt.registerFactory<NotificationCubit>(() => NotificationCubit(
          notificationService: getIt<NotificationService>(),
          repository: getIt<NotificationRepository>(),
          localNotificationService: getIt<LocalNotificationService>(),
        ));

    // تهيئة خدمة الإشعارات
    await getIt<NotificationService>().initialize();
  } catch (e) {
    throw Exception('فشل في تهيئة الخدمات: ${e.toString()}');
  }
}

// دالة لتنظيف الخدمات عند إغلاق التطبيق
Future<void> disposeServiceLocator() async {
  try {
    // تنظيف خدمة الإشعارات
    getIt<NotificationService>().dispose();

    // تنظيف repository إذا كان يحتوي على dispose
    // if (getIt<NotificationRepository>() is NotificationRepositoryImpl) {
    //   (getIt<NotificationRepository>() as NotificationRepositoryImpl).dispose();
    // }

    // إعادة تعيين GetIt
    await getIt.reset();
  } catch (e) {
    print('خطأ في تنظيف الخدمات: ${e.toString()}');
  }
}

// دالة للتحقق من تسجيل الخدمات
void validateServiceRegistration() {
  final requiredServices = [
    SharedPreferences,
    Dio,
    ApiService,
    NotificationRepository,
    LocalNotificationService,
    NotificationService,
    LoginRepository,
    RegisterRepository,
    TraineesRepository,
  ];

  for (final serviceType in requiredServices) {
    if (!getIt.isRegistered(instance: serviceType)) {
      throw Exception('الخدمة غير مسجلة: ${serviceType.toString()}');
    }
  }

  print('✅ تم تسجيل جميع الخدمات بنجاح');
}

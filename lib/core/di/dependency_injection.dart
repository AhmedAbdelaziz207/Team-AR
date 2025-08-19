import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_ar/features/payment/logic/payment_cubit.dart';
import 'package:team_ar/features/payment/repository/payment_repository.dart';
import 'package:team_ar/features/payment/service/fawaterk_service.dart';
import 'package:team_ar/features/payment/service/payment_security_service.dart';
import '../../features/auth/login/logic/login_cubit.dart';
import '../../features/auth/login/repos/login_repository.dart';
import '../../features/auth/register/logic/register_cubit.dart';
import '../../features/auth/register/logic/admin_register_cubit.dart';
import '../../features/auth/register/repos/register_repository.dart';
import '../../features/confirm_subscription/logic/confirm_subscription_cubit.dart';
import '../../features/home/admin/logic/trainees_cubit.dart';
import '../../features/home/admin/repos/trainees_repository.dart';
import '../../features/home/user/logic/navigation/navigation_cubit.dart';
import '../../features/notification/logic/notification_cubit.dart';
import '../../features/notification/services/local_notification_service.dart';
import '../../features/notification/services/notification_repo_impl.dart';
import '../../features/notification/services/notification_repository.dart';
import '../../features/notification/services/notification_storage.dart';
import '../../features/work_out/logic/workout_cubit.dart';
import '../network/api_service.dart';
import '../network/dio_factory.dart';
import '../services/notification_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  try {
    // Shared Preferences
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    // Dio and ApiService
    Dio dio = DioFactory.getDio();
    getIt.registerLazySingleton<Dio>(() => dio);
    getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));
    print('✅ ApiService registered successfully');

    // إضافة خدمة فواتيرك
    getIt.registerLazySingleton<FawaterkService>(() => FawaterkService());

    // إضافة مستودع الدفع
    getIt.registerLazySingleton<PaymentRepository>(
      () => PaymentRepository(getIt<FawaterkService>(), getIt<ApiService>()),
    );


    // // في ملف dependency_injection.dart
    // void setupPaymentDependencies() {
    //   // تسجيل خدمة فواتيرك
    //   getIt.registerLazySingleton<FawaterkService>(
    //         () => FawaterkService(),
    //   );
    //
    //   // تسجيل مستودع الدفع
    //   getIt.registerLazySingleton<PaymentRepository>(
    //         () => PaymentRepository(
    //       getIt<FawaterkService>(),
    //       getIt<ApiService>(),
    //     ),
    //   );
    // }











    // // تسجيل خدمات الدفع الإضافية
    // getIt.registerLazySingleton<PaymentHistoryService>(
    //   () => PaymentHistoryService(
    //       getIt<ApiService>(), getIt<SharedPreferences>()),
    // );

    // getIt.registerLazySingleton<PaymentRetryService>(
    //   () => PaymentRetryService(getIt<PaymentRepository>()),
    // );

    getIt.registerLazySingleton<PaymentSecurityService>(
      () => PaymentSecurityService(),
    );

    // تسجيل PaymentCubit
    getIt.registerFactory<PaymentCubit>(
      () => PaymentCubit(getIt<PaymentRepository>()),
    );

    // Notification Repository
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

    // Notification Service
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

    // Register
    getIt.registerLazySingleton<RegisterRepository>(
        () => RegisterRepository(getIt<ApiService>()));
    getIt.registerFactory<RegisterCubit>(
        () => RegisterCubit(getIt<RegisterRepository>()));

    // Admin Register
    getIt.registerFactory<AdminRegisterCubit>(
        () => AdminRegisterCubit(getIt<RegisterRepository>()));

    // Confirm Subscription
    getIt.registerFactory<ConfirmSubscriptionCubit>(
        () => ConfirmSubscriptionCubit());

    // Admin Home
    getIt.registerLazySingleton<TraineesRepository>(
        () => TraineesRepository(getIt<ApiService>()));
    getIt.registerFactory<TraineeCubit>(
        () => TraineeCubit(getIt<TraineesRepository>()));

    // Navigation
    getIt.registerFactory<NavigationCubit>(() => NavigationCubit());

    // Workout
    getIt.registerFactory<WorkoutCubit>(() => WorkoutCubit());

    // Notification Storage
    getIt.registerLazySingleton<NotificationStorage>(
        () => NotificationStorage());

    // Notification Cubit
    getIt.registerFactory<NotificationCubit>(() => NotificationCubit(
          notificationService: getIt<NotificationService>(),
          repository: getIt<NotificationRepository>(),
          localNotificationService: getIt<LocalNotificationService>(),
          storage: getIt<NotificationStorage>(),
        ));

    // Initialize Notification Service
    await getIt<NotificationService>().initialize();
    print('✅ تم تهيئة NotificationService بنجاح');
  } catch (e) {
    print('❌ خطأ في تهيئة الخدمات: ${e.toString()}');
    rethrow;
  }
}

Future<void> disposeServiceLocator() async {
  try {
    getIt<NotificationService>().dispose();
    await getIt.reset();
    print('✅ تم تنظيف الخدمات بنجاح');
  } catch (e) {
    print('❌ خطأ في تنظيف الخدمات: ${e.toString()}');
  }
}

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

  // تم نقل تسجيل الخدمات التالية إلى setupServiceLocator()
  // getIt.registerLazySingleton<FawaterkService>(() => FawaterkService());
  // getIt.registerLazySingleton<PaymentRepository>(
  //   () => PaymentRepository(getIt<FawaterkService>(), getIt<ApiService>()),
  // );
}

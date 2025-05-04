import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/features/add_workout/model/add_workout_params.dart';
import 'package:team_ar/features/auth/login/ui/login_screen.dart';
import 'package:team_ar/features/auth/register/logic/register_cubit.dart';
import 'package:team_ar/features/auth/register/register_screen.dart';
import 'package:team_ar/features/confirm_subscription/confirm_subscription_screen.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_cubit.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/home/admin/logic/trainees_cubit.dart';
import 'package:team_ar/features/home/user/logic/user_cubit.dart';
import 'package:team_ar/features/landing/admin/admin_landing_screen.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_cubit.dart';
import 'package:team_ar/features/manage_meals_screen/model/meal_model.dart';
import 'package:team_ar/features/manage_meals_screen/ui/add_meal_screen.dart';
import 'package:team_ar/features/manage_meals_screen/ui/manage_food_screen.dart';
import 'package:team_ar/features/manage_plans/ui/manage_plans_screen.dart';
import 'package:team_ar/features/onboarding/onboarding_screen.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_cubit.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';
import 'package:team_ar/features/plans_screen/plans_screen.dart';
import 'package:team_ar/features/profile_screen/change_password_screen.dart';
import 'package:team_ar/features/select_launguage/select_launguage.dart';
import 'package:team_ar/features/select_meals/model/select_meal_params.dart';
import 'package:team_ar/features/select_meals/select_meals_screen.dart';
import 'package:team_ar/features/splash/splash_screen.dart';
import 'package:team_ar/features/trainees_screen/trainees_screen.dart';
import 'package:team_ar/features/trainer_register_success/trainer_register_success_screen.dart';
import 'package:team_ar/features/update_user_diet/admin_users_meal_screen.dart';
import 'package:team_ar/features/users_management/ui/users_about_to_expire_screen.dart';
import 'package:team_ar/features/work_out/logic/workout_cubit.dart';
import 'package:team_ar/features/workout_systems/logic/workout_system_cubit.dart';
import '../../features/add_workout/add_workout_screen.dart';
import '../../features/auth/login/logic/login_cubit.dart';
import '../../features/diet/logic/user_diet_cubit.dart';
import '../../features/diet/ui/user_meal_details.dart';
import '../../features/home/admin/admin_home_screen.dart';
import '../../features/home/admin/repos/trainees_repository.dart';
import '../../features/home/user/logic/navigation/navigation_cubit.dart';
import '../../features/home/user/ui/root_screen.dart';
import '../../features/trainer_register_success/model/register_success_model.dart';
import '../../features/user_info/trainee_info_screen.dart';
import '../../features/work_out/ui/exercise_screen.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings? settings) {
    switch (settings?.name) {
      case Routes.splash:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      case Routes.onboarding:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      case Routes.selectLanguage:
        return MaterialPageRoute(
          builder: (context) => const SelectLanguage(),
        );
      case Routes.login:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<LoginCubit>(),
            child: const LoginScreen(),
          ),
        );

      case Routes.register:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<RegisterCubit>(),
            child: const RegisterScreen(),
          ),
        );

      case Routes.plans:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => UserPlansCubit(),
            child: const PlansScreen(),
          ),
        );

      case Routes.confirmSubscription:
        final plan = settings?.arguments as UserPlan;

        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => getIt<ConfirmSubscriptionCubit>(),
              ),
              BlocProvider(
                create: (context) => getIt<RegisterCubit>(),
              ),
            ],
            child: ConfirmSubscriptionScreen(
              userPlan: plan,
            ),
          ),
        );

      case Routes.adminLanding:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<TraineeCubit>(),
            child: const AdminLandingScreen(),
          ),
        );

      case Routes.adminHome:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<TraineeCubit>(),
            child: const AdminHomeScreen(),
          ),
        );
      case Routes.managePlansScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => UserPlansCubit(),
            child: const ManagePlansScreen(),
          ),
        );
      case Routes.manageMealsScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => MealCubit(),
            child: const ManageMealsScreen(),
          ),
        );
      case Routes.adminTraineesScreen:
        final List<TraineeModel> trainees =
            settings?.arguments as List<TraineeModel>;

        return MaterialPageRoute(
          builder: (context) => TraineesScreen(trainees: trainees),
        );

      case Routes.rootScreen:
        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => getIt<NavigationCubit>(),
              ),
              BlocProvider(
                create: (context) => UserCubit(),
              ),
            ],
            child: const RootScreen(),
          ),
        );

      case Routes.exercise:
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => getIt<WorkoutCubit>(),
                  child: const ExerciseScreen(),
                ));
      case Routes.addMeal:
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => MealCubit(),
                  child: const AddMealScreen(),
                ));
      case Routes.userInfo:
        final trainee = settings?.arguments as TraineeModel;

        return MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => UserCubit(),
                    ),
                    BlocProvider(
                      create: (context) => UserPlansCubit(),
                    ),
                  ],
                  child: TraineeInfoScreen(
                    traineeModel: trainee,
                  ),
                ));
      case Routes.selectUserMeals:
        final params = settings?.arguments as SelectMealParams;
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => MealCubit(),
                  child: SelectMealsScreen(params: params),
                ));
      case Routes.mealDetails:
        final meal = settings?.arguments as DietMealModel;
        return MaterialPageRoute(
          builder: (context) => UserMealDetails(meal: meal),
        );
      case Routes.usersAboutToExpire:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => TraineeCubit(getIt<TraineesRepository>()),
            child: const UsersAboutToExpireScreen(),
          ),
        );
      case Routes.registerSuccess:
        final data = settings?.arguments as RegisterSuccessModel;
        return MaterialPageRoute(
          builder: (context) => TrainerRegistrationSuccess(
            data: data,
          ),
        );
      case Routes.addWorkout:
        final params = settings?.arguments as AddWorkoutParams;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => WorkoutSystemCubit(),
            child: AddWorkoutScreen(
              params: params,
            ),
          ),
        );
      case Routes.changePassword:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => WorkoutSystemCubit(),
            child: ChangePasswordScreen(),
          ),
        );
      case Routes.adminUserMeals:
        final userId = settings?.arguments as String;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => UserDietCubit(),
            child: AdminMealsScreen(
              userId: userId,
            ),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings?.name}'),
            ),
          ),
        );
    }
  }
}

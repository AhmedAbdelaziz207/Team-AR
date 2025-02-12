import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/features/auth/login/login_screen.dart';
import 'package:team_ar/features/auth/register/logic/register_cubit.dart';
import 'package:team_ar/features/auth/register/register_screen.dart';
import 'package:team_ar/features/confirm_subscription/confirm_subscription_screen.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_cubit.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/home/admin/logic/trainees_cubit.dart';
import 'package:team_ar/features/landing/admin/admin_landing_screen.dart';
import 'package:team_ar/features/onboarding/onboarding_screen.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_cubit.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';
import 'package:team_ar/features/plans_screen/plans_screen.dart';
import 'package:team_ar/features/select_launguage/select_launguage.dart';
import 'package:team_ar/features/splash/splash_screen.dart';
import 'package:team_ar/features/trainees_screen/trainees_screen.dart';
import '../../features/auth/login/logic/login_cubit.dart';
import '../../features/home/admin/admin_home_screen.dart';
import '../../features/home/user/logic/navigation/navigation_cubit.dart';
import '../../features/home/user/ui/root_screen.dart';

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
            create: (context) => getIt<UserPlansCubit>(),
            child: const PlansScreen(),
          ),
        );

      case Routes.confirmSubscription:
        final plan = settings?.arguments as UserPlan;

        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<ConfirmSubscriptionCubit>(),
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
      case Routes.adminTraineesScreen:
        final List<TraineeModel> trainees =
            settings?.arguments as List<TraineeModel>;

        return MaterialPageRoute(
          builder: (context) => TraineesScreen(trainees: trainees),
        );

      case Routes.rootScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<NavigationCubit>(),
            child: const RootScreen(),
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

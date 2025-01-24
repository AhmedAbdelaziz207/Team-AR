import 'package:flutter/material.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/features/auth/login/login_screen.dart';
import 'package:team_ar/features/onboarding/onboarding_screen.dart';
import 'package:team_ar/features/select_launguage/select_launguage.dart';
import 'package:team_ar/features/splash/splash_screen.dart';

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
          builder: (context) => const LoginScreen(),
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

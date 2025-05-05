import 'package:flutter/material.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/core/utils/app_constants.dart';

import '../auth/login/model/user_role.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(
      const Duration(seconds: 1),
      () async {
        // Navigator.pushNamed(context, Routes.onboarding);
        await handleNavigation();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.newPrimaryColor,
        ),
      ),
    );
  }

  Future<void> handleNavigation() async {
    final token = await SharedPreferencesHelper.getString(AppConstants.token);
    final userRole =
        await SharedPreferencesHelper.getString(AppConstants.userRole);

    if (token != null && userRole != null && context.mounted) {
      if (userRole.toLowerCase() == UserRole.Admin.name.toLowerCase()) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.adminLanding,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.rootScreen,
          (route) => false,
        );
      }
    } else {
      Navigator.pushNamed(context, Routes.onboarding);
    }
  }
}

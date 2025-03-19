import 'package:flutter/material.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
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
  void initState()  {

    Future.delayed(
      const Duration(seconds: 3),
      ()  async {
        await handleNavigation();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAssets.appLogo),
        ],
      ),
    );
  }

  Future<void> handleNavigation() async {
    final token =await  SharedPreferencesHelper.getString(AppConstants.token);
    final userRole =await  SharedPreferencesHelper.getString(AppConstants.userRole);

    if(token != null && userRole != null && context.mounted){
      if(userRole == UserRole.Admin.name){
        Navigator.pushNamedAndRemoveUntil(context, Routes.adminLanding,(route) => false,);
      }
        if(userRole == UserRole.User.name){
        Navigator.pushNamedAndRemoveUntil(context, Routes.userHome,(route) => false,);
      }



    }


    else{
      Navigator.pushNamed(context, Routes.onboarding);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/utils/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(
      const Duration(seconds: 3),
      () {
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.onboarding,
            (route) => false,
          );
        }
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
}

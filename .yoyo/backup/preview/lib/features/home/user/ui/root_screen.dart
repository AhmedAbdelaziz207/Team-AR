import 'package:flutter/material.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/home/user/widget/navigation_bulider.dart';
import 'package:team_ar/features/home/user/widget/navigation_click.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: NavigationBuilder(),
      body: NavigationClick(),
    );
  }
}

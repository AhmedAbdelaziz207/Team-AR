import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/admin_panal/admin_panel.dart';

import '../../home/admin/admin_home_screen.dart';

class AdminLandingScreen extends StatefulWidget {
  const AdminLandingScreen({super.key});

  @override
  State<AdminLandingScreen> createState() => _AdminLandingScreenState();
}

class _AdminLandingScreenState extends State<AdminLandingScreen> {
  int selectedIndex = 0;
  final screens = [
    const AdminHomeScreen(),
    const Center(child: Text("Register")),
    const Center(child: Text("Exercises")),
    const AdminPanel()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        unselectedLabelStyle: const TextStyle(
          color: AppColors.grey,
          fontWeight: FontWeight.bold,
        ),
        selectedLabelStyle: const TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
        ),
        onTap: (value) {
          selectedIndex = value;
          setState(() {});
        },
        items:  [
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.home_outlined,
                  color: AppColors.primaryColor,
                  size: 30.sp,
                ),
                if (selectedIndex == 0)
                Divider(
                  color: AppColors.primaryColor,
                  height: 4.h,
                  thickness: 2.sp,
                  indent:  20.w,
                  endIndent: 20.w,
                )
              ],
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.primaryColor,
                  size: 30.sp,
                ),
                if (selectedIndex == 1)
                  Divider(
                    color: AppColors.primaryColor,
                    height: 4.h,
                    thickness: 2.sp,
                    indent:  20.w,
                    endIndent: 20.w,
                  )
              ],
            ),
            label: "New User",
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: AppColors.primaryColor,
                  size: 30.sp,
                ),
                if (selectedIndex == 2)
                  Divider(
                    color: AppColors.primaryColor,
                    height: 4.h,
                    thickness: 2.sp,
                    indent:  20.w,
                    endIndent: 20.w,
                  )
              ],
            ),
            label: "Exercises",
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.manage_accounts_rounded,
                  color: AppColors.primaryColor,
                  size: 30.sp,
                ),
                if (selectedIndex == 3)
                  Divider(
                    color: AppColors.primaryColor,
                    height: 4.h,
                    thickness: 2.sp,
                    indent:  20.w,
                    endIndent: 20.w,
                  )
              ],
            ),
            label: "Manage",
          ),
        ],
      ),
    );
  }
}

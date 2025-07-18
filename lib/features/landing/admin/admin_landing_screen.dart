import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/admin_panal/admin_panel.dart';
import 'package:team_ar/features/chat/logic/chat_cubit.dart';
import 'package:team_ar/features/chat/ui/all_chats_screen.dart';
import 'package:team_ar/features/workout_systems/logic/workout_system_cubit.dart';
import 'package:team_ar/features/workout_systems/ui/workout_systems_screen.dart';
import '../../home/admin/admin_home_screen.dart';
import '../../users_management/ui/users_management_screen.dart';

class AdminLandingScreen extends StatefulWidget {
  const AdminLandingScreen({super.key});

  @override
  State<AdminLandingScreen> createState() => _AdminLandingScreenState();
}

class _AdminLandingScreenState extends State<AdminLandingScreen> {
  int selectedIndex = 0;
  final screens = [
    const AdminHomeScreen(),
    BlocProvider(
      create: (context) => ChatCubit(),
      child: const AllChatsScreen(),
    ),
    const UsersManagementScreen(),
    BlocProvider(
      create: (context) => WorkoutSystemCubit(),
      child: const WorkoutSystemsScreen(),
    ),
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
        items: [
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
                    indent: 35.w,
                    endIndent: 35.w,
                  )
              ],
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.message_outlined,
                  color: AppColors.primaryColor,
                  size: 25.sp,
                ),
                if (selectedIndex == 1)
                  Divider(
                    color: AppColors.primaryColor,
                    height: 4.h,
                    thickness: 2.sp,
                    indent: 35.w,
                    endIndent: 35.w,
                  )
              ],
            ),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.primaryColor,
                  size: 30.sp,
                ),
                if (selectedIndex == 2)
                  Divider(
                    color: AppColors.primaryColor,
                    height: 4.h,
                    thickness: 2.sp,
                    indent: 35.w,
                    endIndent: 35.w,
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
                if (selectedIndex == 3)
                  Divider(
                    color: AppColors.primaryColor,
                    height: 4.h,
                    thickness: 2.sp,
                    indent: 35.w,
                    endIndent: 35.w,
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
                if (selectedIndex ==4)
                  Divider(
                    color: AppColors.primaryColor,
                    height: 4.h,
                    thickness: 2.sp,
                    indent: 35.w,
                    endIndent: 35.w,
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

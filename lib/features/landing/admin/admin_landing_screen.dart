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
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, "الرئيسية"),
                _buildNavItem(1, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, "الرسائل"),
                _buildNavItem(2, Icons.people_outline_rounded, Icons.people_rounded, "الأعضاء"),
                _buildNavItem(3, Icons.fitness_center_outlined, Icons.fitness_center, "التمارين"),
                _buildNavItem(4, Icons.manage_accounts_outlined, Icons.manage_accounts, "الإدارة"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14.w : 10.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primaryColor : AppColors.grey,
              size: isSelected ? 26.sp : 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryColor : AppColors.grey,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

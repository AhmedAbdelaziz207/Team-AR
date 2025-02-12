import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../logic/navigation/nav_bar_items.dart';
import '../logic/navigation/navigation_cubit.dart';
import '../logic/navigation/navigation_state.dart';

class NavigationBulider extends StatelessWidget {
  const NavigationBulider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return BottomNavigationBar(
          currentIndex: state.index,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                color: AppColors.grey,
                size: 28.sp,
              ),
              activeIcon: Icon(
                Icons.home_outlined,
                color: AppColors.primaryColor,
                size: 30.sp,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/dumbbell.png"),
                color: AppColors.grey,
                size: 28.sp,
              ),
              activeIcon: ImageIcon(
                AssetImage("assets/images/dumbbell.png"),
                color: AppColors.primaryColor,
                size: 30.sp,
              ),
              label: 'Workouts',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.comment,
                color: AppColors.grey,
                size: 28.sp,
              ),
              activeIcon: Icon(
                Icons.comment,
                color: AppColors.primaryColor,
                size: 30.sp,
              ),
              label: 'Thoughts',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/dish.png"),
                color: AppColors.grey,
                size: 28.sp,
              ),
              activeIcon: ImageIcon(
                AssetImage("assets/images/dish.png"),
                color: AppColors.primaryColor,
                size: 30.sp,
              ),
              label: 'Food',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.menu,
                color: AppColors.grey,
                size: 28.sp,
              ),
              activeIcon: Icon(
                Icons.menu,
                color: AppColors.primaryColor,
                size: 30.sp,
              ),
              label: 'Profile',
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              getNavBarItem(NavBarItems.home, context);
            }
            if (index == 1) {
              getNavBarItem(NavBarItems.workouts, context);
            }
            if (index == 2) {
              getNavBarItem(NavBarItems.thoughts, context);
            }
            if (index == 3) {
              getNavBarItem(NavBarItems.food, context);
            }
            if (index == 4) {
              getNavBarItem(NavBarItems.profile, context);
            }
          },
        );
      },
    );
  }
}
void getNavBarItem(NavBarItems navbarItem, BuildContext context) {
  context.read<NavigationCubit>().getNavBarItem(navbarItem);
}

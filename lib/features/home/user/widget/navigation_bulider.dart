import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_assets.dart';
import '../logic/navigation/nav_bar_items.dart';
import '../logic/navigation/navigation_cubit.dart';
import '../logic/navigation/navigation_state.dart';

class NavigationBuilder extends StatelessWidget {
  const NavigationBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: state.index,
          showSelectedLabels: false,
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
                const AssetImage(AppAssets.dumbbell),
                color: AppColors.grey,
                size: 28.sp,
              ),
              activeIcon: ImageIcon(
                const AssetImage(AppAssets.dumbbell),
                color: AppColors.primaryColor,
                size: 30.sp,
              ),
              label: 'Workouts',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                const AssetImage(AppAssets.iconDish),
                color: AppColors.grey,
                size: 28.sp,
              ),
              activeIcon: ImageIcon(
                const AssetImage(AppAssets.iconDish),
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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/features/admin_panal/widget/admin_manage_card.dart';
import 'package:team_ar/features/chat/logic/chat_cubit.dart';
import 'package:team_ar/features/chat/model/chat_user_model.dart';
import 'package:team_ar/features/chat/ui/message_screen.dart';
import 'package:team_ar/features/diet/logic/user_diet_cubit.dart';
import 'package:team_ar/features/diet/ui/user_diet_screen.dart';
import 'package:team_ar/features/home/user/logic/user_cubit.dart';
import 'package:team_ar/features/home/user/ui/user_home_screen.dart';
import 'package:team_ar/features/profile_screen/profile_screen.dart';
import 'package:team_ar/features/work_out/ui/work_out_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../logic/navigation/nav_bar_items.dart';
import '../logic/navigation/navigation_cubit.dart';
import '../logic/navigation/navigation_state.dart';

class NavigationClick extends StatelessWidget {
  const NavigationClick({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationCubit, NavigationState>(
      listenWhen: (previous, current) => current.navbarItem == NavBarItems.chat,
      listener: (context, state) {
        Navigator.pushNamed(context, Routes.chat,
            arguments: ChatUserModel(
              id: "8c5eda71-1ede-4394-80eb-de412d8f5ba3",
              userName: "Ahmed Ramadan",
              email: "Admin123@gmail.com",
            ));
      },
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          if (state.navbarItem == NavBarItems.home) {
            return const UserHomeScreen();
          }
          if (state.navbarItem == NavBarItems.workouts) {
            return const WorkOutScreen();
          }
          if (state.navbarItem == NavBarItems.food) {
            return BlocProvider(
              create: (context) => UserDietCubit(),
              child: const UserDietScreen(),
            );
          }
          if (state.navbarItem == NavBarItems.chat) {
            // Show an empty container or previous screen while chat screen is pushed via listener
            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30.h,
                      ),
                      AdminManageCard(
                        title: "تواصل معنا",
                        cardColor: AppColors.lightBlue,
                        onTap: () {
                          Navigator.pushNamed(context, Routes.chat,
                              arguments: ChatUserModel(
                                id: "8c5eda71-1ede-4394-80eb-de412d8f5ba3",
                                userName: "Ahmed Ramadan",
                                email: "Admin123@gmail.com",
                              ));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          if (state.navbarItem == NavBarItems.profile) {
            return BlocProvider(
              create: (context) => UserCubit(),
              child: const ProfileScreen(),
            );
          }
          return const SizedBox(); // Fallback UI
        },
      ),
    );
  }
}

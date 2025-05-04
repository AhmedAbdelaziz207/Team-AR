import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/diet/logic/user_diet_cubit.dart';
import 'package:team_ar/features/diet/ui/user_diet_screen.dart';
import 'package:team_ar/features/home/user/logic/user_cubit.dart';
import 'package:team_ar/features/home/user/ui/user_home_screen.dart';
import 'package:team_ar/features/profile_screen/profile_screen.dart';
import 'package:team_ar/features/work_out/ui/work_out_screen.dart';

import '../logic/navigation/nav_bar_items.dart';
import '../logic/navigation/navigation_cubit.dart';
import '../logic/navigation/navigation_state.dart';

class NavigationClick extends StatelessWidget {
  const NavigationClick({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
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
      if (state.navbarItem == NavBarItems.profile) {
        return BlocProvider(
          create: (context) => UserCubit(),
          child: ProfileScreen(),
        );
      }
      return Container();
    });
  }
}

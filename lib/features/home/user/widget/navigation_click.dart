import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/home/user/ui/user_home_screen.dart';

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
            return Center(child: Text('Workouts Screen'));
          }
          if (state.navbarItem == NavBarItems.thoughts) {
            return Center(child: Text('Thoughts Screen'));
          }
          if (state.navbarItem == NavBarItems.food) {
            return Center(child: Text('Food Screen'));
          }
          if (state.navbarItem == NavBarItems.profile) {}
          return Container();
        })
    ;
  }
}

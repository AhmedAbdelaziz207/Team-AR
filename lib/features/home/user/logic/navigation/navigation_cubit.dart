import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/home/user/logic/navigation/nav_bar_items.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(NavBarItems.home, 0));

  void getNavBarItem(NavBarItems navbarItem) {
    switch (navbarItem) {
      case NavBarItems.home:
        emit(const NavigationState(NavBarItems.home, 0));
        break;
      case NavBarItems.workouts:
        emit(const NavigationState(NavBarItems.workouts, 1));
        break;
      case NavBarItems.food:
        emit(const NavigationState(NavBarItems.food, 2));
      case NavBarItems.chat:
        emit(const NavigationState(NavBarItems.chat, 3));
        break;
      case NavBarItems.profile:
        emit(const NavigationState(NavBarItems.profile, 4));
    }
  }
}

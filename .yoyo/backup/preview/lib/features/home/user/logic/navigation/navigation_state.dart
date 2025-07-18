import 'package:equatable/equatable.dart';
import 'package:team_ar/features/home/user/logic/navigation/nav_bar_items.dart';


class NavigationState extends Equatable {
  final NavBarItems navbarItem;
  final int index;

  const NavigationState(this.navbarItem, this.index);

  @override
  List<Object> get props => [navbarItem, index];
}
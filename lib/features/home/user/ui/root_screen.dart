import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/home/user/logic/navigation/nav_bar_items.dart';
import 'package:team_ar/features/home/user/logic/navigation/navigation_cubit.dart';
import 'package:team_ar/features/home/user/logic/navigation/navigation_state.dart';
import 'package:team_ar/features/home/user/widget/navigation_bulider.dart';
import 'package:team_ar/features/home/user/widget/navigation_click.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      bottomNavigationBar: NavigationBulider(),
      body: NavigationClick(),
    );
  }
}

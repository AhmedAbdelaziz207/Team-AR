import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/widgets/custom_app_bar.dart';
import 'package:team_ar/features/home/user/logic/user_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/workout_card.dart';

class WorkOutScreen extends StatelessWidget {
  const WorkOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.h),
        child: const CustomAppBar(
          showNotification: true,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId =
              await SharedPreferencesHelper.getString(AppConstants.userId);
          if (userId != null && context.mounted) {
            context.read<UserCubit>().getUser(userId);
          }
        },
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: WorkoutCard(),
        ),
      ),
    );
  }
}

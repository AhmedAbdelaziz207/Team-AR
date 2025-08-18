import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/workout_card.dart';

class WorkOutScreen extends StatelessWidget {
  const WorkOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('EEEE d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.h),
        child: const CustomAppBar(
          showNotification: true,
        ),
      ),
      body: const WorkoutCard(),
    );
  }
}
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/admin_panal/widget/admin_user_card.dart';
import 'package:team_ar/features/admin_panal/widget/manage_food_card.dart';
import 'package:team_ar/features/admin_panal/widget/subscribed_users_section.dart';
import '../../core/di/dependency_injection.dart';
import '../home/admin/logic/trainees_cubit.dart';
import '../home/admin/repos/trainees_repository.dart';
import 'widget/manage_plans_card.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          AppLocalKeys.adminPanel.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 21.sp,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 24.h,
              ),
              BlocProvider(
                create: (context) => TraineeCubit(getIt<TraineesRepository>()),
                child: const SubscribedUsersSection(),
              ),
              ManagePlansCard(
                seeDetails: () {},
              ),
              SizedBox(
                height: 20.h,
              ),
              ManageFoodsCard(
                onViewFoods: () {},
              )
            ],
          ),
        ),
      ),
    );
  }
}

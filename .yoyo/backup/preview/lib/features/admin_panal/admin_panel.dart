import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/admin_panal/widget/admin_manage_card.dart';
import 'package:team_ar/features/admin_panal/widget/change_language_section.dart';
import 'package:team_ar/features/admin_panal/widget/logout_button.dart';
import 'package:team_ar/features/admin_panal/widget/subscribed_users_section.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/prefs/shared_pref_manager.dart';
import '../../core/routing/routes.dart';
import '../../core/utils/app_constants.dart';
import '../home/admin/logic/trainees_cubit.dart';
import '../home/admin/repos/trainees_repository.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          AppLocalKeys.adminPanel.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 21.sp,
            color:    AppColors.black
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
                create: (context) => TraineeCubit(
                  getIt<TraineesRepository>(),
                ),
                child: const SubscribedUsersSection(),
              ),
              SizedBox(height: 20.h),

              AdminManageCard(
                title: AppLocalKeys.manageFoods.tr(),
                cardColor: AppColors.lightBlue,
                onTap: () {
                  Navigator.pushNamed(context, Routes.manageMealsScreen);
                },
              ),
              SizedBox(height: 20.h),
              AdminManageCard(
                title: AppLocalKeys.plans.tr(),
                onTap: () {
                  Navigator.pushNamed(context, Routes.managePlansScreen);
                },
              ),
              SizedBox(height: 20.h),
              const LanguageSelection(),
              SizedBox(height: 20.h),

              // logout button

              SizedBox(
                height: 50.h,
              ),

              const Align(
                alignment: Alignment.center,
                child: LogoutButton(),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}


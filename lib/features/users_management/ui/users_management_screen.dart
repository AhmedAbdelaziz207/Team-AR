import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/admin_panal/widget/admin_manage_card.dart';

import '../../../../core/theme/app_colors.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalKeys.usersManagement.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontSize: 21.sp,
              ),
        ),
        leading: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 24.0.h,
            horizontal: 16.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "إدارة شؤون الأعضاء والاشتراكات",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20.h),
              AdminManageCard(
                title: AppLocalKeys.addNewUser.tr(),
                cardColor: AppColors.primaryColor,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.plans,
                  );
                },
              ),
              SizedBox(height: 20.h),
              AdminManageCard(
                title: AppLocalKeys.usersAboutToExpire.tr(),
                cardColor: Colors.orange[700] ?? AppColors.newPrimaryColor,
                onTap: () {
                  Navigator.pushNamed(context, Routes.usersAboutToExpire);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

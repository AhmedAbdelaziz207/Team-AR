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
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 40.0.h,
          horizontal: 16.w,
        ),
        child: SafeArea(
          child: Column(
            children: [
              AdminManageCard(
                title: AppLocalKeys.addNewUser.tr(),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.plans,
                  );
                },
              ),
              SizedBox(
                height: 12.h,
              ),
              AdminManageCard(
                title: AppLocalKeys.usersAboutToExpire.tr(),
                cardColor: AppColors.newPrimaryColor,
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

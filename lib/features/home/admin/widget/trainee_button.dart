import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/features/select_meals/model/select_meal_params.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_local_keys.dart';

class TraineeButton extends StatelessWidget {
  const TraineeButton({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () {
        Navigator.pushNamed(context, Routes.selectUserMeals,
            arguments: SelectMealParams(
              userId: userId!,
              mealNum: 1,
            ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: AppColors.primaryColor,
              size: 16.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              AppLocalKeys.add.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

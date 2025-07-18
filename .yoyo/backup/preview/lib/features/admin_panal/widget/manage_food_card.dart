import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';

class ManageFoodsCard extends StatelessWidget {
  final VoidCallback onViewFoods;

  const ManageFoodsCard({
    super.key,
    required this.onViewFoods,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fastfood, color: AppColors.orangeWithShade, size: 30.sp),
                SizedBox(width: 10.w),
                Text(
                  AppLocalKeys.manageFoods.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: 21.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalKeys.manageFoodsDescription.tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.grey, fontSize: 12.sp),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: onViewFoods,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                      minimumSize: Size(160.w, 40.h)
                  ), child: Row(
                  children: [
                     Icon(
                      Icons.list,
                      color: AppColors.white,
                      size: 25.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      AppLocalKeys.seeDetails.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

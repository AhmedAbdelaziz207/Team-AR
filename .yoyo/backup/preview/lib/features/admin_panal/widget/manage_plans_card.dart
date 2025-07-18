import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';

class ManagePlansCard extends StatelessWidget {
  final VoidCallback seeDetails;

  const ManagePlansCard({
    super.key,
    required this.seeDetails,
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
                Icon(Icons.fitness_center, color: Colors.blue, size: 30.sp),
                SizedBox(width: 10.w),
                Text(
                  AppLocalKeys.managePlans.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: 21.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalKeys.managePlansDescription.tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.grey, fontSize: 12.sp),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: seeDetails,
                  icon: Icon(
                    Icons.list,
                    color: AppColors.white,
                    size: 25.sp,
                  ),
                  label: Text(
                    AppLocalKeys.seeDetails.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                      minimumSize: Size(160.w, 40.h)
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

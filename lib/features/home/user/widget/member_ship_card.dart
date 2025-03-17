import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import '../../../../core/theme/app_colors.dart';

class MemberShipCard extends StatelessWidget {
  const MemberShipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h,),
            decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(.9), // Background color
          borderRadius: BorderRadius.circular(15.sp), // Rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.white.withOpacity(.3),
                  child: Icon(Icons.account_balance_wallet,
                      size: 20.sp, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                       AppLocalKeys.appName.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Joined 2024-12-21',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 32.sp),
                  child: Text(
                    '37 Days Left',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      color: AppColors.white.withOpacity(.8),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              // Rounded Progress Bar
              child: LinearProgressIndicator(
                value: 0.3.sp,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

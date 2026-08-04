import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';

class UsersTableHeader extends StatelessWidget {
  const UsersTableHeader({super.key, this.totalCount = 0});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.newSecondaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.newSecondaryColor.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_alt_rounded,
                size: 20.sp,
                color: AppColors.newSecondaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                "قائمة المشتركين المسجلين",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.newSecondaryColor,
                ),
              ),
            ],
          ),
          if (totalCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppColors.newSecondaryColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                "$totalCount مشترك",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

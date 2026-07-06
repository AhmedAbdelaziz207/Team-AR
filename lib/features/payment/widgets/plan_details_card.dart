import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/payment/widgets/info_row.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';

class PlanDetailsCard extends StatelessWidget {
  final UserPlan plan;
  const PlanDetailsCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.newPrimaryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.newPrimaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: AppColors.newPrimaryColor, size: 28.sp),
                SizedBox(width: 10.w),
                Text(
                  AppLocalKeys.planDetails.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.newPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _buildModernInfoRow(Icons.card_membership, AppLocalKeys.planLabel.tr(), plan.name ?? AppLocalKeys.notSpecified.tr()),
                SizedBox(height: 12.h),
                _buildModernInfoRow(Icons.access_time_filled, AppLocalKeys.durationLabel.tr(), '${plan.duration} ${AppLocalKeys.daysAgo.tr()}'),
                SizedBox(height: 12.h),
                _buildModernInfoRow(Icons.payments, AppLocalKeys.priceLabel.tr(), '${plan.newPrice} ${AppLocalKeys.le.tr()}', isHighlight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value, {bool isHighlight = false, Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.grey.shade500, size: 20.sp),
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 18.sp : 15.sp,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.bold,
            color: color ?? (isHighlight ? AppColors.newPrimaryColor : Colors.black87),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/payment/widgets/info_row.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';

class PlanDetailsCard extends StatelessWidget {
  final UserPlan plan;
  const PlanDetailsCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الاشتراك',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.newPrimaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            InfoRow(label: 'الباقة:', value: plan.name ?? 'غير محدد'),
            InfoRow(label: 'المدة:', value: '${plan.duration} يوم'),
            InfoRow(label: 'السعر:', value: '${plan.newPrice} جنيه'),
            if (plan.oldPrice != null && plan.oldPrice! > (plan.newPrice ?? 0))
              InfoRow(
                label: 'الخصم:',
                value: '${plan.oldPrice! - (plan.newPrice ?? 0)} جنيه',
              ),
          ],
        ),
      ),
    );
  }
}

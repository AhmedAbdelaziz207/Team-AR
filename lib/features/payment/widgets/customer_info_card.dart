import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/payment/widgets/info_row.dart';

class CustomerInfoCard extends StatelessWidget {
  final String customerName;
  final String customerEmail;
  const CustomerInfoCard({super.key, required this.customerName, required this.customerEmail});

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
              'معلومات العميل',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.newPrimaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            InfoRow(label: 'الاسم:', value: customerName),
            InfoRow(label: 'البريد الإلكتروني:', value: customerEmail),
          ],
        ),
      ),
    );
  }
}

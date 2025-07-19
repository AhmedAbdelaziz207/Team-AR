import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class SubscriptionWarningDialog extends StatelessWidget {
  final int daysRemaining;
  final VoidCallback onRenew;
  final VoidCallback onDismiss;

  const SubscriptionWarningDialog({
    super.key,
    required this.daysRemaining,
    required this.onRenew,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة التحذير
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time_rounded,
                size: 30.sp,
                color: Colors.orange,
              ),
            ),

            SizedBox(height: 20.h),

            // عنوان
            Text(
              'تنبيه انتهاء الاشتراك',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontFamily: "Cairo",
              ),
            ),

            SizedBox(height: 10.h),

            // رسالة
            Text(
              'اشتراكك سينتهي خلال $daysRemaining ${daysRemaining == 1 ? 'يوم' : 'أيام'}. جدد اشتراكك الآن لتجنب انقطاع الخدمة.',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.grey,
                fontFamily: "Cairo",
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 25.h),

            // أزرار
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.grey, width: 1.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'لاحقاً',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.grey,
                        fontFamily: "Cairo",
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onRenew,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.newPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'تجديد الآن',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.white,
                        fontFamily: "Cairo",
                      ),
                    ),
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
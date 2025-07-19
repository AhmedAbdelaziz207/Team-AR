import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/subscription_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/model/user_data.dart';
import '../screens/subscription_details_screen.dart';

class EnhancedMembershipCard extends StatelessWidget {
  final UserData userData;

  const EnhancedMembershipCard({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final status = SubscriptionService.checkSubscriptionStatus(userData);
    final daysRemaining = SubscriptionService.getDaysRemaining(userData);

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.newPrimaryColor,
            AppColors.newPrimaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.newPrimaryColor.withOpacity(0.3),
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً ${userData.name ?? 'المستخدم'}',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Cairo",
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'باقة ${userData.packageId}',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontSize: 14.sp,
                      fontFamily: "Cairo",
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionDetailsScreen(userData: userData),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          // شريط التقدم
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'متبقي من الاشتراك',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.9),
                        fontSize: 12.sp,
                        fontFamily: "Cairo",
                      ),
                    ),
                    Text(
                      '$daysRemaining ${daysRemaining == 1 ? 'يوم' : 'أيام'}',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Cairo",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: _getProgressValue(userData),
                    backgroundColor: AppColors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      status == SubscriptionStatus.expiringSoon
                          ? Colors.orange
                          : AppColors.white,
                    ),
                    minHeight: 4.h,
                  ),
                ),
              ],
            ),
          ),

          // تحذير إذا كان الاشتراك قارب على الانتهاء
          if (status == SubscriptionStatus.expiringSoon) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 16.sp,
                ),
                SizedBox(width: 5.w),
                Text(
                  'اشتراكك قارب على الانتهاء',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Cairo",
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  double _getProgressValue(UserData userData) {
    final startDate = DateTime.parse(userData.startPackage!);
    final endDate = DateTime.parse(userData.endPackage!);
    final now = DateTime.now();

    final totalDays = endDate.difference(startDate).inDays;
    final usedDays = now.difference(startDate).inDays;

    return (usedDays / totalDays).clamp(0.0, 1.0);
  }
}
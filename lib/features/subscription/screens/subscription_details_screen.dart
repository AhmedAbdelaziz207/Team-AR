import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';

import '../../../core/routing/routes.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/model/user_data.dart';
import '../../../core/utils/app_constants.dart';
import 'package:team_ar/features/payment/screens/payment_screen.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  final UserData userData;

  const SubscriptionDetailsScreen({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'تفاصيل الاشتراك',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: "Cairo",
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<SubscriptionStatus>(
        future: SubscriptionService.checkSubscriptionStatus(userData),
        builder: (context, statusSnapshot) {
          if (statusSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!statusSnapshot.hasData) {
            return const Center(child: Text('خطأ في تحميل البيانات'));
          }

          final status = statusSnapshot.data!;
          final daysRemaining = SubscriptionService.getDaysRemaining(userData);

          // Auto-redirect to payment if expiring soon or expired
          if (status == SubscriptionStatus.expiringSoon || status == SubscriptionStatus.expired) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final userId = await SharedPreferencesHelper.getString(AppConstants.userId);
              if (!context.mounted) return;
              if (userId != null && userId.isNotEmpty) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      userId: userId,
                    ),
                  ),
                );
              } else {
                // Fallback to plans if no user id
                Navigator.pushReplacementNamed(context, Routes.subscriptionPlans);
              }
            });
            return const SizedBox.shrink();
          }

          return _buildContent(context, status, daysRemaining);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, SubscriptionStatus status, int daysRemaining) {
    final startDate = DateTime.parse(userData.startPackage!);
    final endDate = DateTime.parse(userData.endPackage!);
    final totalDays = endDate.difference(startDate).inDays;
    final usedDays = totalDays - daysRemaining;
    final progress = totalDays > 0 ? usedDays / totalDays : 0.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة حالة الاشتراك
          Container(
            width: double.infinity,
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      color: AppColors.white,
                      size: 24.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _getStatusTitle(status),
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Cairo",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  'باقة ${userData.packageId}',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 14.sp,
                    fontFamily: "Cairo",
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'متبقي $daysRemaining ${daysRemaining == 1 ? 'يوم' : 'أيام'}',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Cairo",
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // شريط التقدم
          Text(
            'مدة الاشتراك',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              fontFamily: "Cairo",
            ),
          ),
          SizedBox(height: 10.h),

          Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الأيام المستخدمة',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.grey,
                        fontFamily: "Cairo",
                      ),
                    ),
                    Text(
                      '$usedDays من $totalDays يوم',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                        fontFamily: "Cairo",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.grey.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      status == SubscriptionStatus.expiringSoon
                          ? Colors.orange
                          : AppColors.newPrimaryColor,
                    ),
                    minHeight: 8.h,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // تفاصيل الاشتراك
          Text(
            'تفاصيل الاشتراك',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              fontFamily: "Cairo",
            ),
          ),
          SizedBox(height: 10.h),

          _buildDetailRow(
            'تاريخ البداية',
            DateFormat('dd/MM/yyyy').format(startDate),
          ),
          _buildDetailRow(
            'تاريخ النهاية',
            DateFormat('dd/MM/yyyy').format(endDate),
          ),
          _buildDetailRow(
            'المدة الإجمالية',
            '$totalDays ${totalDays == 1 ? 'يوم' : 'أيام'}',
          ),
          _buildDetailRow(
            'رقم الباقة',
            '${userData.packageId}',
          ),

          SizedBox(height: 30.h),

          // أزرار الإجراءات
          if (status == SubscriptionStatus.expiringSoon ||
              status == SubscriptionStatus.expired)
            // تعديل زر تجديد الاشتراك
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.newPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'تجديد الاشتراك',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    fontFamily: "Cairo",
                  ),
                ),
              ),
            ),

          SizedBox(height: 10.h),

          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.subscriptionPlans);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.newPrimaryColor, width: 1.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'عرض الباقات',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.newPrimaryColor,
                  fontFamily: "Cairo",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.grey,
              fontFamily: "Cairo",
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Icons.check_circle;
      case SubscriptionStatus.expiringSoon:
        return Icons.access_time;
      case SubscriptionStatus.expired:
        return Icons.error;
    }
  }

  String _getStatusTitle(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return 'الاشتراك نشط';
      case SubscriptionStatus.expiringSoon:
        return 'قارب على الانتهاء';
      case SubscriptionStatus.expired:
        return 'انتهى الاشتراك';
    }
  }
}
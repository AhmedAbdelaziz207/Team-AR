import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routing/routes.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/model/user_data.dart';

class SubscriptionStatusWidget extends StatelessWidget {
  final UserData userData;

  const SubscriptionStatusWidget({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SubscriptionStatus>(
      future: SubscriptionService.checkSubscriptionStatus(userData),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // أو يمكنك إظهار loading indicator
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final status = snapshot.data!;
        final daysRemaining = SubscriptionService.getDaysRemaining(userData);

        if (status == SubscriptionStatus.active && daysRemaining > 7) {
          return const SizedBox.shrink(); // لا تظهر شيئاً إذا كان الاشتراك نشطاً لأكثر من 7 أيام
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: _getStatusColor(status),
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getStatusTitle(status, daysRemaining),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
                        fontFamily: "Cairo",
                      ),
                    ),
                    Text(
                      _getStatusMessage(status, daysRemaining),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.grey,
                        fontFamily: "Cairo",
                      ),
                    ),
                  ],
                ),
              ),
              if (status == SubscriptionStatus.expiringSoon)
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.subscriptionPlans);
                  },
                  child: Text(
                    'تجديد',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status),
                      fontFamily: "Cairo",
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.expiringSoon:
        return Colors.orange;
      case SubscriptionStatus.expired:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Icons.check_circle_outline;
      case SubscriptionStatus.expiringSoon:
        return Icons.access_time_rounded;
      case SubscriptionStatus.expired:
        return Icons.error_outline;
    }
  }

  String _getStatusTitle(SubscriptionStatus status, int daysRemaining) {
    switch (status) {
      case SubscriptionStatus.active:
        return 'الاشتراك نشط';
      case SubscriptionStatus.expiringSoon:
        return 'قارب على الانتهاء';
      case SubscriptionStatus.expired:
        return 'انتهى الاشتراك';
    }
  }

  String _getStatusMessage(SubscriptionStatus status, int daysRemaining) {
    switch (status) {
      case SubscriptionStatus.active:
        return 'متبقي $daysRemaining ${daysRemaining == 1 ? 'يوم' : 'أيام'}';
      case SubscriptionStatus.expiringSoon:
        return 'سينتهي خلال $daysRemaining ${daysRemaining == 1 ? 'يوم' : 'أيام'}';
      case SubscriptionStatus.expired:
        return 'يرجى تجديد الاشتراك';
    }
  }
}
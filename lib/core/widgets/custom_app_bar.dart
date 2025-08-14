import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_local_keys.dart';
import '../../../core/routing/routes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;
  final bool showNotification;

  const CustomAppBar({
    super.key,
    this.onNotificationPressed,
    this.showNotification = true,
  });

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('EEEE d MMM', context.locale.languageCode)
        .format(DateTime.now());

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 120.h,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              // App Logo
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Image.asset(
                  AppAssets.appLogo,
                  height: 50.h,
                  width: 50.w,
                  color: AppColors.newPrimaryColor,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      size: 50.sp,
                      color: AppColors.newPrimaryColor,
                    );
                  },
                ),
              ),

              SizedBox(width: 16.w),

              // Date and Journey Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      todayDate,
                      style: TextStyle(
                        color: AppColors.black.withValues(alpha: 0.7),
                        fontSize: 14.sp,
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      AppLocalKeys.yourJourney.tr(),
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 18.sp,
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Notification Button
              if (showNotification)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      size: 24.sp,
                      color: AppColors.newPrimaryColor,
                    ),
                    onPressed: onNotificationPressed ?? () {
                      Navigator.pushNamed(context, Routes.notification);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(120.h);
}
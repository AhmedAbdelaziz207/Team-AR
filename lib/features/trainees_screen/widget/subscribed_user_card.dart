import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/widgets/status_badge.dart';
import '../../home/admin/data/trainee_model.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/routing/routes.dart';
import '../../home/admin/data/trainee_model.dart';

class SubscribedUserCard extends StatelessWidget {
  const SubscribedUserCard({
    super.key,
    required this.trainer,
  });

  final TraineeModel trainer;

  @override
  Widget build(BuildContext context) {
    final int days = trainer.remindDays ?? 0;
    final bool isActive = days > 0;
    final String initialChar = (trainer.userName != null && trainer.userName!.trim().isNotEmpty)
        ? trainer.userName!.trim().substring(0, 1).toUpperCase()
        : "?";
    final String phoneDisplay = (trainer.phone != null && trainer.phone!.isNotEmpty)
        ? trainer.phone!
        : (trainer.phoneNumber ?? "بدون رقم");

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isActive
              ? AppColors.newSecondaryColor.withOpacity(0.15)
              : Colors.red.withOpacity(0.2),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.userInfo,
              arguments: trainer,
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Row(
              children: [
                // Avatar / Profile Picture
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.newSecondaryColor.withOpacity(0.85),
                        AppColors.newPrimaryColor.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipOval(
                    child: (trainer.image != null && trainer.image!.isNotEmpty)
                        ? Image.network(
                            ApiEndPoints.usersImagesBaseUrl + trainer.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(
                                initialChar,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initialChar,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Trainee info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.userName ?? "مشترك",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_iphone_rounded,
                            size: 14.sp,
                            color: AppColors.grey,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              phoneDisplay,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (trainer.name != null && trainer.name!.isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        Text(
                          "الباقة: ${trainer.name}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.newSecondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Status Badge & Arrow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xffE8F5E9)
                            : const Color(0xffFFEBEE),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xff4CAF50).withOpacity(0.4)
                              : Colors.red.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? const Color(0xff2E7D32) : Colors.red,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            isActive
                                ? "${AppLocalKeys.active.tr()} ($days د)"
                                : AppLocalKeys.expired.tr(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: isActive ? const Color(0xff2E7D32) : Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.sp,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

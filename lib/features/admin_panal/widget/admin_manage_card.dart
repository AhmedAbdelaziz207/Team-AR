import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';

class AdminManageCard extends StatelessWidget {
  const AdminManageCard({
    super.key,
    this.onTap,
    required this.title,
    this.cardColor,
  });

  final VoidCallback? onTap;
  final String title;

  final Color? cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor ?? AppColors.mediumLavender,
        borderRadius: BorderRadius.circular(16.sp),
      ),
      padding: EdgeInsets.all(16.sp),
      child: Stack(
        children: [
          const Align(
            alignment:  AlignmentDirectional.bottomEnd,
            child: Positioned(
              right: -10,
              bottom: 20,
              child: Icon(
                Icons.fitness_center, // Represents a dumbbell
                size: 80,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      "AR",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cardColor ?? AppColors.mediumLavender,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 8.h),
                  Text("${AppLocalKeys.appName.tr()} $title",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ))
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 21.sp,
                    ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.mediumLavender,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: onTap ?? () {},
                child: Text(
                  AppLocalKeys.seeDetails.tr(),
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cardColor ?? AppColors.mediumLavender,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

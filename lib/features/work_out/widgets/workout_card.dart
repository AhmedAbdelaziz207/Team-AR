import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_assets.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0.sp),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(20),
        ),
        width: double.infinity,
        height: 180,
        child: Stack(
          children: [
            Positioned(
              right: 20.sp,
              bottom: 20.sp,
              child: Opacity(
                opacity: 0.2,
                child: Icon(
                  Icons.fitness_center,
                  size: 80.sp,
                  color: Colors.white,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.0.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 15.sp,
                        child: Image.asset(
                          AppAssets.appLogo,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              size: 20.sp,
                              color: AppColors.teal,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Team AR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  Text(
                    AppLocalKeys.workouts.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),
                  SizedBox(
                    width: 150.w,
                    height: 35.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.exercise);
                      },
                      child: Text(
                        AppLocalKeys.seeDetails.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
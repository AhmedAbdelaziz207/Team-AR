import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_assets.dart';
import '../widgets/workout_card.dart';

class WorkOutScreen extends StatelessWidget {
  const WorkOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('EEEE d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.h),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.white,
          elevation: 0,
          flexibleSpace: Padding(
            padding: EdgeInsets.only(bottom: 2.0.sp),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Stack(children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        AppAssets.appLogo,
                        height: 100.h,
                        width: 100.w,
                        color: AppColors.newPrimaryColor,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          // Prevent extra space
                          children: [
                            Text(todayDate,
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                )),
                            Text(
                              AppLocalKeys.yourJourney.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ]),
                    ],
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Positioned(
                    right: 10,
                    bottom: 35,
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        size: 30.sp,
                      ),
                      onPressed: () {},
                    ),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
      body: const WorkoutCard()

    );

  }
}

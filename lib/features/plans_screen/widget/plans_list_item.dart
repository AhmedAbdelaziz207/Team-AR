import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';
import '../../../core/theme/app_colors.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key, required this.plan});

  final UserPlan plan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: MediaQuery.of(context).size.height * .17,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadiusDirectional.only(
                    bottomStart: Radius.circular(12.r),
                    topStart: Radius.circular(12.r)),
              ),
              child: Center(
                child: Text(
                  plan.name ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryColor),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: MediaQuery.of(context).size.height * .17,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.lightLavender,
                borderRadius: BorderRadiusDirectional.only(
                    bottomEnd: Radius.circular(12.r),
                    topEnd: Radius.circular(12.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        "${plan.price} ${AppLocalKeys.le.tr()}",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16.sp, color: AppColors.primaryColor),
                      ),
                      SizedBox(width: 18.h),
                      Text(
                        "${plan.price} ${AppLocalKeys.le.tr()}",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16.sp,
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.primaryColor.withOpacity(.5),
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(180.w, 40.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(
                          color: AppColors.grey.withOpacity(.3),
                        ),
                      ),
                    ),
                    child: Text(
                      AppLocalKeys.subscribe.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.primaryColor,
                          ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

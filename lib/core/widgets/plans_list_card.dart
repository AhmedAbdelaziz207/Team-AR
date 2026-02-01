import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/manage_plans/widget/plans_dialog.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';
import '../routing/routes.dart';
import '../theme/app_colors.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';

class PlansListCard extends StatelessWidget {
  const PlansListCard({
    super.key,
    required this.plan,
    this.isSelected = false,
    this.isAdmin = false,
    this.backgroundColor,
  });

  final UserPlan plan;
  final bool isSelected;
  final bool isAdmin;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    // color: AppColors.secondaryColor,
                    color: backgroundColor?.withOpacity(.3) ??
                        AppColors.newSecondaryColor.withOpacity(.28),
                    borderRadius: BorderRadiusDirectional.only(
                        bottomStart: Radius.circular(12.r),
                        topStart: Radius.circular(12.r)),
                  ),
                  child: Center(
                    child: Text(
                      plan.name ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w400,
                            color:
                                backgroundColor ?? AppColors.newSecondaryColor,
                          ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    // color: AppColors.secondaryColor,
                    color: backgroundColor?.withOpacity(.2) ??
                        AppColors.dustyGreyColor.withOpacity(.3),
                    borderRadius: BorderRadiusDirectional.only(
                        bottomEnd: Radius.circular(12.r),
                        topEnd: Radius.circular(12.r)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${plan.newPrice} ${AppLocalKeys.le.tr()}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontSize: 16.sp,
                                    color: backgroundColor ??
                                        AppColors.newSecondaryColor,
                                  ),
                            ),
                          ),
                          SizedBox(width: 12.h),
                          Expanded(
                            child: Text(
                              "${plan.oldPrice} ${AppLocalKeys.le.tr()}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontSize: 16.sp,
                                    decoration: TextDecoration.lineThrough,
                                    color: backgroundColor?.withOpacity(.5) ??
                                        AppColors.newSecondaryColor
                                            .withOpacity(.5),
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      if (!isAdmin)
                        FutureBuilder<bool>(
                          future: SharedPreferencesHelper.getBool(
                              AppConstants.isReleased),
                          builder: (context, snapshot) {
                            final isReleased = snapshot.data ?? false;
                            if (!isReleased) return const SizedBox.shrink();
                            return TextButton(
                              onPressed: isSelected
                                  ? null
                                  : () {
                                      Navigator.pushNamed(
                                        context,
                                        Routes.confirmSubscription,
                                        arguments: plan,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(180.w, 40.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: BorderSide(
                                    color: backgroundColor?.withOpacity(.3) ??
                                        AppColors.newSecondaryColor
                                            .withOpacity(.3),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: backgroundColor ??
                                          AppColors.newPrimaryColor,
                                      size: 30,
                                    ),
                                  if (isSelected)
                                    SizedBox(
                                      width: 16.w,
                                    ),
                                  Text(
                                    isSelected
                                        ? AppLocalKeys.subscribed.tr()
                                        : AppLocalKeys.subscribe.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontSize: 16.sp,
                                          color: backgroundColor ??
                                              AppColors.newSecondaryColor,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      if (isAdmin)
                        TextButton(
                          onPressed: isSelected
                              ? null
                              : () {
                                  showPlanDialog(
                                    context,
                                    plan: plan,
                                    isForEdit: true,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(180.w, 40.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(
                                color: AppColors.grey.withOpacity(.3),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalKeys.edit.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontSize: 16.sp,
                                      color: AppColors.primaryColor,
                                    ),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

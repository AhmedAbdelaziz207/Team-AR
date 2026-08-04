import 'package:team_ar/core/utils/app_constants.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/manage_plans/widget/plans_dialog.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';
import '../routing/routes.dart';
import '../theme/app_colors.dart';

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
    final cardColor = backgroundColor ?? AppColors.newSecondaryColor;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    color: backgroundColor?.withOpacity(.25) ?? AppColors.newSecondaryColor.withOpacity(.15),
                    border: BorderDirectional(
                      top: BorderSide(color: cardColor.withOpacity(0.3)),
                      bottom: BorderSide(color: cardColor.withOpacity(0.3)),
                      start: BorderSide(color: cardColor.withOpacity(0.3)),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars_rounded, size: 28.sp, color: cardColor),
                      SizedBox(height: 8.h),
                      Text(
                        plan.name ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: cardColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: cardColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!AppConstants.isReleasedValue)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${plan.newPrice} ${AppLocalKeys.le.tr()}",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                            ),
                            if (plan.oldPrice != null && plan.oldPrice.toString() != "0" && plan.oldPrice != plan.newPrice) ...[
                              SizedBox(width: 10.w),
                              Text(
                                "${plan.oldPrice} ${AppLocalKeys.le.tr()}",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 13.sp,
                                      color: AppColors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      if (!AppConstants.isReleasedValue) SizedBox(height: 16.h),
                      if (!isAdmin)
                        ElevatedButton(
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
                            backgroundColor: isSelected ? Colors.green[50] : cardColor,
                            foregroundColor: isSelected ? Colors.green : Colors.white,
                            elevation: isSelected ? 0 : 2,
                            minimumSize: Size(double.infinity, 42.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isSelected) ...[
                                Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                                SizedBox(width: 8.w),
                              ],
                              Text(
                                AppConstants.isReleasedValue
                                    ? 'اختيار الباقة'
                                    : isSelected
                                        ? AppLocalKeys.subscribed.tr()
                                        : AppLocalKeys.subscribe.tr(),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isAdmin)
                        ElevatedButton.icon(
                          onPressed: () {
                            showPlanDialog(
                              context,
                              plan: plan,
                              isForEdit: true,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                            foregroundColor: AppColors.primaryColor,
                            elevation: 0,
                            minimumSize: Size(double.infinity, 42.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: Icon(Icons.edit_rounded, size: 18.sp, color: AppColors.primaryColor),
                          label: Text(
                            AppLocalKeys.edit.tr(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

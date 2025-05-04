import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/manage_meals_screen/model/meal_model.dart';

class MealItem extends StatelessWidget {
  final DietMealModel? mealModel;

  const MealItem({
    super.key,
    this.mealModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.sp),
                  child: Image.network(
                    ApiEndPoints.imagesBaseUrl + mealModel!.imageURL! ?? "",
                    height: 100.h,
                    width: 100.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      height: 100.h,
                      width: 100.w,
                      child:  const Icon(Icons.broken_image_rounded),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 100.w,
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.newPrimaryColor.withOpacity(0.8),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(10.sp),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${mealModel?.numOfGrams ?? "0"}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          fontFamily: "Cairo",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 25.h,
                  left: 10.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealModel?.name ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        fontFamily: "Cairo",
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.iconCart,
                          width: 20.w,
                          height: 20.h,
                          color: AppColors.newSecondaryColor,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          '${mealModel?.numOfGrams ?? "0"}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Cairo",
                          ),
                        ),
                        SizedBox(width: 4.h),
                        Text(
                          AppLocalKeys.gram.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            fontFamily: "Cairo",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

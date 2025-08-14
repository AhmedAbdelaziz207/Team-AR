import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
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
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.sp),
                child: CachedNetworkImage(
                  imageUrl:
                      ApiEndPoints.imagesBaseUrl + (mealModel?.imageURL ?? ""),
                  height: 100.h,
                  width: 100.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    height: 100.h,
                    width: 100.w,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    height: 100.h,
                    width: 100.w,
                    child: const Icon(Icons.broken_image_rounded),
                  ),
                ),
              ),
              Positioned(
                bottom: 5.h,
                left: 5.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: Text(
                    '${mealModel?.numOfGrams ?? "0"} ${AppLocalKeys.gram.tr()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                      fontFamily: "Cairo",
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealModel?.name ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    fontFamily: "Cairo",
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.black),
                    SizedBox(width: 5.w),
                    Text(
                      '${mealModel?.numOfCalories ?? 0} Kcal',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildMacroInfo(AppLocalKeys.proteins.tr(),
                          '${mealModel?.numOfProtein ?? 0}g'),
                    ),
                    Expanded(
                      child: _buildMacroInfo(AppLocalKeys.fats.tr(),
                          '${mealModel?.numOfFats ?? 0}g'),
                    ),
                    Expanded(
                      child: _buildMacroInfo(AppLocalKeys.carbs.tr(),
                          '${mealModel?.numOfCarbs ?? 0}g'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value) {
    IconData icon;

    if (label == AppLocalKeys.proteins.tr()) {
      icon = Icons.fitness_center;
    } else if (label == AppLocalKeys.fats.tr()) {
      icon = Icons.water_drop;
    } else if (label == AppLocalKeys.carbs.tr()) {
      icon = Icons.bubble_chart;
    } else {
      icon = Icons.circle;
    }

    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.red),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                fontFamily: "Cairo",
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontFamily: "Cairo",
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/manage_meals_screen/model/meal_model.dart';

class UserMealDetails extends StatelessWidget {
  const UserMealDetails({super.key, this.meal});

  final DietMealModel? meal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (below sheet)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: ApiEndPoints.imagesBaseUrl + meal!.imageURL!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 50,
                    ),
                    Text(
                      AppLocalKeys.noImage.tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Draggable Sheet (on top of image)
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 1,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25.r),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (() {
                        final isAr = context.locale.languageCode == 'ar';
                        final arName = meal?.arabicName;
                        final enName = meal?.name;
                        if (isAr) {
                          return (arName != null && arName.isNotEmpty)
                              ? arName
                              : (enName ?? "");
                        }
                        return enName ?? arName ?? "";
                      })(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Cairo",
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      alignment: WrapAlignment.end,
                      children: [
                        _buildNutrientTag(
                          "🔥",
                          meal?.numOfCalories.toString() ??
                              "0 ${AppLocalKeys.calories.tr()}",
                        ),
                        _buildNutrientTag(
                          "🥚",
                          meal?.numOfFats.toString() ??
                              "0 ${AppLocalKeys.fats.tr()}",
                        ),
                        _buildNutrientTag(
                          "🍖",
                          meal?.numOfProtein.toString() ??
                              "0 ${AppLocalKeys.proteins.tr()}",
                        ),
                        _buildNutrientTag(
                          "🌽",
                          meal?.numOfCarbs.toString() ??
                              "0 ${AppLocalKeys.carbs.tr()}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientTag(String emoji, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(width: 6.w),
          Text(
            text == "null" ? "0" : text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }
}

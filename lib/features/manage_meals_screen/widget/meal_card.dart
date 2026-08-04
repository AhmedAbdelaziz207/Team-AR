import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_cubit.dart';
import 'package:team_ar/features/manage_meals_screen/model/meal_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';
import 'diet_meal_dialog.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    this.meal,
  });

  final DietMealModel? meal;

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalKeys.deleteMealTitle.tr()),
          content: Text(AppLocalKeys.deleteMealMessage.tr()),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalKeys.cancel.tr()),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                AppLocalKeys.delete.tr(),
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((confirmDelete) {
      if (confirmDelete == true) {
        context.read<MealCubit>().deleteMeal(meal!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealName = (() {
      final isAr = context.locale.languageCode == 'ar';
      final arName = meal?.arabicName;
      final enName = meal?.name;
      if (isAr) {
        return (arName != null && arName.isNotEmpty)
            ? arName
            : (enName ?? "");
      }
      return enName ?? arName ?? "";
    })();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.softGrey, width: 1),
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
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            showDietMealSheet(context, isForEdit: true, meal: meal);
          },
          onDoubleTap: () {
            _showDeleteDialog(context);
          },
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 85.w,
                  height: 85.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: CachedNetworkImage(
                      imageUrl: ApiEndPoints.imagesBaseUrl + (meal?.imageURL ?? ""),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, error, stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fastfood_rounded, color: Colors.grey[400], size: 30.sp),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mealName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: () => _showDeleteDialog(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: EdgeInsets.all(4.r),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red[400],
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: [
                          buildNutritionPill(
                            AppLocalKeys.calories.tr(),
                            ((meal?.numOfCalories ?? 0) * 100).toStringAsFixed(1),
                            Colors.orange,
                          ),
                          buildNutritionPill(
                            AppLocalKeys.proteins.tr(),
                            ((meal?.numOfProtein ?? 0) * 100).toStringAsFixed(1),
                            Colors.blue,
                          ),
                          buildNutritionPill(
                            AppLocalKeys.carbs.tr(),
                            ((meal?.numOfCarbs ?? 0) * 100).toStringAsFixed(1),
                            Colors.purple,
                          ),
                          buildNutritionPill(
                            AppLocalKeys.fats.tr(),
                            ((meal?.numOfFats ?? 0) * 100).toStringAsFixed(1),
                            Colors.teal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNutritionPill(String title, String value, MaterialColor color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Text(
        "$value $title",
        style: TextStyle(
          color: color[800],
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

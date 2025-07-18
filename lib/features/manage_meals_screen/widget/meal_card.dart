import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_cubit.dart';
import 'package:team_ar/features/manage_meals_screen/model/meal_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    this.meal,
  });

  final DietMealModel? meal;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        context.read<MealCubit>().deleteMeal(meal!.id!);
      },
      background: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        margin: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        padding: EdgeInsets.all(16.r),
        margin: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Image.network(
                  ApiEndPoints.imagesBaseUrl + meal!.imageURL!,
                  width: 100.w,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
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
                        ));
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    meal?.name ?? "",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    children: [
                      Column(
                        children: [
                          buildDetailsItem(
                            AppLocalKeys.calories.tr(),
                            meal?.numOfCalories.toString() ?? "0",
                          ),
                          SizedBox(height: 12.h),
                          buildDetailsItem(
                            AppLocalKeys.proteins.tr(),
                            meal?.numOfProtein.toString() ?? "0",
                          )
                        ],
                      ),
                      Column(
                        children: [
                          buildDetailsItem(
                            AppLocalKeys.carbs.tr(),
                            meal?.numOfCarbs == null
                                ? "0"
                                : meal!.numOfCarbs.toString(),
                          ),
                          SizedBox(height: 12.h),
                          buildDetailsItem(
                            AppLocalKeys.fats.tr(),
                            meal?.numOfFats.toString() ?? "0",
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildDetailsItem(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        "$value $title",
        style: TextStyle(
          color: AppColors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/diet/model/user_diet.dart';
import 'package:team_ar/features/diet/widgets/health_alert.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/app_local_keys.dart';
import 'meal_item.dart';
class MealsList extends StatelessWidget {
  const MealsList({super.key, required this.userDiet});

  final List<UserDiet> userDiet;

  @override
  Widget build(BuildContext context) {
    final double totalCalories = userDiet
        .map((e) => e.meal?.numOfCalories ?? 0)
        .fold(0, (sum, cal) => sum + cal);

    final foodType = userDiet.first.foodType ?? 1;

    return Padding(
      padding: EdgeInsets.all(15.0.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// title
          Text(
            getMealName(foodType),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo",
            ),
          ),
          Text(
            "${userDiet.length} items | $totalCalories calories",
            style: TextStyle(
              color: AppColors.grey.withOpacity(.6),
              fontSize: 12.sp,
              fontFamily: "Cairo",
            ),
          ),

          /// meals
          Column(
            children: userDiet.map((e) {
              final meal = e.meal;
              if (meal == null) return const SizedBox.shrink();
              return InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.mealDetails,
                  arguments: meal,
                ),
                child: MealItem(mealModel: meal),
              );
            }).toList(),
          ),

          /// alert
          if (userDiet.first.note != null && userDiet.first.note!.isNotEmpty)
            HealthAlert(message: userDiet.first.note!),
        ],
      ),
    );
  }

  String getMealName(int foodType) {
    switch (foodType) {
      case 1:
        return AppLocalKeys.firstMeal.tr();
      case 2:
        return AppLocalKeys.secondMeal.tr();
      case 3:
        return AppLocalKeys.thirdMeal.tr();
      case 4:
        return AppLocalKeys.fourthMeal.tr();
      case 5:
        return AppLocalKeys.fifthMeal.tr();
      case 6:
        return AppLocalKeys.sixthMeal.tr();
      default:
        return AppLocalKeys.firstMeal.tr();
    }
  }
}

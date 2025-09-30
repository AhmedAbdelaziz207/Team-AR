import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/manage_meals_screen/model/meal_model.dart';
import 'package:team_ar/features/select_meals/widgets/selected_meal_card.dart';
import 'package:team_ar/features/select_meals/widgets/natural_supplement_card.dart';
import '../../../core/theme/app_colors.dart';

class MealCategory extends StatelessWidget {
  final String title;
  final List<DietMealModel> meals;

  const MealCategory({
    super.key,
    required this.title,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      title: Text(
        title.tr(),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.black,
          fontSize: 14.sp,
        ),
      ),
      initiallyExpanded: title == AppLocalKeys.proteins.tr(),
      iconColor: AppColors.black,
      collapsedIconColor: AppColors.black,
      children: meals.map(
            (meal) => meal.foodCategory == 4
                ? NaturalSupplementCard(
                    key: ValueKey(meal.id),
                    meal: meal,
                  )
                : SelectMealCard(
                    key: ValueKey(meal.id),
                    meal: meal,
                  ),
      ).toList(),
    );
  }
}

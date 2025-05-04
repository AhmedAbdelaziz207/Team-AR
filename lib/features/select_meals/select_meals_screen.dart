import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_cubit.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_state.dart';
import 'package:team_ar/features/select_meals/model/select_meal_params.dart';
import 'package:team_ar/features/select_meals/widgets/meal_footer.dart';
import 'package:team_ar/features/select_meals/widgets/meals_list.dart';
import '../../core/theme/app_colors.dart';

class SelectMealsScreen extends StatelessWidget {
  const SelectMealsScreen({
    super.key,
    this.params,
  });

  final SelectMealParams? params ;
  @override
  Widget build(BuildContext context) {
    context.read<MealCubit>().mealNum = params!.mealNum;

    log("meal num: ${params!.mealNum}");

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          AppLocalKeys.selectMeals.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontSize: 24.sp,
              ),
        ),
        centerTitle: false,
        elevation: 0,
        leading: const AppBarBackButton(),
        backgroundColor: AppColors.white,
        actions: [
          BlocBuilder<MealCubit, MealState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "${context.read<MealCubit>().mealNum}/5",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Expanded(
            child: MealList(),
          ),
          MealSummaryFooter(userId: params!.userId),
        ],
      ),
    );
  }
}

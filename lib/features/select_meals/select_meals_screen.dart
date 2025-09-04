import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  final SelectMealParams? params;

  @override
  Widget build(BuildContext context) {
    // Initialize meal number from params and ensure name is in sync
    final cubit = context.read<MealCubit>();
    cubit.mealNum = params!.mealNum;
    cubit.mealName = cubit.getMealName(cubit.mealNum);

    log("meal num: ${params!.mealNum}");

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: BlocBuilder<MealCubit, MealState>(
          builder: (context, state) {
            final c = context.read<MealCubit>();
            return Text(
              "${c.mealName} ",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontSize: 24.sp,
                  ),
            );
          },
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
          MealSummaryFooter(
            userId: params!.userId,
            isUpdate: params!.isUpdate ?? false,
          ),
        ],
      ),
    );
  }
}

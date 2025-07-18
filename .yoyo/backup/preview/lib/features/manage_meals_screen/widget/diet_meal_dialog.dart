import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_state.dart';
import 'package:team_ar/features/manage_meals_screen/model/meal_model.dart';
import 'package:team_ar/features/manage_meals_screen/widget/meal_type_dropdown.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../logic/meal_cubit.dart';

showDietMealSheet(context, {isForEdit = false, DietMealModel? meal}) {
  final formKey = GlobalKey<FormState>();
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    builder: (context) {
      return BlocProvider(
        create: (context) => MealCubit(),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalKeys.addMeal.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: BlocBuilder<MealCubit, MealState>(
                      builder: (context, state) {
                        return InkWell(
                          onTap: () {
                            context.read<MealCubit>().pickImage();
                          },
                          child: CircleAvatar(
                              radius: 40.r,
                              backgroundColor: AppColors.primaryColor,
                              child: const Icon(
                                Icons.fastfood,
                                color: AppColors.white,
                              )),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  CustomTextFormField(
                    suffixIcon: Icons.fastfood,
                    controller: context.read<MealCubit>().nameController,
                    hintText: AppLocalKeys.name.tr(),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  CustomTextFormField(
                    suffixIcon: Icons.propane_tank,
                    controller: context.read<MealCubit>().caloriesController,
                    hintText: AppLocalKeys.numOfCalories.tr(),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  CustomTextFormField(
                    controller: context.read<MealCubit>().carbsController,
                    hintText: AppLocalKeys.numOfCarbs.tr(),
                    keyboardType: const TextInputType.numberWithOptions(),
                    suffixIcon: Icons.propane,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  CustomTextFormField(
                    controller: context.read<MealCubit>().proteinController,
                    hintText: AppLocalKeys.numOfProteins.tr(),
                    keyboardType: const TextInputType.numberWithOptions(),
                    suffixIcon: Icons.propane_tank,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  CustomTextFormField(
                    controller: context.read<MealCubit>().fatController,
                    hintText: AppLocalKeys.numOfFat.tr(),
                    keyboardType: const TextInputType.numberWithOptions(),
                    suffixIcon: Icons.propane,
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: BlocBuilder<MealCubit, MealState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppLocalKeys.save.tr(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 21.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

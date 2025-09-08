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

showDietMealSheet(BuildContext context, {bool isForEdit = false, DietMealModel? meal}) {
  final formKey = GlobalKey<FormState>();
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    builder: (context) {
      // Try to reuse existing MealCubit if available; otherwise create a new one for the sheet
      MealCubit? existingCubit;
      bool provideExisting = false;
      try {
        existingCubit = context.read<MealCubit>();
        provideExisting = true;
      } catch (_) {
        provideExisting = false;
      }

      void prefill(MealCubit c) {
        if (isForEdit && meal != null) {
          final shouldPrefill =
              c.nameController.text.isEmpty &&
              c.arabicNameController.text.isEmpty &&
              c.caloriesController.text.isEmpty &&
              c.carbsController.text.isEmpty &&
              c.proteinController.text.isEmpty &&
              c.fatController.text.isEmpty;

          if (shouldPrefill) {
            c.nameController.text = meal.name ?? '';
            c.arabicNameController.text = meal.arabicName ?? '';
            c.caloriesController.text = ((meal.numOfCalories ?? 0) * 100).toStringAsFixed(1);
            c.carbsController.text = ((meal.numOfCarbs ?? 0) * 100).toStringAsFixed(1);
            c.proteinController.text = ((meal.numOfProtein ?? 0) * 100).toStringAsFixed(1);
            c.fatController.text = ((meal.numOfFats ?? 0) * 100).toStringAsFixed(1);
            c.mealType = meal.foodCategory ?? c.mealType;
          }
        }
      }

      Widget sheet(MealCubit c) {
        prefill(c);
        return Container(
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
                    isForEdit ? AppLocalKeys.edit.tr() : AppLocalKeys.addMeal.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  if (!isForEdit)
                    Align(
                      alignment: Alignment.center,
                      child: BlocBuilder<MealCubit, MealState>(
                        builder: (context, state) {
                          return InkWell(
                            onTap: () {
                              c.pickImage();
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
                    controller: c.nameController,
                    hintText: AppLocalKeys.name.tr(),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  CustomTextFormField(
                    suffixIcon: Icons.translate,
                    controller: c.arabicNameController,
                    hintText: 'Arabic name',
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  CustomTextFormField(
                    suffixIcon: Icons.propane_tank,
                    controller: c.caloriesController,
                    hintText: AppLocalKeys.numOfCalories.tr(),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  CustomTextFormField(
                    controller: c.carbsController,
                    hintText: AppLocalKeys.numOfCarbs.tr(),
                    keyboardType: const TextInputType.numberWithOptions(),
                    suffixIcon: Icons.propane,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  CustomTextFormField(
                    controller: c.proteinController,
                    hintText: AppLocalKeys.numOfProteins.tr(),
                    keyboardType: const TextInputType.numberWithOptions(),
                    suffixIcon: Icons.propane_tank,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  CustomTextFormField(
                    controller: c.fatController,
                    hintText: AppLocalKeys.numOfFat.tr(),
                    keyboardType: const TextInputType.numberWithOptions(),
                    suffixIcon: Icons.propane,
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  MealTypeDropdown(
                    onChanged: (v) => c.mealType = v,
                  ),
                  SizedBox(
                  
                    height: 12.h,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: BlocBuilder<MealCubit, MealState>(
                      builder: (context, state) {
                        final isLoading = state is MailLoading;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (isForEdit && meal != null) {
                                      await c.updateMeal(
                                        meal.copyWith(
                                          name: c.nameController.text,
                                          numOfCalories: double.tryParse(c.caloriesController.text) != null
                                              ? double.parse(c.caloriesController.text) / 100
                                              : meal.numOfCalories,
                                          numOfCarbs: double.tryParse(c.carbsController.text) != null
                                              ? double.parse(c.carbsController.text) / 100
                                              : meal.numOfCarbs,
                                          numOfProtein: double.tryParse(c.proteinController.text) != null
                                              ? double.parse(c.proteinController.text) / 100
                                              : meal.numOfProtein,
                                          numOfFats: double.tryParse(c.fatController.text) != null
                                              ? double.parse(c.fatController.text) / 100
                                              : meal.numOfFats,
                                          foodCategory: c.mealType,
                                        ),
                                      );
                                    } else {
                                      await c.addMeal();
                                    }
                                    if (context.mounted) Navigator.pop(context);
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Text(
                                    AppLocalKeys.save.tr(),
                                  ),
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
        );
      }

      if (provideExisting && existingCubit != null) {
        return BlocProvider.value(
          value: existingCubit,
          child: sheet(existingCubit),
        );
      } else {
        return BlocProvider(
          create: (_) => MealCubit(),
          child: Builder(
            builder: (innerCtx) => sheet(innerCtx.read<MealCubit>()),
          ),
        );
      }
    },
  );
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/manage_meals_screen/widget/meal_type_dropdown.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../logic/meal_cubit.dart';
import '../logic/meal_state.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalKeys.addMeal.tr(),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Container(
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
                            radius: 60.r,
                            backgroundColor: AppColors.primaryColor,
                            backgroundImage: state is ImagePicked
                                ? FileImage(state.image)
                                : null,
                            child: state is ImagePicked
                                ? null
                                : const Icon(
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
                  suffixIcon: Icons.translate,
                  controller: context.read<MealCubit>().arabicNameController,
                  hintText: 'Arabic name',
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
                MealTypeDropdown(
                  onChanged: (type) {
                    context.read<MealCubit>().mealType = type;
                  },
                ),
                SizedBox(
                  height: 30.h,
                ),
                Align(
                  alignment: Alignment.center,
                  child: BlocConsumer<MealCubit, MealState>(
                    listener: (context, state) {
                      if (state is MailAdded) {
                        Navigator.pop(context);
                      }
                      if (state is MealFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: AppColors.red,
                          content: Text(
                            state.message,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.white),
                          ),
                        ));
                      }
                    },
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate() &&
                              context.read<MealCubit>().image != null) {
                            context.read<MealCubit>().addMeal();
                          }

                          if (context.read<MealCubit>().image == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: AppColors.red,
                              content: Text(
                                AppLocalKeys.pleaseSelectImage.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.white),
                              ),
                            ));
                          }
                        },
                        child: state is MailLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.white,
                              )
                            : Text(
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
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/custom_text_form_field.dart';
import 'package:team_ar/features/complete_data/logic/complete_data_cubit.dart';

class CompleteDataScreen extends StatelessWidget {
  const CompleteDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CompleteDataCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalKeys.enterYourInfo.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: BlocConsumer<CompleteDataCubit, CompleteDataState>(
            listener: (context, state) {
              if (state.status == CompleteDataStatus.failure &&
                  state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!)),
                );
              }
              if (state.status == CompleteDataStatus.success) {
                Navigator.pushNamedAndRemoveUntil(
                    context, Routes.rootScreen, (route) => false);
              }
            },
            builder: (context, state) {
              return Form(
                key: cubit.formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    SizedBox(height: 16.h),
                      // Username, Email, Password are intentionally HIDDEN per requirement
                      
                      CustomTextFormField(
                        controller: cubit.phoneController,
                        suffixIcon: Icons.phone,
                        hintText: AppLocalKeys.phone.tr(),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: cubit.addressController,
                        suffixIcon: Icons.location_on,
                        hintText: AppLocalKeys.address.tr(),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              controller: cubit.heightController,
                              hintText: AppLocalKeys.height.tr(),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: CustomTextFormField(
                              controller: cubit.weightController,
                              hintText: AppLocalKeys.weight.tr(),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      // Gender simple input (string)
                      CustomTextFormField(
                        controller: cubit.genderController,
                        hintText: AppLocalKeys.gender.tr(),
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: cubit.numberOfDaysController,
                        hintText: AppLocalKeys.numberOfDaysForTraining.tr(),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: cubit.numberOfMealsController,
                        hintText: AppLocalKeys.numberOfMeals.tr(),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: cubit.areYouSmokerController,
                        hintText: AppLocalKeys.areYouSmoking.tr(),
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: cubit.lastExerciseController,
                        hintText: AppLocalKeys.lastTimeTrained.tr(),
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: cubit.aimOfJoinController,
                        hintText: AppLocalKeys.aimOfJoin.tr(),
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: cubit.anyPainsController,
                        hintText: AppLocalKeys.haveAnyPain.tr(),
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: cubit.dailyWorkController,
                        hintText: AppLocalKeys.aboutYourWork.tr(),
                        isMultiline: true,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: cubit.allergyOfFoodController,
                        hintText: AppLocalKeys.allergyOfFood.tr(),
                        isMultiline: true,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: cubit.foodSystemController,
                        hintText: AppLocalKeys.whatYouWantInFood.tr(),
                        isMultiline: true,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: cubit.anyInfectionController,
                        hintText: AppLocalKeys.haveInfection.tr(),
                        isMultiline: true,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: cubit.abilityOfSystemMoneyController,
                        hintText: 'Ability Of System Money',
                        isMultiline: true,
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.status == CompleteDataStatus.loading
                              ? null
                              : () => cubit.submit(),
                          child: state.status == CompleteDataStatus.loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(AppLocalKeys.save.tr()),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

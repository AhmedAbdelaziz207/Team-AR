import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/custom_text_form_field.dart';
import 'package:team_ar/features/complete_data/logic/complete_data_cubit.dart';

class CompleteDataScreen extends StatefulWidget {
  const CompleteDataScreen({super.key});

  @override
  State<CompleteDataScreen> createState() => _CompleteDataScreenState();
}

class _CompleteDataScreenState extends State<CompleteDataScreen> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CompleteDataCubit>();
    // Default values if empty
    if (cubit.genderController.text.isEmpty) {
      cubit.genderController.text = 'Male';
    }
    if (cubit.areYouSmokerController.text.isEmpty) {
      cubit.areYouSmokerController.text = 'No';
    }
  }

  void _nextStep(CompleteDataCubit cubit) {
    // Validate current step
    bool isValid = false;
    if (_currentStep == 0) {
      isValid = cubit.phoneController.text.isNotEmpty &&
          cubit.addressController.text.isNotEmpty &&
          cubit.heightController.text.isNotEmpty &&
          cubit.weightController.text.isNotEmpty;
    } else if (_currentStep == 1) {
      isValid = cubit.numberOfDaysController.text.isNotEmpty &&
          cubit.numberOfMealsController.text.isNotEmpty &&
          cubit.aimOfJoinController.text.isNotEmpty;
    } else {
      isValid = true; // final step validation happens on submit
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalKeys.pleaseEnterYourPhone
                .tr())), // Use a generic error or the original
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      cubit.submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CompleteDataCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalKeys.enterYourInfo.tr(),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: AppColors.white,
      body: SafeArea(
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
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                      primary: AppColors.newPrimaryColor),
                ),
                child: Stepper(
                  type: StepperType.horizontal,
                  elevation: 0,
                  currentStep: _currentStep,
                  onStepCancel: _prevStep,
                  onStepContinue: () => _nextStep(cubit),
                  onStepTapped: (step) {
                    if (step < _currentStep) {
                      setState(() => _currentStep = step);
                    }
                  },
                  controlsBuilder: (context, details) {
                    final isLastStep = _currentStep == 2;
                    final isLoading =
                        state.status == CompleteDataStatus.loading;
                    return Container(
                      margin: EdgeInsets.only(top: 30.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  isLoading ? null : details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.newPrimaryColor,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      isLastStep
                                          ? AppLocalKeys.submit.tr()
                                          : AppLocalKeys.next.tr(),
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                            ),
                          ),
                          if (_currentStep > 0) ...[
                            SizedBox(width: 12.w),
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    isLoading ? null : details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  side: const BorderSide(
                                      color: AppColors.newPrimaryColor),
                                ),
                                child: Text(
                                  AppLocalKeys.previous.tr(),
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: AppColors.newPrimaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: Text(AppLocalKeys.personalInfo.tr(),
                          style: TextStyle(fontSize: 12.sp)),
                      state: _currentStep > 0
                          ? StepState.complete
                          : StepState.indexed,
                      isActive: _currentStep >= 0,
                      content: _buildPersonalInfoStep(cubit),
                    ),
                    Step(
                      title: Text(AppLocalKeys.activityInfo.tr(),
                          style: TextStyle(fontSize: 12.sp)),
                      state: _currentStep > 1
                          ? StepState.complete
                          : StepState.indexed,
                      isActive: _currentStep >= 1,
                      content: _buildActivityInfoStep(cubit),
                    ),
                    Step(
                      title: Text(AppLocalKeys.healthInfo.tr(),
                          style: TextStyle(fontSize: 12.sp)),
                      isActive: _currentStep >= 2,
                      content: _buildHealthInfoStep(cubit),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep(CompleteDataCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          key: const ValueKey('phone'),
          controller: cubit.phoneController,
          suffixIcon: Icons.phone_outlined,
          hintText: AppLocalKeys.phone.tr(),
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16.h),
        CustomTextFormField(
          key: const ValueKey('address'),
          controller: cubit.addressController,
          suffixIcon: Icons.location_on_outlined,
          hintText: AppLocalKeys.address.tr(),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                key: const ValueKey('height'),
                controller: cubit.heightController,
                hintText: "${AppLocalKeys.height.tr()} (cm)",
                keyboardType: TextInputType.number,
                suffixIcon: Icons.height,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomTextFormField(
                key: const ValueKey('weight'),
                controller: cubit.weightController,
                hintText: "${AppLocalKeys.weight.tr()} (kg)",
                keyboardType: TextInputType.number,
                suffixIcon: Icons.monitor_weight_outlined,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Text(AppLocalKeys.gender.tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text(AppLocalKeys.male.tr()),
                value: 'Male',
                groupValue: cubit.genderController.text,
                activeColor: AppColors.newPrimaryColor,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() => cubit.genderController.text = value!);
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text(AppLocalKeys.female.tr()),
                value: 'Female',
                groupValue: cubit.genderController.text,
                activeColor: AppColors.newPrimaryColor,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() => cubit.genderController.text = value!);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityInfoStep(CompleteDataCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          key: const ValueKey('aimOfJoin'),
          controller: cubit.aimOfJoinController,
          hintText: AppLocalKeys.aimOfJoin.tr(),
          suffixIcon: Icons.flag_outlined,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                key: const ValueKey('numberOfDays'),
                controller: cubit.numberOfDaysController,
                hintText: AppLocalKeys.numberOfDaysForTraining.tr(),
                keyboardType: TextInputType.number,
                suffixIcon: Icons.calendar_today_outlined,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomTextFormField(
                key: const ValueKey('numberOfMeals'),
                controller: cubit.numberOfMealsController,
                hintText: AppLocalKeys.numberOfMeals.tr(),
                keyboardType: TextInputType.number,
                suffixIcon: Icons.restaurant_outlined,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        CustomTextFormField(
          key: const ValueKey('lastExercise'),
          controller: cubit.lastExerciseController,
          hintText: AppLocalKeys.lastTimeTrained.tr(),
          suffixIcon: Icons.history,
        ),
      ],
    );
  }

  Widget _buildHealthInfoStep(CompleteDataCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalKeys.areYouSmoking.tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text(AppLocalKeys.yes.tr()),
                value: 'Yes',
                groupValue: cubit.areYouSmokerController.text,
                activeColor: AppColors.newPrimaryColor,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() => cubit.areYouSmokerController.text = value!);
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text(AppLocalKeys.no.tr()),
                value: 'No',
                groupValue: cubit.areYouSmokerController.text,
                activeColor: AppColors.newPrimaryColor,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() => cubit.areYouSmokerController.text = value!);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        CustomTextFormField(
          key: const ValueKey('anyPains'),
          controller: cubit.anyPainsController,
          hintText: AppLocalKeys.haveAnyPain.tr(),
          isMultiline: true,
        ),
        SizedBox(height: 12.h),
        CustomTextFormField(
          key: const ValueKey('anyInfection'),
          controller: cubit.anyInfectionController,
          hintText: AppLocalKeys.haveInfection.tr(),
          isMultiline: true,
        ),
        SizedBox(height: 12.h),
        CustomTextFormField(
          key: const ValueKey('allergyOfFood'),
          controller: cubit.allergyOfFoodController,
          hintText: AppLocalKeys.allergyOfFood.tr(),
          isMultiline: true,
        ),
        SizedBox(height: 12.h),
        CustomTextFormField(
          key: const ValueKey('foodSystem'),
          controller: cubit.foodSystemController,
          hintText: AppLocalKeys.whatYouWantInFood.tr(),
          isMultiline: true,
        ),
        SizedBox(height: 12.h),
        CustomTextFormField(
          key: const ValueKey('dailyWork'),
          controller: cubit.dailyWorkController,
          hintText: AppLocalKeys.aboutYourWork.tr(),
          isMultiline: true,
        ),
        SizedBox(height: 12.h),
        CustomTextFormField(
          key: const ValueKey('abilityOfSystemMoney'),
          controller: cubit.abilityOfSystemMoneyController,
          hintText: AppLocalKeys.abilityOfSystemMoney.tr(),
        ),
      ],
    );
  }
}

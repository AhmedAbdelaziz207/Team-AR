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

  bool _showAnyPains = false;
  bool _showAnyInfection = false;
  bool _showAllergyOfFood = false;

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

    _showAnyPains = cubit.anyPainsController.text.isNotEmpty;
    _showAnyInfection = cubit.anyInfectionController.text.isNotEmpty;
    _showAllergyOfFood = cubit.allergyOfFoodController.text.isNotEmpty;
  }

  void _nextStep(CompleteDataCubit cubit) {
    if (_currentStep == 0) {
      final isValid = cubit.phoneController.text.trim().isNotEmpty &&
          cubit.addressController.text.trim().isNotEmpty &&
          cubit.heightController.text.trim().isNotEmpty &&
          cubit.weightController.text.trim().isNotEmpty;
      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalKeys.pleaseEnterAllRequiredFields.tr(),
              style: const TextStyle(fontFamily: "Cairo"),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      final isValid = cubit.numberOfDaysController.text.trim().isNotEmpty &&
          cubit.numberOfMealsController.text.trim().isNotEmpty &&
          cubit.aimOfJoinController.text.trim().isNotEmpty;
      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalKeys.pleaseEnterAllRequiredFields.tr(),
              style: const TextStyle(fontFamily: "Cairo"),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
        return;
      }
      setState(() => _currentStep = 2);
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: "Cairo",
              ),
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
                SnackBar(
                  content: Text(
                    state.error!,
                    style: const TextStyle(fontFamily: "Cairo"),
                  ),
                  backgroundColor: Colors.red[700],
                ),
              );
            }
            if (state.status == CompleteDataStatus.success) {
              Navigator.pushNamedAndRemoveUntil(
                  context, Routes.rootScreen, (route) => false);
            }
          },
          builder: (context, state) {
            final isLoading = state.status == CompleteDataStatus.loading;
            final isLastStep = _currentStep == 2;

            return Form(
              key: cubit.formKey,
              child: Column(
                children: [
                  _buildStepIndicator(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_currentStep == 0) _buildPersonalInfoStep(cubit),
                          if (_currentStep == 1) _buildActivityInfoStep(cubit),
                          if (_currentStep == 2) _buildHealthInfoStep(cubit),
                          SizedBox(height: 28.h),
                          _buildBottomButtons(cubit, isLoading, isLastStep),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final stepTitles = [
      AppLocalKeys.personalInfo.tr(),
      AppLocalKeys.activityInfo.tr(),
      AppLocalKeys.healthInfo.tr(),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(stepTitles.length, (index) {
          final isCompleted = _currentStep > index;
          final isCurrent = _currentStep == index;
          final isClickable = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: isClickable
                        ? () => setState(() => _currentStep = index)
                        : null,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green
                                : (isCurrent
                                    ? AppColors.newPrimaryColor
                                    : Colors.grey[200]),
                            shape: BoxShape.circle,
                            border: isCurrent
                                ? Border.all(
                                    color: AppColors.newPrimaryColor
                                        .withValues(alpha: 0.3),
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: isCompleted
                                ? Icon(Icons.check,
                                    size: 18.sp, color: Colors.white)
                                : Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      color: isCurrent
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                      fontFamily: "Cairo",
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            stepTitles[index],
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontFamily: "Cairo",
                              color: isCurrent
                                  ? AppColors.newPrimaryColor
                                  : (isCompleted
                                      ? Colors.black87
                                      : Colors.grey[500]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < stepTitles.length - 1)
                  Container(
                    width: 16.w,
                    height: 2.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    color: _currentStep > index
                        ? Colors.green
                        : Colors.grey[300],
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomButtons(
      CompleteDataCubit cubit, bool isLoading, bool isLastStep) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _nextStep(cubit),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newPrimaryColor,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isLastStep
                        ? AppLocalKeys.submit.tr()
                        : AppLocalKeys.next.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: "Cairo",
                    ),
                  ),
          ),
        ),
        if (_currentStep > 0) ...[
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : _prevStep,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                side: const BorderSide(color: AppColors.newPrimaryColor),
              ),
              child: Text(
                AppLocalKeys.previous.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.newPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
                ),
              ),
            ),
          ),
        ],
      ],
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, fontFamily: "Cairo")),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text(AppLocalKeys.male.tr(), style: const TextStyle(fontFamily: "Cairo")),
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
                title: Text(AppLocalKeys.female.tr(), style: const TextStyle(fontFamily: "Cairo")),
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
          validator: (value) => null,
        ),
      ],
    );
  }

  Widget _buildHealthInfoStep(CompleteDataCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalKeys.areYouSmoking.tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, fontFamily: "Cairo")),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text(AppLocalKeys.yes.tr(), style: const TextStyle(fontFamily: "Cairo")),
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
                title: Text(AppLocalKeys.no.tr(), style: const TextStyle(fontFamily: "Cairo")),
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
        _buildYesNoField(
          title: AppLocalKeys.haveAnyPain.tr(),
          showDetails: _showAnyPains,
          onChanged: (value) {
            setState(() {
              _showAnyPains = value ?? false;
              if (!_showAnyPains) {
                cubit.anyPainsController.clear();
              }
            });
          },
          detailsController: cubit.anyPainsController,
          keyName: 'anyPains',
        ),
        SizedBox(height: 12.h),
        _buildYesNoField(
          title: AppLocalKeys.haveInfection.tr(),
          showDetails: _showAnyInfection,
          onChanged: (value) {
            setState(() {
              _showAnyInfection = value ?? false;
              if (!_showAnyInfection) {
                cubit.anyInfectionController.clear();
              }
            });
          },
          detailsController: cubit.anyInfectionController,
          keyName: 'anyInfection',
        ),
        SizedBox(height: 12.h),
        _buildYesNoField(
          title: AppLocalKeys.allergyOfFood.tr(),
          showDetails: _showAllergyOfFood,
          onChanged: (value) {
            setState(() {
              _showAllergyOfFood = value ?? false;
              if (!_showAllergyOfFood) {
                cubit.allergyOfFoodController.clear();
              }
            });
          },
          detailsController: cubit.allergyOfFoodController,
          keyName: 'allergyOfFood',
        ),
        SizedBox(height: 12.h),
        CustomTextFormField(
          key: const ValueKey('foodSystem'),
          controller: cubit.foodSystemController,
          hintText: AppLocalKeys.whatYouWantInFood.tr(),
          isMultiline: true,
          validator: (value) => null,
        ),
        SizedBox(height: 12.h),
        CustomTextFormField(
          key: const ValueKey('dailyWork'),
          controller: cubit.dailyWorkController,
          hintText: AppLocalKeys.aboutYourWork.tr(),
          isMultiline: true,
          validator: (value) => null,
        ),
        SizedBox(height: 12.h),
        CustomTextFormField(
          key: const ValueKey('abilityOfSystemMoney'),
          controller: cubit.abilityOfSystemMoneyController,
          hintText: AppLocalKeys.abilityOfSystemMoney.tr(),
          validator: (value) => null,
        ),
      ],
    );
  }

  Widget _buildYesNoField({
    required String title,
    required bool showDetails,
    required ValueChanged<bool?> onChanged,
    required TextEditingController detailsController,
    required String keyName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, fontFamily: "Cairo")),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: Text(AppLocalKeys.yes.tr(), style: const TextStyle(fontFamily: "Cairo")),
                value: true,
                groupValue: showDetails,
                activeColor: AppColors.newPrimaryColor,
                contentPadding: EdgeInsets.zero,
                onChanged: onChanged,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: Text(AppLocalKeys.no.tr(), style: const TextStyle(fontFamily: "Cairo")),
                value: false,
                groupValue: showDetails,
                activeColor: AppColors.newPrimaryColor,
                contentPadding: EdgeInsets.zero,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        if (showDetails) ...[
          SizedBox(height: 8.h),
          CustomTextFormField(
            key: ValueKey(keyName),
            controller: detailsController,
            hintText: 'التفاصيل (يرجى التوضيح)',
            isMultiline: true,
            validator: (value) => null,
          ),
        ],
      ],
    );
  }
}

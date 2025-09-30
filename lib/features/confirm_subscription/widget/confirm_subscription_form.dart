import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/app_local_keys.dart';
import '../../../core/widgets/custom_text_form_field.dart';
import '../logic/confirm_subscription_cubit.dart';
import 'gender_selection_widget.dart';

class ConfirmSubscriptionForm extends StatelessWidget {
  const ConfirmSubscriptionForm({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConfirmSubscriptionCubit>();
    // final isAdmin = context.watch<ConfirmSubscriptionCubit>().isAdmin;

    return Form(
      key: cubit.formKey,
      child: Column(
        children: [
          CustomTextFormField(
            controller: cubit.nameController,
            suffixIcon: Icons.person,
            hintText: AppLocalKeys.userName.tr(),
            validator: (value) {

                final regex = RegExp(r'^[a-zA-Z0-9]+$');
                 if (!regex.hasMatch(value!)) {
                  return '${AppLocalKeys.userName.tr()} ${AppLocalKeys.mustBeAlphanumeric.tr()}';
                }

            },
          ),
          SizedBox(height: 8.h),
          // If admin: only keep email and password after username
          if (true) ...[
            CustomTextFormField(
              controller: cubit.emailController,
              suffixIcon: Icons.email_outlined,
              hintText: AppLocalKeys.email.tr(),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h),
            CustomTextFormField(
              controller: cubit.passwordController,
              suffixIcon: Icons.password,
              hintText: AppLocalKeys.password.tr(),
              obscureText: true,
            ),
          ] else ...[
        //   CustomTextFormField(
        //     controller: cubit.ageController,
        //     suffixIcon: Icons.event_note,
        //     hintText: AppLocalKeys.age.tr(),
        //     keyboardType: TextInputType.number,
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.phoneController,
        //     suffixIcon: Icons.phone,
        //     hintText: AppLocalKeys.phone.tr(),
        //     keyboardType: TextInputType.phone,
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.addressController,
        //     suffixIcon: Icons.location_on,
        //     hintText: AppLocalKeys.address.tr(),
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.emailController,
        //     suffixIcon: Icons.email_outlined,
        //     hintText: AppLocalKeys.email.tr(),
        //     keyboardType: TextInputType.emailAddress,
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.passwordController,
        //     suffixIcon: Icons.password,
        //     hintText: AppLocalKeys.password.tr(),
        //     obscureText: true,
        //   ),
        //   SizedBox(height: 16.h),
        //   Row(
        //     children: [
        //       Expanded(
        //         child: CustomTextFormField(
        //           controller: cubit.heightController,
        //           hintText: AppLocalKeys.height.tr(),
        //           keyboardType: TextInputType.number,
        //         ),
        //       ),
        //       SizedBox(width: 8.w),
        //       Expanded(
        //         child: CustomTextFormField(
        //           controller: cubit.weightController,
        //           hintText: AppLocalKeys.weight.tr(),
        //           keyboardType: TextInputType.number,
        //         ),
        //       ),
        //     ],
        //   ),
        //   SizedBox(height: 16.h),
        //   GenderSelection(onGenderSelected: (value) {
        //     cubit.genderController.text = value;
        //   }),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.trainingDaysController,
        //     hintText: AppLocalKeys.numberOfDaysForTraining.tr(),
        //     keyboardType: TextInputType.number,
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.numberOfMealsController,
        //     hintText: AppLocalKeys.numberOfMeals.tr(),
        //     keyboardType: TextInputType.number,
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.smokingController,
        //     hintText: AppLocalKeys.areYouSmoking.tr(),
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.lastTrainedController,
        //     hintText: AppLocalKeys.lastTimeTrained.tr(),
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.aimOfJoinController,
        //     hintText: AppLocalKeys.aimOfJoin.tr(),
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.painController,
        //     hintText: AppLocalKeys.haveAnyPain.tr(),
        //     isMultiline: false,
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.dailyWorkController,
        //     hintText: AppLocalKeys.aboutYourWork.tr(),
        //     isMultiline: true,
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.allergyController,
        //     hintText: AppLocalKeys.allergyOfFood.tr(),
        //     isMultiline: true,
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.foodSystemController,
        //     hintText: AppLocalKeys.whatYouWantInFood.tr(),
        //     isMultiline: true,
        //   ),
        //   SizedBox(height: 16.h),
        //   CustomTextFormField(
        //     controller: cubit.infectionController,
        //     hintText: AppLocalKeys.haveInfection.tr(),
        //     isMultiline: true,
        //   ),
          ]
        ],
      ),
    );
  }
}

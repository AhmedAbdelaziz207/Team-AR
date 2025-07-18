import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/core/widgets/custom_text_form_field.dart';
import 'package:team_ar/features/auth/register/logic/register_cubit.dart';
import 'package:team_ar/features/auth/register/logic/register_state.dart';
import 'package:team_ar/features/confirm_subscription/widget/register_bloc_listener.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.mediumLavender,
        toolbarHeight: 100.h,
        title: Text(
          AppLocalKeys.register.tr(),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.white),
        ),
        leading: const AppBarBackButton(
          color: AppColors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: context.read<RegisterCubit>().formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 50.h,
                ),
                Text(
                  AppLocalKeys.createYourAccount.tr(),
                  // Additional caption above the form
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 21.sp,
                      ),
                ),
                SizedBox(
                  height: 21.h,
                ),
                CustomTextFormField(
                  hintText: AppLocalKeys.email.tr(),
                  suffixIcon: Icons.email,
                ),
                SizedBox(
                  height: 21.h,
                ),
                CustomTextFormField(
                  hintText: AppLocalKeys.password.tr(),
                  suffixIcon: Icons.lock,
                ),
                SizedBox(
                  height: 21.h,
                ),
                CustomTextFormField(
                  hintText: AppLocalKeys.confirmPassword.tr(),
                  suffixIcon: Icons.lock,
                ),
                SizedBox(
                  height: 60.h,
                ),
                BlocBuilder<RegisterCubit, RegisterState>(
                  builder: (context, state) {
                    return state is RegisterLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          )
                        : TextButton(
                            onPressed: state is RegisterLoading ? null : () {
                              if(context.read<RegisterCubit>().formKey.currentState!.validate()){
                                context.read<RegisterCubit>().addTrainer();
                              }

                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(250.w, 30.h),
                              backgroundColor:
                                  AppColors.primaryColor.withOpacity(.8),
                            ),
                            child: Text(
                              AppLocalKeys.register,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: AppColors.white),
                            ));
                  },
                ),
                const RegisterBlocListener(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

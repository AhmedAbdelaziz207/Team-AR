import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/features/auth/login/logic/login_cubit.dart';
import 'package:team_ar/features/auth/login/model/login_request_body.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_local_keys.dart';
import '../../../../core/widgets/custom_text_form_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
            suffixIcon: Icons.person,
            hintText: AppLocalKeys.userName.tr(),
          ),
          SizedBox(height: 12.h),
          CustomTextFormField(
            suffixIcon: Icons.lock,
            hintText: AppLocalKeys.password.tr(),
            obscureText: true,
          ),
          SizedBox(height: 12.h),
          InkWell(
            onTap: () {},
            child: Text(AppLocalKeys.forgotPassword.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                    decoration: TextDecoration.underline)),
          ),
          SizedBox(
            height: 32.h,
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  debugPrint('form is not valid');
                } else {
                  getIt<LoginCubit>().emitLoginStates(
                    const LoginRequestBody(
                        email: "", password: "P@ssw0rd"),
                  );
                }
              },
              child: Text(
                AppLocalKeys.login.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          SizedBox(
            height: 24.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalKeys.dontHaveAnAccount.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                    ),
              ),
              InkWell(
                onTap: () {

                },

                child: Text(
                  AppLocalKeys.signUp.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.mediumLavender,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

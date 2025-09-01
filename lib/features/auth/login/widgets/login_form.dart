import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/auth/login/logic/login_cubit.dart';
import 'package:team_ar/features/auth/login/model/login_request_body.dart';
import 'package:team_ar/features/auth/login/widgets/email_and_password_widget.dart';
import 'package:team_ar/features/auth/login/widgets/login_bloc_listener.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_local_keys.dart';
import '../logic/login_state.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: context.read<LoginCubit>().formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EmailAndPasswordWidget(),
          SizedBox(height: 12.h),
        //   // Forgot Password
        //   InkWell(
        //     onTap: () {},
        //     child: Text(
        //       AppLocalKeys.forgotPassword.tr(),
        //       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        //             fontWeight: FontWeight.w500,
        //             color: AppColors.grey,
        //             decoration: TextDecoration.underline,
        //           ),
        //     ),
        //   ),

          SizedBox(height: 32.h),

          BlocBuilder<LoginCubit, LoginState>(builder: (context, state) {
            return Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style:  ElevatedButton.styleFrom(
                  backgroundColor: AppColors.newPrimaryColor,
                ),
                onPressed: state is LoginLoading
                    ? null
                    : () {
                        validateFormAndLogin(context);
                      },
                child: state is LoginLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.white,
                      )
                    : Text(
                        AppLocalKeys.login.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
              ),
            );
          }),
          SizedBox(height: 24.h),
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
              SizedBox(
                width: 8.w,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.plans);
                },
                child: Text(
                  AppLocalKeys.subscribe.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.newPrimaryColor,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ],
          ),
          const LoginBlocListener(),
        ],
      ),
    );
  }

  void validateFormAndLogin(BuildContext context) {
    if (context.read<LoginCubit>().formKey.currentState!.validate()) {
      context.read<LoginCubit>().emitLoginStates(
            LoginRequestBody(
              email: context.read<LoginCubit>().emailController.text,
              password: context.read<LoginCubit>().passwordController.text,
            ),
          );
    }
  }
}

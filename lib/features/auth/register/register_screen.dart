import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/core/widgets/custom_text_form_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        leading: const AppBarBackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50.h,),
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
              TextButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(250.w, 30.h),
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: Text(
                    AppLocalKeys.register,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.white
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

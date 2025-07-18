import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text_form_field.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: const AppBarBackButton(),
        elevation: 0,
        backgroundColor: AppColors.white,
        title: Text(
          'Change Password',
          style: TextStyle(
              color: AppColors.black,
              fontSize: 20.sp,
              fontFamily: "Cairo",
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30.h,
              ),
              CustomTextFormField(
                controller: currentPasswordController,
                hintText: "Current Password",
                prefixIcon: Icons.lock_outline,
                iconColor: AppColors.newPrimaryColor,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: newPasswordController,
                hintText: "New Password",
                prefixIcon: Icons.lock_reset_outlined,
                iconColor: AppColors.newPrimaryColor,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: confirmPasswordController,
                hintText: "Confirm New Password",
                prefixIcon: Icons.lock_outline,
                iconColor: AppColors.newPrimaryColor,
                obscureText: true,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle submit logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.newPrimaryColor,
                  ),
                  child: Text(AppLocalKeys.save.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

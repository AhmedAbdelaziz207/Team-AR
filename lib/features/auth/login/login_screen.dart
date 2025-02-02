import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/auth/login/widgets/login_form.dart';
import 'package:team_ar/features/auth/login/widgets/login_top_section.dart';
import '../../../core/utils/app_local_keys.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: const SizedBox(),
        title: Text(
          AppLocalKeys.login.tr(),
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 50.h,
          horizontal: 12.w,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Column(
                children: [
                  const LoginTopSection(),
                  SizedBox(
                    height: 36.h,
                  ),
                  const LoginForm()
                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}

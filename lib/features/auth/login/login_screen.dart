import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/features/auth/login/widgets/login_form.dart';
import 'package:team_ar/features/auth/login/widgets/login_top_section.dart';
import '../../../core/utils/app_local_keys.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              AppAssets.coachImage2,
              fit: BoxFit.contain,
            ),
            Column(
              children: [
                SizedBox(height: 300.h,),
                Container(
                  padding: EdgeInsets.only(top: 12.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.white
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const LoginTopSection(),
                        SizedBox(
                          height: 36.h,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0.sp),
                          child: const LoginForm(),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

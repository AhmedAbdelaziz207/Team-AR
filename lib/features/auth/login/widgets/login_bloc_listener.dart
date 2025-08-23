import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/custom_dialog.dart';
import 'package:team_ar/features/auth/login/logic/login_cubit.dart';
import 'package:team_ar/features/auth/login/logic/login_state.dart';
import 'package:team_ar/features/auth/login/model/login_response.dart';
import 'package:team_ar/features/auth/login/model/user_role.dart';
import 'package:team_ar/features/payment/screens/payment_screen.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';

class LoginBlocListener extends StatelessWidget {
  const LoginBlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          current is LoginFailure || current is LoginSuccess || current is NavigateToCompleteData,
      listener: (BuildContext context, LoginState state) {
        state.whenOrNull(
          loginFailure: (apiErrorModel) {
            showCustomDialog(
              context,
              title: AppLocalKeys.loginError.tr(),
              message: apiErrorModel.getErrorsMessage() ?? '',
            );
          }, 
          loginSuccess: (loginResponse) {
            navigateToHomeScreen(context, loginResponse);
          },
          navigateToCompleteData: (loginResponse) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              Routes.completeData, 
              (route) => false
            );
          },
        );
      },
      child: SizedBox(
        height: 20.h,
      ),
    );
  }

  void navigateToHomeScreen(
      BuildContext context, LoginResponse loginResponse) async {
      // إذا لم تكن هناك بيانات اشتراك مؤقتة، استخدم السلوك العادي
      if (loginResponse.role?.toLowerCase() ==
          UserRole.Admin.name.toLowerCase()) {
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.adminLanding, (arguments) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.rootScreen, (arguments) => false);
      }
  }
}

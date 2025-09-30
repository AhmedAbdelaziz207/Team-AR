import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/custom_dialog.dart';
import 'package:team_ar/features/auth/login/logic/login_cubit.dart';
import 'package:team_ar/features/auth/login/logic/login_state.dart';
import 'package:team_ar/features/auth/login/model/login_response.dart';
import 'package:team_ar/features/auth/login/model/user_role.dart';
import 'package:team_ar/features/subscription/screens/subscription_expired_screen.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/payment/screens/payment_screen.dart';

class LoginBlocListener extends StatelessWidget {
  const LoginBlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) => true,
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
          navigateToSubscriptionExpired: (loginResponse) {
          log("navigateToSubscriptionExpired");
            // If admin, bypass subscription checks and go directly to admin panel
            if (_isAdmin(loginResponse.role)) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.adminLanding,
                (route) => false,
              );
              return;
            }
            // Non-admin: go to subscription expired screen
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.subscriptionExpired,
              (route) => false,
            );
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

  // Robust admin role matcher to handle possible backend typos/variants
  bool _isAdmin(String? role) {
    final r = role?.toLowerCase().trim();
    return r == UserRole.Admin.name.toLowerCase() ||
        r == 'admin' ||
        r == 'adimn' || // common typo observed
        r == 'administrator';
  }

  void navigateToHomeScreen(
      BuildContext context, LoginResponse loginResponse) async {
    // ADMIN FLOW: If user is admin, bypass all checks and go to admin panel
    if (_isAdmin(loginResponse.role)) {
      Navigator.pushNamedAndRemoveUntil(
          context, Routes.adminLanding, (route) => false);
      return; // Exit early for admin
    }

    // USER FLOW:
    // 1) If user is unpaid, send to payment screen with userId only
    if (loginResponse.isPaid == false) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            userId: (loginResponse.id ?? '').toString(),
          ),
        ),
        (route) => false,
      );
      return;
    }

    // 2) If paid, check if subscription expired (endPackage <= today)
    try {
      if ((loginResponse.id ?? '').isNotEmpty) {
        final api = getIt<ApiService>();
        final user = await api.getLoggedUserData(loginResponse.id!);
        final end = user.endPackage; // DateTime? from model
        if (end == null || end.difference(DateTime.now()).inDays <= 0) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.subscriptionExpired,
            (route) => false,
          );
          return;
        }
      }
    } catch (e) {
      // On error fetching user, fallback to normal navigation
    }

    // 3) Otherwise proceed to home for non-admin users
    Navigator.pushNamedAndRemoveUntil(
        context, Routes.rootScreen, (route) => false);
  }
}

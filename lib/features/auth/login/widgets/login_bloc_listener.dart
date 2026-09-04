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
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
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
            final r = loginResponse.role?.toLowerCase().trim() ?? '';
            // Admins go to adminLanding
            if (r == 'admin' || r == 'adimn' || r == 'administrator') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.adminLanding,
                (route) => false,
              );
              return;
            }
            // Trainers go to rootScreen
            if (r == 'trainer') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.rootScreen,
                (route) => false,
              );
              return;
            }
            // Non-admin trainee: go to subscription expired screen
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
              (route) => false,
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
    final r = loginResponse.role?.toLowerCase().trim() ?? '';
    final bool isTrainerRole = r == 'trainer';
    final bool isAdminRole =
        r == 'admin' || r == 'adimn' || r == 'administrator';
    final isRealAdmin =
        await SharedPreferencesHelper.getBool('is_real_admin');

    // 1) ADMIN FLOW: Proceed to admin landing
    if (isAdminRole && (isRealAdmin || loginResponse.isPaid != false)) {
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.adminLanding, (route) => false);
      }
      return;
    }

    // 2) TRAINER FLOW:
    if (isTrainerRole) {
      final isDataCompleted = loginResponse.isDataCompleted ??
          await SharedPreferencesHelper.getBool(AppConstants.dataCompleted);
      if (context.mounted) {
        if (!isDataCompleted) {
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.completeData, (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.rootScreen, (route) => false);
        }
      }
      return;
    }

    // 3) TRAINEE / USER FLOW:
    bool isUnpaid = loginResponse.isPaid == false;
    final userId = loginResponse.id ?? '';

    final hasPaidLocally = userId.isNotEmpty
        ? await SharedPreferencesHelper.getBool('has_completed_payment_$userId')
        : false;

    if (isUnpaid && !hasPaidLocally) {
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              userId: userId,
            ),
          ),
          (route) => false,
        );
      }
      return;
    }

    // Check if trainee subscription expired (endPackage <= today)
    try {
      if ((loginResponse.id ?? '').isNotEmpty) {
        final api = getIt<ApiService>();
        final user = await api.getLoggedUserData(loginResponse.id!);
        final end = user.endPackage;
        if (end == null || end.difference(DateTime.now()).inDays <= 0) {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.subscriptionExpired,
              (route) => false,
            );
          }
          return;
        }
      }
    } catch (e) {
      // On error fetching user, fallback to normal navigation
    }

    // Otherwise proceed to home for regular trainees
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, Routes.rootScreen, (route) => false);
    }
  }
}

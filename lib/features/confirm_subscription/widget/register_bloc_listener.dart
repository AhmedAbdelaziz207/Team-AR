import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/network/dio_factory.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_cubit.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_state.dart';

import '../../../core/utils/app_local_keys.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../trainer_register_success/model/register_success_model.dart';
import 'package:team_ar/features/payment/screens/payment_screen.dart';

class RegisterBlocListener extends StatelessWidget {
  const RegisterBlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConfirmSubscriptionCubit, ConfirmSubscriptionState>(
      listenWhen: (previous, current) =>
          current is SubscriptionSuccess || current is SubscriptionFailure,
      listener: (BuildContext context, ConfirmSubscriptionState state) {
        state.whenOrNull(failure: (apiErrorModel) {
          {
            showCustomDialog(
              context,
              title: AppLocalKeys.registerError.tr(),
              message: apiErrorModel.getErrorsMessage() ?? '',
            );
          }
        }, success: (registerResponse) async {
          final role = await SharedPreferencesHelper.getString(
              AppConstants.userRole);
          final isRealAdmin =
              await SharedPreferencesHelper.getBool('is_real_admin');
          final isAdmin = isRealAdmin ||
              role?.toLowerCase() == "admin" ||
              role?.toLowerCase() == "adimn" ||
              role?.toLowerCase() == "administrator" ||
              (context.mounted &&
                  context.read<ConfirmSubscriptionCubit>().isAdmin);

          if (!context.mounted) return;

          // -------------------------------------------------------------
          // CASE 1: ADMIN CREATED A TRAINEE ACCOUNT
          // -------------------------------------------------------------
          if (isAdmin) {
            final cubit = context.read<ConfirmSubscriptionCubit>();
            final successModel = RegisterSuccessModel(
              userName: cubit.nameController.text.trim(),
              email: cubit.emailController.text.trim(),
              password: cubit.passwordController.text,
            );

            // Navigate directly to TrainerRegistrationSuccess screen
            // Displays: Checkmark, Credentials, and WhatsApp share button
            Navigator.pushReplacementNamed(
              context,
              Routes.registerSuccess,
              arguments: successModel,
            );
            return;
          }

          // -------------------------------------------------------------
          // CASE 2: NORMAL TRAINEE SELF-REGISTRATION
          // -------------------------------------------------------------
          DioFactory.setTokenIntoHeaderAfterLogin(registerResponse.token!);
          await SharedPreferencesHelper.setString(
            AppConstants.userId,
            registerResponse.id!,
          );

          if (!context.mounted) return;
          showCustomDialog(
            context,
            onConfirm: () async {
              if (AppConstants.isReleasedValue) {
                // Skip payment screen entirely if released/in-review
                await SharedPreferencesHelper.setData(
                    AppConstants.token, registerResponse.token);
                await SharedPreferencesHelper.setData(
                    AppConstants.userRole, "Trainee");
                await SharedPreferencesHelper.setData(
                    'has_completed_payment_${registerResponse.id}', true);
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.rootScreen,
                    (route) => false,
                  );
                }
              } else {
                // Save userRole as Trainee and userId only (Do NOT save token to disk yet)
                await SharedPreferencesHelper.setData(
                    AppConstants.userRole, "Trainee");
                await SharedPreferencesHelper.setData(
                    AppConstants.userId, registerResponse.id);

                final userId = registerResponse.id;
                if (context.mounted) {
                  if (userId != null && userId.isNotEmpty) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          userId: userId,
                        ),
                      ),
                    );
                  } else {
                    Navigator.pushNamed(context, Routes.rootScreen);
                  }
                }
              }
            },
            iconColor: AppColors.green,
            icon: Icons.check,
            title: AppLocalKeys.success.tr(),
            message: AppConstants.isReleasedValue
                ? AppLocalKeys.accountCreatedSuccessfully.tr()
                : AppLocalKeys.registerSuccessfully.tr(),
          );
        });
      },
      child: SizedBox(
        height: 20.h,
      ),
    );
  }
}

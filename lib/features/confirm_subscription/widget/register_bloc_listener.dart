import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/auth/register/logic/register_cubit.dart';
import 'package:team_ar/features/auth/register/logic/register_state.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_cubit.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_state.dart';

import '../../../core/utils/app_local_keys.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../trainer_register_success/model/register_success_model.dart';

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
        }, success: (registerResponse) {
          showCustomDialog(
            context,
            onConfirm: () async {
            
              final role = await SharedPreferencesHelper.getString(
                  AppConstants.userRole);

              if (role?.toLowerCase() == "admin") {
                Navigator.pushReplacementNamed(context, Routes.registerSuccess,arguments: RegisterSuccessModel(
                  userName: context
                      .read<ConfirmSubscriptionCubit>()
                      .nameController
                      .text,
                  email: context
                      .read<ConfirmSubscriptionCubit>()
                      .emailController
                      .text,
                  password: context
                      .read<ConfirmSubscriptionCubit>()
                      .passwordController
                      .text,
                ),);
              } else {
                Navigator.pushNamed(context, Routes.rootScreen);
              }
            },
            iconColor: AppColors.green,
            icon: Icons.check,
            title: AppLocalKeys.success.tr(),
            message: AppLocalKeys.registerSuccessfully.tr(),
          );
        });
      },
      child: SizedBox(
        height: 20.h,
      ),
    );
  }
}

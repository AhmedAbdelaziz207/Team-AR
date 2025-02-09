
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/auth/register/logic/register_cubit.dart';
import 'package:team_ar/features/auth/register/logic/register_state.dart';

import '../../../../core/utils/app_local_keys.dart';
import '../../../../core/widgets/custom_dialog.dart';

class RegisterBlocListener extends StatelessWidget {
  const RegisterBlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) =>
      current is RegisterFailure || current is RegisterSuccess,
      listener: (BuildContext context, RegisterState state) {
        state.whenOrNull(failure: (apiErrorModel) {
          {
            showCustomDialog(
              context,
              title: AppLocalKeys.registerError.tr(),
              message: apiErrorModel.getErrorsMessage() ?? '',
            );
          }
        }, success: (loginResponse) {
          showCustomDialog(
            context,
            title: "Success",
            message: "Login Successfully",
          );
        });
      },
      child:  SizedBox(height: 20.h,),
    );
  }
}

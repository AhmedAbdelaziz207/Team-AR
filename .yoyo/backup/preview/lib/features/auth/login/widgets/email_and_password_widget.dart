import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/auth/login/logic/login_cubit.dart';

import '../../../../core/utils/app_local_keys.dart';
import '../../../../core/widgets/custom_text_form_field.dart';

class EmailAndPasswordWidget extends StatelessWidget {
  const EmailAndPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormField(
          controller: context.read<LoginCubit>().emailController,
          suffixIcon: Icons.person,
          hintText: AppLocalKeys.email.tr(),
        ),
        SizedBox(height: 12.h),
        CustomTextFormField(
          controller: context.read<LoginCubit>().passwordController,
          suffixIcon: Icons.lock,
          hintText: AppLocalKeys.password.tr(),
          obscureText: true,
        ),
      ],
    );
  }
}

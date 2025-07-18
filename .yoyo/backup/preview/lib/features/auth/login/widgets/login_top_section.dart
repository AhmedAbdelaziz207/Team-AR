import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_local_keys.dart';

class LoginTopSection extends StatelessWidget {
  const LoginTopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalKeys.welcomeBack.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black
          ),
        ),
        Text(
          AppLocalKeys.enterYourCredentials.tr(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey
          ),
        ),
      ],
    );
  }
}

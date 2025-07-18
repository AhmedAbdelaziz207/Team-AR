import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_local_keys.dart';

class UserInfoSection extends StatelessWidget {
  const UserInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                AppLocalKeys.trainee.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black.withOpacity(.7)),
              ),
            ),
            Expanded(
              child: Text(
                AppLocalKeys.phone.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black.withOpacity(.7)),
              ),
            ),
            Expanded(
              child: Text(
                AppLocalKeys.time.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black.withOpacity(.7)),
              ),
            ),
            Expanded(
              child: Text(
                AppLocalKeys.addTrainee.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black.withOpacity(.7)),
              ),
            ),
          ],
        )
        ,
        SizedBox(height: 12.h,),
        const Divider(color: AppColors.grey, thickness: .1,),
      ],
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_local_keys.dart';

class TraineeButton extends StatelessWidget {
  const TraineeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {

      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppColors.lightBlue.withOpacity(.15),
          borderRadius: BorderRadius.circular(20.sp),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalKeys.add.tr(),
              style:  Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightBlue
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.lightBlue, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

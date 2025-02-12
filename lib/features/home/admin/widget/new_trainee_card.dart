import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/datetime_helper.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/home/admin/widget/trainee_button.dart';

import '../../../../core/theme/app_colors.dart';

class NewTraineeCard extends StatelessWidget {
  const NewTraineeCard({super.key, required this.trainee});

  final TraineeModel trainee;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 12.h,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                trainee.userName??"",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.black.withOpacity(.7)),
              ),
            ),
            SizedBox(
              width: 4.w,
            ),
            Expanded(
              child: Text(trainee.phone?? "0108987911",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.black.withOpacity(.6),
                      fontWeight: FontWeight.w600)),
            ),
            SizedBox(
              width: 4.w,
            ),
            Expanded(
              child: Text(
                  "${DateTimeHelper.formatTime(trainee.startPackage.toString())} - ${DateTimeHelper.formatDate(trainee.startPackage.toString())}",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.black.withOpacity(.6),
                      fontWeight: FontWeight.w600)),
            ),
            SizedBox(
              width: 4.w,
            ),
            const Expanded(
              child: TraineeButton(),
            ),
          ],
        ),
      ],
    );
  }
}

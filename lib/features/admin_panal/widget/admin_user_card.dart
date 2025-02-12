import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import '../../../core/theme/app_colors.dart';

class AdminUserCard extends StatelessWidget {
  const AdminUserCard({super.key, this.trainee});

  final TraineeModel? trainee;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 21.r,
          backgroundImage: NetworkImage(trainee?.image ?? AppConstants.avatarUrl2),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          trainee!.userName ?? "",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black.withOpacity(.8),
              ),
        )
      ],
    );
  }
}

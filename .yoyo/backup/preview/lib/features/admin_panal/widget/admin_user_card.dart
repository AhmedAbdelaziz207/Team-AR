import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';

class AdminUserCard extends StatelessWidget {
  const AdminUserCard({super.key, this.trainee});

  final TraineeModel? trainee;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.userInfo,
          arguments: trainee,
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 21.r,
            backgroundColor: AppColors.white,
            backgroundImage: trainee?.image == null
                ? const AssetImage(
                    AppAssets.avatar,
                  )
                : NetworkImage(
                    trainee!.image!,
                  ),
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
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_local_keys.dart';
import '../logic/trainees_cubit.dart';
import '../logic/trainees_state.dart';

class UserInfoSection extends StatelessWidget {
  const UserInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TraineeCubit, TraineeState>(
      builder: (context, state) {
        final trainees = state.maybeWhen(
          success: (list) => list,
          orElse: () => [],
        );

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: AppColors.primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                AppLocalKeys.trainee.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                      color: AppColors.black,
                    ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: trainees.isEmpty
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          Routes.adminTraineesScreen,
                          arguments: trainees,
                        );
                      },
                child: Text(
                  AppLocalKeys.seeDetails.tr(),
                  style: TextStyle(
                    color: trainees.isEmpty
                        ? AppColors.grey
                        : AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/workout_systems/logic/workout_system_cubit.dart';
import 'package:team_ar/features/workout_systems/model/workout_system_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_assets.dart';

class WorkoutSystemCard extends StatelessWidget {
  const WorkoutSystemCard({
    super.key,
    this.name,
    this.workout,
  });

  final String? name;

  final WorkoutSystemModel? workout;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction:  DismissDirection.startToEnd,
      onDismissed: (direction) {
        context.read<WorkoutSystemCubit>().deleteWorkoutSystem(workout!.id!);
      },
      background: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        margin: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: IntrinsicHeight(
          // Makes both children adapt to the tallest one
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.sp, horizontal: 20.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(16.sp),
                      bottomStart: Radius.circular(16.sp),
                    ),
                    color: AppColors.primaryColor.withOpacity(.3),
                  ),
                  child: Center(
                    child: Image.asset(
                      AppAssets.dumbbell,
                      height: 30.h,
                      width: 30.w,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 26.sp, horizontal: 20.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.only(
                      topEnd: Radius.circular(16.sp),
                      bottomEnd: Radius.circular(16.sp),
                    ),
                    color: AppColors.primaryColor.withOpacity(.17),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                  fontSize: 16.sp,
                                ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {},
                            child: Icon(
                              Icons.more_horiz,
                              color: AppColors.primaryColor,
                              size: 20.sp,
                            ),
                          )
                        ],
                      ),

                      // Row(
                      //   children: [
                      //     Row(
                      //       children: [
                      //         Icon(
                      //           Icons.timer_outlined,
                      //           color: AppColors.grey,
                      //           size: 20.sp,
                      //         ),
                      //         SizedBox(width: 8.w),
                      //
                      //       ],
                      //     ),
                      //     const Spacer(),
                      //     // Row(
                      //     //   children: [
                      //     //     const Icon(
                      //     //       Icons.snowshoeing_sharp,
                      //     //       color: AppColors.grey,
                      //     //     ),
                      //     //     Text(
                      //     //       "14 sets",
                      //     //       style: Theme.of(context)
                      //     //           .textTheme
                      //     //           .headlineMedium
                      //     //           ?.copyWith(
                      //     //             color: AppColors.grey,
                      //     //             fontSize: 12.sp,
                      //     //           ),
                      //     //     ),
                      //     //   ],
                      //     // ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

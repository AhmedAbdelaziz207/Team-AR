import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/workout_systems/logic/workout_system_cubit.dart';
import 'package:team_ar/features/workout_systems/model/workout_system_model.dart';
import 'package:team_ar/features/workout_systems/widget/pdf_preview_widget.dart';
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
      child: GestureDetector(
        onTap: () => _openPdf(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.06),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Image.asset(
                  AppAssets.dumbbell,
                  height: 28.h,
                  width: 28.w,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.black.withOpacity(0.85),
                            fontSize: 16.sp,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.visibility_outlined,
                  color: AppColors.primaryColor,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPdf(BuildContext context) {
    if (workout?.url != null && workout!.url!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfPreviewWidget(
            pdfUrl: workout!.url!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No PDF available for preview'),
        ),
      );
    }
  }
}

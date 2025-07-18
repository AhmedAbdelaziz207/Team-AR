import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/add_workout/model/add_workout_params.dart';
import 'package:team_ar/features/workout_systems/logic/workout_system_state.dart';
import '../../core/utils/app_assets.dart';
import '../workout_systems/logic/workout_system_cubit.dart';
import '../workout_systems/model/workout_system_model.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key, required this.params});

  final AddWorkoutParams params;

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  int? _selectedWorkoutId;

  @override
  void initState() {
    super.initState();
    _selectedWorkoutId = widget.params.exerciseId;
    context.read<WorkoutSystemCubit>().getWorkoutSystems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppLocalKeys.addWorkout.tr(),
          style: TextStyle(
            color: AppColors.black,
            fontSize: 21.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        leading: const AppBarBackButton(),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 8.h,
            ),
            Text(
              AppLocalKeys.selectWorkout.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: BlocBuilder<WorkoutSystemCubit, WorkoutSystemState>(
                builder: (context, state) {
                  if (state is WorkoutSystemLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  if (state is WorkoutSystemFailure) {
                    return Center(
                      child: Text(
                        state.errorModel.getErrorsMessage() ??
                            AppLocalKeys.failedToLoadWorkouts.tr(),
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: "Cairo",
                        ),
                      ),
                    );
                  }

                  if (state is WorkoutSystemLoadSuccess) {
                    if (state.data.isEmpty) {
                      return Center(child: Text(AppLocalKeys.noWorkouts.tr()));
                    }

                    return ListView.builder(
                      itemCount: state.data.length,
                      itemBuilder: (context, index) {
                        final workout = state.data[index];
                        return WorkoutRadioCard(
                          onSelected: (value) {
                            setState(() {
                              _selectedWorkoutId = value;
                            });
                          },
                          workout: workout,
                          selectedWorkoutId: _selectedWorkoutId,
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
            BlocBuilder<WorkoutSystemCubit, WorkoutSystemState>(
              builder: (context, state) {
                if (state is WorkoutSystemAssignedSuccess) {
                  Navigator.pop(context);
                }

                return ElevatedButton(
                  onPressed: () {
                    context.read<WorkoutSystemCubit>().addWorkoutForUser(
                          _selectedWorkoutId!,
                          widget.params.traineeId!,
                        );

                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: state is WorkoutSystemAssignLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.white,
                        )
                      : Text(AppLocalKeys.save.tr()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutRadioCard extends StatelessWidget {
  const WorkoutRadioCard({
    super.key,
    required this.workout,
    this.selectedWorkoutId,
    required this.onSelected,
  });

  final WorkoutSystemModel workout;
  final int? selectedWorkoutId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedWorkoutId == workout.id;

    return GestureDetector(
      onTap: () => onSelected(workout.id),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.sp),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Icon Section
              Container(
                width: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(.3),
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(16.sp),
                    bottomStart: Radius.circular(16.sp),
                  ),
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
              // Info Section
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.sp, horizontal: 16.sp),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(.12),
                    borderRadius: BorderRadiusDirectional.only(
                      topEnd: Radius.circular(16.sp),
                      bottomEnd: Radius.circular(16.sp),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          workout.name ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                                fontSize: 16.sp,
                              ),
                        ),
                      ),
                      Radio<int>(
                        value: workout.id!,
                        groupValue: selectedWorkoutId,
                        activeColor: AppColors.primaryColor,
                        onChanged: onSelected,
                      )
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

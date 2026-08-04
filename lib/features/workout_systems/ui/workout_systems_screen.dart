import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/features/workout_systems/logic/workout_system_cubit.dart';
import 'package:team_ar/features/workout_systems/logic/workout_system_state.dart';
import 'package:team_ar/features/workout_systems/widget/workout_system_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';
import 'create_workout_system.dart';
import 'dart:developer';

class WorkoutSystemsScreen extends StatefulWidget {
  const WorkoutSystemsScreen({super.key});

  @override
  State<WorkoutSystemsScreen> createState() => _WorkoutSystemsScreenState();
}

class _WorkoutSystemsScreenState extends State<WorkoutSystemsScreen> {
  @override
  void initState() {
    context.read<WorkoutSystemCubit>().getWorkoutSystems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: const SizedBox.shrink(),
        title: Text(
          AppLocalKeys.workoutSystems.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontSize: 21.sp,
              ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => context
            .read<WorkoutSystemCubit>()
            .refreshWorkoutSystems(), // استخدام دالة التحديث
        child: BlocBuilder<WorkoutSystemCubit, WorkoutSystemState>(
          builder: (context, state) {
            if (state is WorkoutSystemLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WorkoutSystemFailure) {
              return Center(
                child: Text(
                    state.errorModel.getErrorsMessage() ?? "Unknown Error"),
              );
            }

            if (state is WorkoutSystemLoadSuccess) {
              if (state.data.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 80.sp,
                        color: AppColors.grey.withOpacity(0.4),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "لا توجد أنظمة تمارين مسجلة حالياً",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: state.data.length,
                padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
                itemBuilder: (context, index) => WorkoutSystemCard(
                  name: state.data[index].name,
                  workout: state.data[index],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => WorkoutSystemCubit(),
                child: const CreateWorkoutScreen(),
              ),
            ),
          ).then((value) => {
                if (context.mounted)
                  {
                    context.read<WorkoutSystemCubit>().getWorkoutSystems(),
                  },
                log("then")
              });
        },
        elevation: 4,
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        icon: Image.asset(
          AppAssets.dumbbell,
          height: 24.h,
          width: 24.w,
          color: AppColors.white,
        ),
        label: Text(
          "إضافة نظام",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}

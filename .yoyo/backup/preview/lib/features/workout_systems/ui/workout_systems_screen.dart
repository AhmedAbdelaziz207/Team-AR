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
        onRefresh: () async =>
            context.read<WorkoutSystemCubit>().getWorkoutSystems(),
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
              return ListView.builder(
                itemCount: state.data.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => WorkoutSystemCubit(),
                child: const CreateWorkoutScreen(),
              ),
            ),
          );
        },
        backgroundColor: AppColors.primaryColor,
        child: Image.asset(
          AppAssets.dumbbell,
          height: 25.h,
          width: 25.w,
          color: AppColors.white,
        ),
      ),
    );
  }
}

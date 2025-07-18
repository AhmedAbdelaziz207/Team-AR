import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/work_out/logic/workout_cubit.dart';
import 'package:team_ar/features/work_out/logic/workout_state.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({
    super.key,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    log("Get Workout with Id ${await SharedPreferencesHelper.getInt(AppConstants.exerciseId)}");

    await SharedPreferencesHelper.getInt(AppConstants.exerciseId).then(
      (value) {
        context.read<WorkoutCubit>().getWorkout(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const AppBarBackButton(
          color: AppColors.white,
        ),
        title: Text(
          AppLocalKeys.workouts.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutSuccess) {
            return SfPdfViewer.network(
              '${ApiEndPoints.baseUrl}/Exercises/${state.url}',
            );
          }

          if (state is WorkoutFailure) {
            return Center(
              child: Text(
                AppLocalKeys.noWorkouts.tr(),
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20.sp,
                  fontFamily: "Cairo",
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

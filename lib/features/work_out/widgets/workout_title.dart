import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../logic/workout_cubit.dart';
import '../logic/workout_state.dart';

class WorkoutTitle extends StatelessWidget {
  const WorkoutTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return  BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Day ${state.selectedDay+1} - Exercises",
              style: TextStyle(color: Colors.red, fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
        );

      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../logic/workout_cubit.dart';
import '../logic/workout_state.dart';
import '../model/workout_model.dart';

class ExerciseList extends StatelessWidget {
  const ExerciseList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, state) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: state.exercises.length,
            itemBuilder: (context, index) {
              final exercise = state.exercises[index];
              return _buildExerciseCard(context, exercise);
            },
          );
        },
      ),
    );
  }
}

/// Exercise Card - Opens Bottom Sheet when tapped
Widget _buildExerciseCard(BuildContext context, WorkoutModel exercise) {
  return GestureDetector(
    onTap: () => showExerciseDetails(context, exercise),
    // Show bottom sheet on tap
    child: Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(bottom: 10.sp),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildExerciseImage(exercise.image1, "Step 1"),
                SizedBox(width: 10.w),
                _buildExerciseImage(exercise.image2, "Step 2"),
              ],
            ),
            SizedBox(height: 10.h),
            Text(exercise.title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ),
  );
}

/// Bottom Sheet to Show Exercise Details
void showExerciseDetails(BuildContext context, WorkoutModel exercise) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                    child: Image.asset(exercise.image1,
                        height: 150.h, fit: BoxFit.cover)),
                SizedBox(width: 10.h),
                Expanded(
                    child: Image.asset(exercise.image2,
                        height: 150.h, fit: BoxFit.cover)),
              ],
            ),
            SizedBox(height: 20.h),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Close", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Exercise Image Widget
Widget _buildExerciseImage(String imagePath, String step) {
  return Expanded(
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(imagePath, height: 120, fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 5,
          left: 5,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5.sp),
            ),
            child: Text(step,
                style: TextStyle(color: Colors.white, fontSize: 12.sp)),
          ),
        ),
      ],
    ),
  );
}

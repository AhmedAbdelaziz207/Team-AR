import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/work_out/widgets/days_section.dart';
import 'package:team_ar/features/work_out/widgets/exercise_list.dart';
import 'package:team_ar/features/work_out/widgets/workout_title.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Workout",
            style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Day counter
          const DaysSection(),

          SizedBox(height: 20.h),

          /// Workout Title
          const WorkoutTitle(),

          SizedBox(height: 10.h),

          /// Exercise List
          const ExerciseList(),
        ],
      ),
    );
  }
}

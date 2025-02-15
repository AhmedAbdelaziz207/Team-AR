import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../logic/workout_cubit.dart';
import '../logic/workout_state.dart';

class DaysSection extends StatelessWidget {
  const DaysSection({super.key});

  @override
  Widget build(BuildContext context) {
    return   BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 70.h,
                    width: double.infinity,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 4,
                      scrollDirection:  Axis.horizontal,
                      itemBuilder: (context, index) {
                        return  GestureDetector(
                          onTap: () => context.read<WorkoutCubit>().selectDay(index),
                          child: Padding(
                            padding:  EdgeInsets.all(4.0.sp),
                            child: Container(
                              height: 70.h,
                              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                              decoration: BoxDecoration(
                                color:  state.selectedDay== index  ? Colors.red : Colors.grey[800],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(child: Text("Day   \n ${index+1} ", style: const TextStyle(color: Colors.white))),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ]
          ),
        );
      },
    );
  }
}

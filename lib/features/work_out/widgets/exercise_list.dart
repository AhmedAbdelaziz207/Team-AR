// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:team_ar/core/theme/app_colors.dart';
// import 'package:team_ar/core/utils/app_local_keys.dart';
//
// import '../../diet/widgets/health_alert.dart';
// import '../logic/workout_cubit.dart';
// import '../logic/workout_state.dart';
// import '../model/workout_model.dart';
// import '../ui/workout_video_screen.dart';
//
// class ExerciseList extends StatelessWidget {
//   const ExerciseList({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: BlocBuilder<WorkoutCubit, WorkoutState>(
//         builder: (context, state) {
//           return DraggableScrollableSheet(
//             initialChildSize: 1,
//             minChildSize: .8,
//             builder: (context, controller) {
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(20.r),
//                     topRight: Radius.circular(20.r),
//                   ),
//                 ),
//                 child: ListView.builder(
//                   controller: controller,
//                   padding: EdgeInsets.symmetric(horizontal: 16.w),
//                   itemCount: state.exercises.length,
//                   itemBuilder: (context, index) {
//                     final exercise = state.exercises[index];
//                     return _buildExerciseCard(context, exercise);
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// /// Exercise Card - Opens Bottom Sheet when tapped
// Widget _buildExerciseCard(BuildContext context, WorkoutModel exercise) {
//   return GestureDetector(
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const WorkoutVideoScreen(),
//         ),
//       );
//     },
//     child: Card(
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       margin: EdgeInsets.only(bottom: 10.sp),
//       child: Padding(
//         padding: EdgeInsets.all(10.sp),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 _buildExerciseImage(exercise.image1, "1"),
//                 _buildExerciseImage(exercise.image1, "2"),
//               ],
//             ),
//             SizedBox(height: 15.h),
//             Text(
//               exercise.title,
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Row(
//               children: [
//                 _buildExerciseProperty(AppLocalKeys.sets, "3"),
//                 SizedBox(
//                   width: 12.w,
//                 ),
//                 _buildExerciseProperty(AppLocalKeys.reps, "(8 - 12)"),
//               ],
//             ),
//             SizedBox(
//               height: 8.h,
//             ),
//             _buildExerciseProperty(AppLocalKeys.restTime, "2:00"),
//             SizedBox(
//               height: 21.h,
//             ),
//             const HealthAlert(message: "اول جولتين تكون تسخين بأوزان خفيفة"),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// /// Bottom Sheet to Show Exercise Details
// void showExerciseDetails(BuildContext context, WorkoutModel exercise) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.white,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: EdgeInsets.all(16.sp),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               exercise.title,
//               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10.h),
//             Row(
//               children: [
//                 Expanded(
//                     child: Image.asset(exercise.image1,
//                         height: 150.h, fit: BoxFit.cover)),
//                 SizedBox(width: 10.h),
//                 Expanded(
//                     child: Image.asset(exercise.image2,
//                         height: 150.h, fit: BoxFit.cover)),
//               ],
//             ),
//             SizedBox(height: 20.h),
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 onPressed: () => Navigator.pop(context),
//                 child:
//                     const Text("Close", style: TextStyle(color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
//
// /// Exercise Image Widget
// Widget _buildExerciseImage(String imagePath, String step) {
//   return Expanded(
//     child: Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: Image.asset(imagePath, height: 120, fit: BoxFit.cover),
//         ),
//         Positioned(
//           bottom: 5,
//           left: 5,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//             decoration: BoxDecoration(
//               color: AppColors.newPrimaryColor,
//               borderRadius: BorderRadius.circular(5.sp),
//             ),
//             child: Text(
//               "step $step",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 12.sp,
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// Widget _buildExerciseProperty(String title, String value) {
//   return Container(
//     padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
//     decoration: BoxDecoration(
//       color: AppColors.grey.withOpacity(.2),
//       borderRadius: BorderRadius.circular(5.sp),
//     ),
//     child: Text(
//       "$title: $value",
//       style: TextStyle(
//         fontSize: 12.sp,
//         fontWeight: FontWeight.w500,
//         color: AppColors.black,
//         fontFamily: "Cairo",
//       ),
//     ),
//   );
// }

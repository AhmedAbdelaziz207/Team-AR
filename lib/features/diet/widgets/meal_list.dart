import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/diet/widgets/health_alert.dart';

import 'meal_item.dart';

class MealList extends StatelessWidget {
  const MealList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// title
          Text("Number of meal",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          Text("n items | calories",
              style: TextStyle(color: Colors.grey[800], fontSize: 16.sp)),

          /// meals
          const MealItem(
              imagePath: 'assets/images/dish.png',
              dishName: "dish name",
              weight: "Weight"),
          const MealItem(
              imagePath: 'assets/images/dish.png',
              dishName: "dish name",
              weight: "Weight"),

          /// alert
          const HealthAlert(message: "ابدأ بالخضار، واشرب ماء قبل ما تفطر"),
        ],
      ),
    );
  }
}

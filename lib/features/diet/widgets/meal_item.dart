import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealItem extends StatelessWidget {
  final String imagePath;

  final String weight;
  final String dishName;

  const MealItem(
      {super.key, required this.imagePath, required this.weight, required this.dishName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(10.sp),
              child: Image.asset(
                imagePath,
                height: 100.h,
                width: 100.w,
              )),
          Expanded(
            child: Padding(
              padding:
              EdgeInsets.only(bottom: 25.0.h, left: 10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dishName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Row(
                    children: [
                      Icon(Icons.shopping_cart,
                          color: Colors.grey, size: 16.sp),
                      SizedBox(width: 5.w),
                      Text(weight,
                          style:
                          TextStyle(color: Colors.grey[800])),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),

        ]),

      ],
    );
  }
}

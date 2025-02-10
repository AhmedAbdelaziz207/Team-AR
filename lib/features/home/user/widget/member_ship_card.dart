import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class MemberShipCard extends StatelessWidget {
  const MemberShipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: AppColors.lightBlue, // Background color
          borderRadius: BorderRadius.circular(20), // Rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.account_balance_wallet,
                      size: 30.sp, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TEAM AR",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: AppColors.white),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Joined 2024-12-21',
                        style: TextStyle(
                          color: AppColors.softGrey,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 32.sp),
                  child: Text(
                    '37 Days Left',
                    style: TextStyle(
                      color: AppColors.softGrey,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              // Rounded Progress Bar
              child: LinearProgressIndicator(
                value: 0.6.sp,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

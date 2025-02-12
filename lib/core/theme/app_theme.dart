import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

ThemeData appTheme(context) => ThemeData(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(250.w, 50.h),
          backgroundColor: AppColors.mediumLavender,
          // Blue background.
          foregroundColor: Colors.white,
          // White text color.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.sp), // Rounded corners.
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          // Padding inside the button.
          elevation: 0, // Flat design without shadow.
        ),
      ),
    );

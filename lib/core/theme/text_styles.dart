import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextStyles{

 static TextTheme arabicTextStyle() {
    return TextTheme(
      headlineLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 32.sp),
      headlineMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 20.sp),
      bodyLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, fontSize: 16.sp),
      bodyMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w300, fontSize: 14.sp),
    );
  }

  static TextTheme englishTextStyle() {
    return TextTheme(
      headlineLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 32.sp),
      headlineMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 20.sp),
      bodyLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 16.sp),
      bodyMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontSize: 14.sp),
    );
  }

}
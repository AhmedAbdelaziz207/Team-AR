import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';

class HealthAlert extends StatelessWidget {
  final String message ;
  const HealthAlert({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding:  EdgeInsets.all(12.sp),
      margin:  EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child:  Row(
        children: [
          Icon(Icons.info, color: AppColors.orange),
          SizedBox(width: 4.w,),
          Text("${AppLocalKeys.note} : ", style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
          SizedBox(width: 10.w),
           Expanded(
            child: Text(
              maxLines: 1,
              message,
              style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

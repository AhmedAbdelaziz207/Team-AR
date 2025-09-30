import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/app_local_keys.dart';

class HealthAlert extends StatelessWidget {
  final String message;
  final bool isNaturalSupplement;

  const HealthAlert({
    super.key,
    required this.message,
    this.isNaturalSupplement = false,
  });

  @override
  Widget build(BuildContext context) {
    // Always use green colors and natural supplements styling
    final backgroundColor = Colors.green.shade100;
    final iconColor = Colors.green;
    final textColor = Colors.green[700];
    final labelText = AppLocalKeys.howToUseNaturalSupplements.tr();

    return Container(
      padding: EdgeInsets.all(12.sp),
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco,
                color: iconColor,
              ),
              SizedBox(width: 4.w),
                       Text(
                      labelText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: iconColor,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
            ],
          ),
          SizedBox(height: 12.w),
          Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import '../../../core/utils/app_local_keys.dart';

class AdminMealCard extends StatelessWidget {
  final String mealName;
  final String amount;
  final VoidCallback onReplace;
  final String imageUrl;

  const AdminMealCard({
    super.key,
    required this.imageUrl,
    required this.mealName,
    required this.amount,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.network(
              ApiEndPoints.imagesBaseUrl + imageUrl,
              height: 70.h,
              width: 70.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  height: 70.h,
                  width: 70.w,
                  child: const Icon(Icons.broken_image_rounded),
                );
              },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: "Cairo",
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "$amount ${AppLocalKeys.gram.tr()}",
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontFamily: "Cairo",
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';

class FilesList extends StatelessWidget {
  const FilesList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {
        "title": "DIET",
        "description": "كتيب زيادة الوزن",
        "icon": "assets/images/dish.png"
      },
      {
        "title": "DIET",
        "description": "كتاب صمم جدولك الغذائي بدون مدرب",
        "icon": "assets/images/dish.png"
      },
      {
        "title": "DIET",
        "description": "Shopping List",
        "icon": "assets/images/dish.png"
      },
      {
        "title": "DIET",
        "description": "كتيب أقوى النصائح لخسارة الدهون",
        "icon": "assets/images/dish.png"
      },
      {
        "title": "GENERAL",
        "description": "كتيب الأسئلة الشائعة",
        "icon": "assets/images/dish.png"
      },
    ];

    return Padding(
      padding: EdgeInsets.all(20.0.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Files", style: TextStyle(fontSize: 24.sp,fontWeight: FontWeight.bold, color: Colors.black)),
          Text(
            "Become the best version of you.",
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(6.sp),
                decoration: BoxDecoration(
                  color:Colors.black12,
                  borderRadius: BorderRadius.circular(16.sp),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        item["icon"]!,
                        width: 50.w,
                        height: 50.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["title"]!,
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item["description"]!,
                            style: TextStyle(
                                fontSize: 14.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_circle_right_outlined,
                        color: Colors.black, size: 35.sp),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

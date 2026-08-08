import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/guide_files/ui/protected_pdf_viewer_screen.dart';

class FilesList extends StatelessWidget {
  const FilesList({super.key});

  void _openProtected(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProtectedPdfViewerScreen(url: url, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {
        "title": AppLocalKeys.importantInstructions.tr(),
        "description": "كتيب طرق الأكل",
        "icon": "assets/images/dish.png",
        "url":
            "https://drive.google.com/file/d/1WyNvaEzsEUpmy5U0RwTmGqzIRytxsgwa/view?usp=sharing"
      },
      {
        "title": AppLocalKeys.importantInstructions.tr(),
        "description": "كتيب الطعام الصحي",
        "icon": "assets/images/dish.png",
        "url":
            "https://drive.google.com/file/d/1t01CH-81j3M1iN6ti67s6DG76MiScNvr/view?usp=sharing"
      },
      {
        "title": AppLocalKeys.importantInstructions.tr(),
        "description": "كتيب بدائل الطعام ",
        "icon": "assets/images/dish.png",
        "url":
            "https://drive.google.com/file/d/1HuFY2yZ_hcHPyaw5zNst1xG6WF7tBkH-/view?usp=sharing"
      },
      {
        "title": AppLocalKeys.importantInstructions.tr(),
        "description": "2 كتيب بدائل الطعام ",
        "icon": "assets/images/dish.png",
        "url":
            "https://drive.google.com/file/d/1HdJndGM9nn_1uEkrKLFg0Ln-uLhr-BUU/view?usp=drive_link"
      },
      {
        "title": AppLocalKeys.training.tr(),
        "description": "كتيب الاحماء",
        "icon": "assets/images/dish.png",
        "url":
            "https://drive.google.com/file/d/1ZvU20xVbAdlgwO4bsEjdXXmQgNxYmZny/view?usp=sharing",
      },
      {
        "title": AppLocalKeys.training.tr(),
        "description": "2 كتيب الاحماء",
        "icon": "assets/images/dish.png",
        "url":
            "https://drive.google.com/file/d/1YXhpJKpHMgoXMgqPfzUBBsAU0B2-O9Z1/view?usp=sharing",
      },
      {
        "title": AppLocalKeys.tipsAndGuides.tr(),
        "description": "استرشادات ونصائح",
        "icon": "assets/images/dish.png",
        "url":
            "https://drive.google.com/file/d/1hthJxKJRFZL4X-QZ_8yqbJ8HyHuOt5M2/view?usp=sharing"
      },
      {
        "title": "GENERAL",
        "description": "كتيب الأسئلة الشائعة",
        "icon": "assets/images/dish.png",
        "url":
            "https://drive.google.com/file/d/1YyXaAgTPmJMS1V2Dp7-ngrfp4PAM8C8x/view?usp=sharing"
      },
    ];

    return Padding(
      padding: EdgeInsets.all(20.0.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalKeys.files.tr(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: Colors.black,
                  fontFamily: "Cairo",
                ),
          ),
          Text(
            AppLocalKeys.filesDescription.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.black,
                  fontSize: 14.sp,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
              onTap: () {
                  _openProtected(
                    context,
                    item["url"]!,
                    item["description"]!,
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(6.sp),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.sp),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 8.w,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item["icon"]!,
                          width: 30.w,
                          height: 50.h,
                          color: AppColors.newPrimaryColor,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: 21.w),
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
                      Icon(
                        Icons.arrow_circle_right_outlined,
                        color: AppColors.black.withValues(alpha: 0.9),
                        size: 25.sp,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

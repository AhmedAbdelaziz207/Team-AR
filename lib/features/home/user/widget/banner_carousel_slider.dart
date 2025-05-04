import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_assets.dart';

class BannerCarouselSlider extends StatelessWidget {
  const BannerCarouselSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {
        "image": AppAssets.coachImage3,
        "title": "الإستمرارية",
        "text":
            "هي المفتاح الحقيقي للوصول\n إلى أهدافك،استمر فالتحديات تصنع الأقوياء"
      },
      {
        "image": AppAssets.coachImage1,
        "text": "اليوم أفضل من الأمس، وغدًا أفضل من اليوم",
        "title": "انتقاء الوقت",
      },
      {
        "image": AppAssets.coachImage2,
        "text": "الطريق طويل لكنه يستحق العناء",
        "title": "التحقيق",
      },
    ];

    return CarouselSlider.builder(
      options: CarouselOptions(
        height: 280.h,
        viewportFraction: 0.95,
        enlargeFactor: 0.10,
        enableInfiniteScroll: true,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      itemCount: items.length,
      itemBuilder: (context, index, realIndex) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16.r)),
            child: Stack(
              children: [
                //  Image
                Container(
                  width: double.infinity,
                  color: Colors.grey,
                  child: Image.asset(
                    items[index]["image"]!,
                    fit: BoxFit.cover,
                  ),
                ),

                //shadow
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.black87.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),

                // Text
                Positioned(
                  top: 80, // Center vertically
                  right: 12, // Center horizontally
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.only(end: 8.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          items[index]["title"]!,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24.sp,
                                fontFamily: "Cairo",
                              ),
                        ),
                        SizedBox(
                          height: 8.h,
                        ),
                        Text(
                          items[index]["text"]!,
                          textAlign: TextAlign.end,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                  fontFamily: "Cairo"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BannerCarouselSlider extends StatelessWidget {
  const BannerCarouselSlider({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة الصور مع النصوص
    final List<Map<String, String>> items = [
      {"image": "assets/images/coach_1.png", "text": "الإستمرارية"},
      {"image": "assets/images/coach_2.JPG", "text": " الإستمرارية"},
    ];

    return CarouselSlider.builder(
      options: CarouselOptions(
        height: 180.h,
        viewportFraction: 0.80,
        enlargeFactor: 0.20,
        enableInfiniteScroll: true,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      itemCount: items.length,
      itemBuilder: (context, index, realIndex) {
        return ClipRRect(
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
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Text
              Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  items[index]["text"]!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

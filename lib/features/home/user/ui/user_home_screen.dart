import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/home/user/widget/banner_carousel_slider.dart';
import 'package:team_ar/features/home/user/widget/file_list.dart';

import '../../../../core/theme/app_colors.dart';
import '../widget/member_ship_card.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('EEEE d MMM').format(DateTime.now());

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.h),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.white,
            elevation: 0,
            flexibleSpace: Padding(
              padding: EdgeInsets.only(bottom: 2.0.sp),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Stack(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/app_logo.PNG",
                        height: 100.h,
                        width: 100.w,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          // Prevent extra space

                          children: [
                            Text(todayDate,
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                )),
                            Text("You are on your journey",
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                )),
                          ]),
                    ],
                  ),
                  Positioned(
                    right: 10,
                    bottom: 35,
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications_on_outlined,
                        size: 30.sp,
                      ),
                      onPressed: () {},
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
        body:  SingleChildScrollView(
          child: Column(
            crossAxisAlignment:  CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MemberShipCard(),
              SizedBox(height: 10.h),
              BannerCarouselSlider(),

              FilesList(),



            ],
          ),
        ));
  }
}

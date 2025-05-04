import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/home/user/logic/user_cubit.dart';
import 'package:team_ar/features/home/user/widget/banner_carousel_slider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widget/file_list.dart';
import '../widget/member_ship_card.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    log("Get User Id from SharedPref");
    SharedPreferencesHelper.getString(AppConstants.userId).then(
      (value) {
        log("Get User Data ");
        context.read<UserCubit>().getUser(value!);
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('EEEE d MMM').format(DateTime.now());

    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(110.h),
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
                        color: AppColors.newPrimaryColor,
                        AppAssets.appLogo,
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
                            Text(
                              AppLocalKeys.yourJourney.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ]),
                    ],
                  ),
                  Positioned(
                    right: 10,
                    bottom: 35,
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        size: 30.sp,
                        color: AppColors.black,
                      ),
                      onPressed: () {
                      },
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const MemberShipCard(),
              SizedBox(height: 10.h),
              const BannerCarouselSlider(),
              const FilesList(),
            ],
          ),
        ));
  }
}

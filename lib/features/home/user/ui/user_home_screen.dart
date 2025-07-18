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
import '../../../../core/routing/routes.dart';
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
    loadData();
    super.initState();
  }

  loadData() async {
    await SharedPreferencesHelper.getString(AppConstants.userId).then(
      (value) {
        context.read<UserCubit>().getUser(value!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    log(context.locale.languageCode.toString());
    String todayDate = DateFormat('EEEE d MMM', context.locale.languageCode)
        .format(DateTime.now());

    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120.h),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.white,
            elevation: 0,
            flexibleSpace: Padding(
              padding: EdgeInsets.only(bottom: 2.0.sp),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Stack(children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 0,
                          child: Image.asset(
                            color: AppColors.newPrimaryColor,
                            AppAssets.appLogo,
                            height: 80.h, // Reduced size to prevent overflow
                            width: 80.w,  // Reduced size to prevent overflow
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported,
                                size: 80.sp,
                                color: AppColors.newPrimaryColor,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                todayDate,
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 16.sp,
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                AppLocalKeys.yourJourney.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  fontSize: 16.sp,
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                        Navigator.pushNamed(context, Routes.notification);
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

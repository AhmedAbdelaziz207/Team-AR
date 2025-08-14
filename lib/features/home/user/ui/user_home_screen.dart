import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/widgets/custom_app_bar.dart';
import 'package:team_ar/features/home/user/logic/user_cubit.dart';
import 'package:team_ar/features/home/user/widget/banner_carousel_slider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../subscription/screens/subscription_expired_screen.dart';
import '../../../notification/services/push_notifications_services.dart';
import '../widget/file_list.dart';
import '../widget/member_ship_card.dart';
import '../logic/user_state.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    loadData();
    FirebaseNotificationsServices.listenToTokenRefresh();

    super.initState();
  }

  loadData() async {
    await SharedPreferencesHelper.getString(AppConstants.userId).then(
      (value) {
        // استخدام getUser فقط إذا لم تكن البيانات محملة مسبقًا
        context.read<UserCubit>().getUser(value!);
      },
    );
  }

  // إضافة دالة لتحديث البيانات
  refreshData() async {
    await SharedPreferencesHelper.getString(AppConstants.userId).then(
      (value) {
        context.read<UserCubit>().refreshUserData(value!);
      },
    );
  }

  // دالة للتحقق من انتهاء الاشتراك
  bool _isSubscriptionExpired(DateTime? endDate, int? remindDays) {
    if (endDate == null) return true;

    // التحقق من التاريخ الحالي مقارنة بتاريخ انتهاء الاشتراك
    DateTime now = DateTime.now();
    bool isExpired = now.isAfter(endDate);

    // أو يمكنك استخدام remindDays إذا كانت أقل من أو تساوي 0
    bool isExpiredByDays = (remindDays ?? 0) <= 0;

    return isExpired || isExpiredByDays;
  }

  // دالة لعرض شاشة انتهاء الاشتراك
  void _showSubscriptionExpiredScreen(String? userEmail, String? endDate) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SubscriptionExpiredScreen(
          userEmail: userEmail,
          endDate: endDate, // تمرير String مباشرة
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateFormat('EEEE d MMM', context.locale.languageCode)
        .format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.h),
        child: const CustomAppBar(
          showNotification: true,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshData(), // استخدام دالة التحديث
        child: BlocListener<UserCubit, UserState>(
          listener: (context, state) {
            state.maybeMap(
              success: (userState) {
                final userData = userState.userData; // TraineeModel

                // التحقق من انتهاء الاشتراك
                DateTime? endDate = userData.endPackage; // مباشرة DateTime?
                String? endDateString;

                // تحويل DateTime إلى String للتمرير للشاشة
                if (endDate != null) {
                  endDateString = endDate.toIso8601String();
                }

                if (_isSubscriptionExpired(endDate, userData.remindDays)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showSubscriptionExpiredScreen(
                      userData.email,
                      endDateString, // تمرير String
                    );
                  });
                }
              },
              orElse: () {},
            );
          },
          child: SingleChildScrollView(
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
          ),
        ),
      ),
    );
  }
}

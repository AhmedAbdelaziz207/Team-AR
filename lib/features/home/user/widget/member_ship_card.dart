import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/utils/extensions.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/home/user/logic/user_cubit.dart';
import 'package:team_ar/features/home/user/logic/user_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_constants.dart';

class MemberShipCard extends StatefulWidget {
  const MemberShipCard({super.key});

  @override
  State<MemberShipCard> createState() => _MemberShipCardState();
}

class _MemberShipCardState extends State<MemberShipCard> {
  TraineeModel? _cachedUserData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    // محاولة تحميل البيانات المخزنة مؤقتًا
    final startPackageStr =
        await SharedPreferencesHelper.getString('user_start_package');
    final endPackageStr =
        await SharedPreferencesHelper.getString('user_end_package');
    final remindDays = await SharedPreferencesHelper.getInt('user_remind_days');
    final userName = await SharedPreferencesHelper.getString('user_name');
    final exerciseId = await SharedPreferencesHelper.getInt('user_exercise_id');

    if (startPackageStr != null &&
        endPackageStr != null &&
        remindDays != null &&
        userName != null) {
      if (mounted) {
        setState(() {
          _cachedUserData = TraineeModel(
            id: '',
            userName: userName,
            email: '',
            long: 0,
            weight: 0,
            age: 0,
            startPackage: DateTime.parse(startPackageStr),
            endPackage: DateTime.parse(endPackageStr),
            name: '',
            duration: 0,
            oldPrice: 0,
            newPrice: 0,
            gender: '',
            remindDays: remindDays,
            exerciseId: exerciseId,
          );
          _isLoading = false;
        });
      }
    }
  }

  void _cacheUserData(TraineeModel userData) async {
    // تخزين البيانات المهمة في التخزين المؤقت
    if (userData.startPackage != null) {
      await SharedPreferencesHelper.setString(
          'user_start_package', userData.startPackage!.toIso8601String());
    }
    if (userData.endPackage != null) {
      await SharedPreferencesHelper.setString(
          'user_end_package', userData.endPackage!.toIso8601String());
    }
    if (userData.remindDays != null) {
      await SharedPreferencesHelper.setData(
          'user_remind_days', userData.remindDays!);
    }
    if (userData.userName != null) {
      await SharedPreferencesHelper.setString('user_name', userData.userName!);
    }
    if (userData.exerciseId != null) {
      await SharedPreferencesHelper.setData(
          'user_exercise_id', userData.exerciseId!);
    }

    // تحديث البيانات المخزنة مؤقتًا
    if (mounted) {
      setState(() {
        _cachedUserData = userData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.newSecondaryColor,
              borderRadius: BorderRadius.circular(15.sp),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: state.maybeMap(
              loading: (_) {
                // إذا كان لدينا بيانات مخزنة مؤقتًا، نعرضها أثناء التحميل
                if (!_isLoading && _cachedUserData != null) {
                  return _buildCardContent(_cachedUserData!);
                }
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              },
              success: (user) {
                // تخزين البيانات الجديدة في التخزين المؤقت
                _cacheUserData(user.userData);
                saveUserExerciseInfo(user.userData);
                return _buildCardContent(user.userData);
              },
              orElse: () {
                // إذا كان لدينا بيانات مخزنة مؤقتًا، نعرضها في حالة الخطأ
                if (!_isLoading && _cachedUserData != null) {
                  return _buildCardContent(_cachedUserData!);
                }
                return SizedBox(height: 120.h);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(TraineeModel userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.white.withOpacity(.3),
              child: Icon(Icons.account_balance_wallet,
                  size: 20.sp, color: Colors.white),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalKeys.appName.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getJoinedText(userData.startPackage!),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.sp),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getDaysLeftText(userData.remindDays ?? 0),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: userData.getPackageProgress(),
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8.h,
          ),
        ),
      ],
    );
  }

  String _getJoinedText(DateTime joinDate) {
    final formattedDate = formatDate(joinDate);
    return '${AppLocalKeys.joined.tr()} $formattedDate';
  }

  String _getDaysLeftText(int days) {
    final remainingDays = days >= 0 ? days : 0;

    if (remainingDays == 0) {
      return AppLocalKeys.subscriptionExpired.tr();
    } else if (remainingDays == 1) {
      return '1 ${AppLocalKeys.dayLeft.tr()}';
    } else {
      return '$remainingDays ${AppLocalKeys.daysLeft.tr()}';
    }
  }

  void saveUserExerciseInfo(TraineeModel userData) {
    if (userData.exerciseId != null) {
      SharedPreferencesHelper.setData(
        AppConstants.exerciseId,
        userData.exerciseId,
      );
    }
  }
}

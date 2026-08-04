import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/home/admin/logic/trainees_cubit.dart';
import 'package:team_ar/features/home/admin/logic/trainees_state.dart';
import 'package:team_ar/features/users_management/widget/user_status_card.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/widgets/app_bar_back_button.dart';

class UsersAboutToExpireScreen extends StatefulWidget {
  const UsersAboutToExpireScreen({super.key});

  @override
  State<UsersAboutToExpireScreen> createState() =>
      _UsersAboutToExpireScreenState();
}

class _UsersAboutToExpireScreenState extends State<UsersAboutToExpireScreen> {
  @override
  void initState() {
    context.read<TraineeCubit>().getUsersAboutToExpired();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: const AppBarBackButton(),
        title: Text(
          AppLocalKeys.usersAboutToExpire.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontSize: 21.sp,
              ),
        ),
      ),
      body: BlocBuilder<TraineeCubit, TraineeState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<TraineeCubit>().getUsersAboutToExpired(),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange[800], size: 28.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "هذه القائمة تعرض الأعضاء الذين اقترب موعد انتهاء باقتهم أو انتهت بالفعل لتسهيل متابعتهم وتجديد اشتراكاتهم.",
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                if (state is TraineeLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const LinearProgressIndicator(
                        color: AppColors.primaryColor),
                  ),
                if (state is TraineeSuccess && state.trainees.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.trainees.length,
                      padding: EdgeInsets.only(top: 4.h, bottom: 20.h),
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.userInfo,
                            arguments: state.trainees[index],
                          );
                        },
                        child: UserStatusCard(
                          firstName: state.trainees[index].userName ?? "",
                          isActive: (state.trainees[index].remindDays ?? 0) > 0,
                          currentDays: state.trainees[index].remindDays ?? 0,
                        ),
                      ),
                    ),
                  ),
                if (state is TraineeSuccess && state.trainees.isEmpty)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.emptyPageEmpty,
                          height: 180.h,
                          width: 180.w,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "لا يوجد أعضاء اقترب انتهاء اشتراكاتهم حالياً",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.black.withOpacity(.6),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                  ),
                        ),
                      ],
                    ),
                  ),
                if (state is TraineeFailure)
                  Center(
                    child: Text(
                      state.errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.red,
                            fontSize: 18.sp,
                          ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

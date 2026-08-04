import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/home/admin/logic/trainees_cubit.dart';
import 'package:team_ar/features/home/admin/logic/trainees_state.dart';
import 'package:team_ar/features/home/admin/widget/new_trainee_card.dart';
import 'package:team_ar/features/home/admin/widget/user_info_section.dart';
import 'package:team_ar/features/notification/services/push_notifications_services.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_local_keys.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int totalTrainees = 0;
  bool isLoading = false;

  @override
  void initState() {
    context.read<TraineeCubit>().getNewTrainees();
    FirebaseNotificationsServices.listenToTokenRefresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          AppLocalKeys.home.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
        ),
        leading: const SizedBox.shrink(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<TraineeCubit>().getNewTrainees();
          },
          child: BlocBuilder<TraineeCubit, TraineeState>(
            builder: (context, state) {
              isLoading = state is TraineeLoading;
              totalTrainees =
                  state is TraineeSuccess ? state.trainees.length : 0;
              return Column(
                children: [
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(22.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalKeys.totalRequests.tr(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.insights_rounded,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  totalTrainees.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 34.sp,
                                  ),
                                ),
                          SizedBox(height: 8.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              child: Image.asset(
                                AppAssets.progressWave,
                                height: 45.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const UserInfoSection(),

                  state.whenOrNull(
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        failure: (errorMessage) => Center(
                          child: Text(
                            errorMessage,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.red,
                                ),
                          ),
                        ),
                        success: (trainees) {
                          if (trainees.isEmpty) {
                            return Expanded(
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
                                    AppLocalKeys.noTrainees.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: AppColors.black
                                                .withOpacity(.6),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.sp),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: trainees.length,
                              padding: EdgeInsets.only(top: 4.h, bottom: 20.h),
                              itemBuilder: (context, index) => NewTraineeCard(
                                trainee: trainees[index],
                              ),
                            ),
                          );
                        },
                      ) ??
                      const SizedBox() // Default case
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

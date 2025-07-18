import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/home/admin/logic/trainees_cubit.dart';
import 'package:team_ar/features/home/admin/logic/trainees_state.dart';
import 'package:team_ar/features/home/admin/widget/new_trainee_card.dart';
import 'package:team_ar/features/home/admin/widget/user_info_section.dart';
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
        actions: [
          IconButton(
            onPressed: () {

            },

            icon: Icon(
              Icons.notifications_outlined,
              size: 25.sp,
              color: AppColors.grey,
            ),
          )
        ],
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
              totalTrainees = state is TraineeSuccess ? state.trainees.length : 0;
              return Column(
                children: [
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withOpacity(.4),
                      borderRadius: BorderRadius.circular(20.sp),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 21.0, vertical: 21.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalKeys.totalRequests.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp,
                                    ),
                              ),
                              Icon(
                                Icons.more_horiz,
                                color: AppColors.primaryColor,
                                size: 25.sp,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 21.h,
                          ),
                          isLoading
                              ? const CircularProgressIndicator(
                                  color: AppColors.lightBlue,
                                )
                              : Text(
                                  totalTrainees.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Image.asset(
                            AppAssets.progressWave,
                            height: 60.h,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  const UserInfoSection(),

                  state.whenOrNull(
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.lightBlue,
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
                                children: [
                                  Image.asset(
                                    AppAssets.emptyPageEmpty,
                                    height: 200.h,
                                    width: 200.w,
                                  ),
                                  SizedBox(
                                    height: 12.h,
                                  ),
                                  Text(
                                    AppLocalKeys.noTrainees.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: AppColors.black
                                                .withOpacity(.7)),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Expanded(
                            child: ListView.separated(
                              itemCount: trainees.length,
                              itemBuilder: (context, index) => NewTraineeCard(
                                trainee: trainees[index],
                              ),
                              separatorBuilder: (context, index) => Column(
                                children: [
                                  SizedBox(height: 21.h),
                                  const Divider(
                                    color: AppColors.grey,
                                    thickness: .1,
                                  ),
                                ],
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

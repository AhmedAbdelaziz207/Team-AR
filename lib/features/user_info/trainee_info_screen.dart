import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/core/widgets/plans_list_card.dart';
import 'package:team_ar/features/auth/register/model/user_model.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/home/user/logic/user_cubit.dart';
import 'package:team_ar/features/home/user/logic/user_state.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_cubit.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_state.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';
import 'package:team_ar/features/user_info/model/trainee_model.dart';
import 'package:team_ar/features/user_info/widget/floating_menu.dart';

class TraineeInfoScreen extends StatefulWidget {
  final TraineeModel? traineeModel;

  const TraineeInfoScreen({super.key, this.traineeModel});

  @override
  State<TraineeInfoScreen> createState() => _TraineeInfoScreenState();
}

class _TraineeInfoScreenState extends State<TraineeInfoScreen> {
  @override
  void initState() {
    context.read<UserCubit>().getTrainee(
          widget.traineeModel?.id ?? "",
        );
    context.read<UserPlansCubit>().getUserPlan(
          widget.traineeModel?.packageId ?? 0,
        );
    super.initState();
  }

  late TrainerModel trainee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          AppLocalKeys.traineeInfo.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const AppBarBackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, AppLocalKeys.plan.tr()),

            BlocBuilder<UserPlansCubit, UserPlansState>(
              builder: (context, state) {
                if (state is UserPlansLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return PlansListCard(
                  plan: state is UserPlansLoaded ? state.plans[0] : UserPlan(),
                  isSelected: true,
                  backgroundColor: AppColors.primaryColor,
                );
              },
            ),

            const Divider(
              thickness: 1,
            ),
            const SizedBox(height: 16),

            // Basic Info
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is UserFailure) {
                  return Center(child: Text(state.errorMessage));
                }

                if (state is GetTrainee) {
                  trainee = state.userData;

                  log("Trainee: ${trainee.userName.toString()}");

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, "Basic Info"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoText(
                              AppLocalKeys.name.tr(),
                              state.userData.userName ?? "",
                              context,
                            ),
                            _buildInfoText(AppLocalKeys.gender.tr(),
                                trainee.gender ?? "", context),
                            _buildInfoText(AppLocalKeys.age.tr(),
                                "${trainee.age ?? 0}", context),
                            _buildInfoText(AppLocalKeys.weight.tr(),
                                "${trainee.weight ?? 0} kg", context),
                          ],
                        ),
                      ),
                      const Divider(),

                      // Contact Info
                      _buildSectionTitle(context, "Contact"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoText(AppLocalKeys.phone.tr(),
                                trainee.phone ?? "", context),
                            _buildInfoText(AppLocalKeys.email.tr(),
                                trainee.email ?? "", context),
                            _buildInfoText(
                              AppLocalKeys.address.tr(),
                              trainee.address ?? "",
                              context,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),

                      // Lifestyle
                      _buildSectionTitle(context, "Lifestyle"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoText(AppLocalKeys.aboutYourWork.tr(),
                                trainee.dailyWork ?? "", context),
                            _buildInfoText(AppLocalKeys.areYouSmoking.tr(),
                                trainee.areYouSmoker ?? "", context),
                            _buildInfoText(
                              AppLocalKeys.lastTimeTrained.tr(),
                              trainee.lastExercise ?? "",
                              context,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),

                      // Nutrition
                      _buildSectionTitle(context, "Nutrition"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoText(AppLocalKeys.foodSystem.tr(),
                                trainee.foodSystem ?? "", context),
                            _buildInfoText(AppLocalKeys.numberOfMeals.tr(),
                                "${trainee.numberOfMeals ?? 0}", context),
                            _buildInfoText(
                              AppLocalKeys.allergyOfFood.tr(),
                              trainee.allergyOfFood ?? "",
                              context,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),

                      // Health & Goals
                      _buildSectionTitle(context, "Health & Goals"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoText(AppLocalKeys.aimOfJoin.tr(),
                                trainee.aimOfJoin ?? "", context),
                            _buildInfoText(AppLocalKeys.haveAnyPain,
                                trainee.anyPains ?? "", context),
                            _buildInfoText(AppLocalKeys.haveInfection,
                                trainee.anyInfection ?? "", context),
                            _buildInfoText(
                              AppLocalKeys.numberOfDaysForTraining,
                              "${trainee.numberOfDays ?? 0}",
                              context,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {

         if (state is GetTrainee) {
           final trainee = state.userData;

           return FloatingMenu(
             trainee: trainee,
             exerciseId: widget.traineeModel?.exerciseId,
           );
         }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String? title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 6,
      ),
      child: Text(
        title!,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 21.sp,
              color: AppColors.primaryColor,
              fontFamily: "Cairo",
            ),
      ),
    );
  }

  Widget _buildInfoText(String? label, String? value, context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:  ",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    fontFamily: "Cairo",
                    fontSize: 16.sp,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              "$value",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.black,
                    fontSize: 16.sp,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

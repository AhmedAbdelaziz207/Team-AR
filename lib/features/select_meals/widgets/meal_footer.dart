import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_cubit.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_state.dart';
import '../../../core/routing/routes.dart';

class MealSummaryFooter extends StatelessWidget {
  const MealSummaryFooter({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      child: BlocBuilder<MealCubit, MealState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 8.h,
              ),
              state.maybeMap(
                loaded: (value) => Text(
                  "Total:   ${context.read<MealCubit>().totalCalories} cal /Day",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                        fontSize: 14.sp,
                        fontFamily: "Cairo",
                      ),
                ),
                orElse: () => const SizedBox(),
              ),
              SizedBox(
                height: 12.h,
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          context
                              .read<MealCubit>()
                              .assignDietMealForUser(userId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: state is MailAssignLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.white,
                              )
                            : Text(
                                AppLocalKeys.next.tr(),
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          Routes.addWorkout,
                          arguments: userId,

                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(AppLocalKeys.save.tr()),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

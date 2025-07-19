import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/add_workout/model/add_workout_params.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_cubit.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_state.dart';
import '../../../core/routing/routes.dart';

class MealSummaryFooter extends StatefulWidget {
  const MealSummaryFooter({
    super.key,
    required this.userId,
    required this.isUpdate,
  });

  final String userId;
  final bool isUpdate;

  @override
  State<MealSummaryFooter> createState() => _MealSummaryFooterState();
}

class _MealSummaryFooterState extends State<MealSummaryFooter> {
  int mealCount = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      child: BlocConsumer<MealCubit, MealState>(
        listener: (context, state) {
          if (state is MailAssigned) {
            if (mounted) {
              mealCount = context.read<MealCubit>().mealNum;
              setState(() {});
            }
          }
        },
        builder: (context, state) {
          final cubit = context.read<MealCubit>();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              state.maybeMap(
                loaded: (_) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMacroText("Calories", "${cubit.totalCalories.toStringAsFixed(1)} cal"),
                          _buildMacroText("Protein", "${cubit.totalProtein.toStringAsFixed(1)} g"),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMacroText("Carbs", "${cubit.totalCarbs.toStringAsFixed(1)} g"),
                          _buildMacroText("Fats", "${cubit.totalFats.toStringAsFixed(1)} g"),
                        ],
                      ),
                    ],
                  ),
                ),
                orElse: () => const SizedBox(),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: mealCount == 5 || widget.isUpdate
                            ? null
                            : () {
                          context.read<MealCubit>().assignDietMealForUser(
                            widget.userId,
                            isUpdate: widget.isUpdate,
                          );
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
                            : Text(AppLocalKeys.next.tr()),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await context
                            .read<MealCubit>()
                            .assignDietMealForUser(
                          widget.userId,
                          isUpdate: widget.isUpdate,
                        )
                            .then((value) {
                          if (widget.isUpdate) {
                            Navigator.pop(context);
                            return;
                          }
                          Navigator.pushReplacementNamed(
                            context,
                            Routes.addWorkout,
                            arguments: AddWorkoutParams(
                              traineeId: widget.userId,
                              exerciseId: null,
                            ),
                          );
                        });
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
  Widget _buildMacroText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: "Cairo",
            fontWeight: FontWeight.w400,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

}

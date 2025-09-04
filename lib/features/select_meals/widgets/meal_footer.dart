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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Assign the meal first.
                      await context.read<MealCubit>().assignDietMealForUser(
                            widget.userId,
                            isUpdate: widget.isUpdate,
                          );

                      if (!mounted) return;

                      // Handle navigation after the meal is assigned.
                      if (widget.isUpdate) {
                        // If updating, just pop the screen.
                        Navigator.pop(context);
                        return;
                      }

                      // If adding a new meal plan, check if all meals are added.
                      if (context.read<MealCubit>().mealNum > 5) {
                        // If all 5 meals are added, navigate to the next step.
                        Navigator.pushReplacementNamed(
                          context,
                          Routes.addWorkout,
                          arguments: AddWorkoutParams(
                            traineeId: widget.userId,
                          ),
                        );
                      }
                      // If not all meals are added, the cubit will automatically
                      // update the state for the next meal selection. No navigation needed.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.isUpdate
                          ? AppLocalKeys.save.tr()
                          : (context.watch<MealCubit>().mealNum < 5
                              ? AppLocalKeys.next.tr()
                              : AppLocalKeys.save.tr()),
                    ),
                  ),
                ),
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

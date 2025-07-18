import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/diet/logic/user_diet_cubit.dart';
import 'package:team_ar/features/diet/logic/user_diet_state.dart';
import 'package:team_ar/features/update_user_diet/widget/admin_user_meal_card.dart';
import '../diet/model/user_diet.dart';
import '../select_meals/model/select_meal_params.dart';

class AdminMealsScreen extends StatefulWidget {
  const AdminMealsScreen({
    super.key,
    this.userId,
  });

  final String? userId;

  @override
  State<AdminMealsScreen> createState() => _AdminMealsScreenState();
}

class _AdminMealsScreenState extends State<AdminMealsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserDietCubit>().getUserDiet(userId: widget.userId ?? "");
  }

  int numberOfMeals = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const AppBarBackButton(),
        title: Text(
          AppLocalKeys.manageUserMeals.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            fontFamily: "Cairo",
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<UserDietCubit, UserDietState>(
        listener: (context, state) {
          if (state is UserDietSuccess) {
            final groupedTypes = state.diet.map((e) => e.foodType).toSet();

            setState(() {
              numberOfMeals = groupedTypes.length;
            });

            log("number of meals: $numberOfMeals");
          }
        },
        builder: (context, state) {
          if (state is UserDietLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserDietFailure) {
            return Center(
              child: Text(
                "Failed to load meals",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          if (state is UserDietSuccess) {
            final meals = state.diet;

            if (meals.isEmpty) {
              return Column(
                children: [
                  SizedBox(
                    height: 40.h,
                  ),
                  Image.asset(AppAssets.noData),
                  SizedBox(
                    height: 21.h,
                  ),
                  Center(
                    child: Text(
                      AppLocalKeys.noMeals.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                            fontFamily: "Cairo",
                          ),
                    ),
                  ),
                ],
              );
            }
            // Group meals by foodType
            final grouped = <int, List<UserDiet>>{};
            for (var meal in meals) {
              final type = meal.foodType ?? 0;
              grouped.putIfAbsent(type, () => []).add(meal);
            }
            return RefreshIndicator(
              onRefresh: () async => context
                  .read<UserDietCubit>()
                  .getUserDiet(userId: widget.userId ?? ""),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: grouped.entries.map((entry) {
                    final meals = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              meals.first.getMealName(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Cairo",
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.selectUserMeals,
                                  arguments: SelectMealParams(
                                      userId: widget.userId!,
                                      mealNum: entry.key,
                                      isUpdate: true),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryColor,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalKeys.replace.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                          fontFamily: "Cairo",
                                        ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.replay_circle_filled_outlined,
                                    size: 16,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),

                        /// Meal cards
                        ...meals.map(
                          (userDiet) => AdminMealCard(
                            mealName:
                                userDiet.meal?.name ?? userDiet.name ?? '',
                            amount: userDiet.numOfGrams?.toString() ?? '0',
                            imageUrl: userDiet.meal?.imageURL ?? '',
                            onReplace: () {
                              // Replace logic
                            },
                          ),
                        ),

                        const Divider(height: 30),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          }

          return const SizedBox(); // fallback
        },
      ),
      floatingActionButton: numberOfMeals <= 5
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryColor,
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  Routes.selectUserMeals,
                  arguments: SelectMealParams(
                    userId: widget.userId!,
                    mealNum: ++numberOfMeals,
                  ),
                ).then(
                  (value) {
                    context
                        .read<UserDietCubit>()
                        .getUserDiet(userId: widget.userId ?? "");
                  },
                );
              },
              child: const Icon(Icons.add),
            )
          : const SizedBox(),
    );
  }
}

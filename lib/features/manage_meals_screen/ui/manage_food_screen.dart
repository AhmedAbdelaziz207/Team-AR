import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_cubit.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_state.dart';
import 'package:team_ar/features/manage_meals_screen/widget/meal_card.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/app_local_keys.dart';

class ManageMealsScreen extends StatefulWidget {
  const ManageMealsScreen({super.key});

  @override
  State<ManageMealsScreen> createState() => _ManageMealsScreenState();
}

class _ManageMealsScreenState extends State<ManageMealsScreen> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  final List<String> categories = [
    AppLocalKeys.proteins.tr(),
    AppLocalKeys.fats.tr(),
    AppLocalKeys.carbs.tr(),
    AppLocalKeys.vegetables.tr(),
  ];
  int selectedTab = 0;

  getData() async {
    context.read<MealCubit>().getMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            getData();
          },
          child: Column(
            children: [
              SizedBox(height: 16.h),

              // 🔹 Tab Row
              SizedBox(
                height: 48.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedTab == index;
                    return GestureDetector(
                      onTap: () {
                        setState(
                          () => selectedTab = index,
                        );
                      },
                      child: Card(
                        elevation: isSelected ? 4 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.lightBlue
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        color: isSelected
                            ? AppColors.lightBlue.withOpacity(0.85)
                            : Colors.white,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => setState(() => selectedTab = index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : AppColors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // 🔹 Meals List
              Expanded(
                child: BlocBuilder<MealCubit, MealState>(
                  builder: (context, state) {
                    return state.maybeMap(
                      loading: (_) =>
                          const Center(child: CircularProgressIndicator()),
                      failure: (value) => Center(
                        child: Text(value.message,
                            style: const TextStyle(color: Colors.red)),
                      ),
                      loaded: (value) {
                        final filteredMeals = value.meals
                            .where((meal) => meal.foodCategory == selectedTab)
                            .toList();
                        if (filteredMeals.isEmpty) {
                          return Center(
                              child: Text(
                            AppLocalKeys.noMealsFound.tr(),
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Cairo",
                              fontSize: 21.sp,
                            ),
                          ));
                        }

                        return ListView.builder(
                          itemCount: filteredMeals.length,
                          itemBuilder: (context, index) => MealCard(
                            meal: filteredMeals[index],
                          ),
                        );
                      },
                      orElse: () => const SizedBox(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lightBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          getData();
          await Navigator.pushNamed(context, Routes.addMeal).then(
            (value) => getData(),
          );
        },
      ),
    );
  }
}

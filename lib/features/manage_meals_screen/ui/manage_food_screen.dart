import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late SharedPreferences _prefs;
  final Map<int, Map<String, int>> _mealOrders = {};
  bool _isLoadingOrder = true;

  @override
  void initState() {
    super.initState();
    _initOrder().then((_) => getData());
  }

  Future<void> _initOrder() async {
    _prefs = await SharedPreferences.getInstance();
    // Load orders for each category
    for (int i = 0; i < categories.length; i++) {
      final order = _prefs.getStringList('meal_order_$i') ?? [];
      _mealOrders[i] = {};
      for (int j = 0; j < order.length; j++) {
        _mealOrders[i]![order[j]] = j;
      }
    }
    setState(() => _isLoadingOrder = false);
  }

  Future<void> _saveMealOrder(int category, List<String> mealIds) async {
    await _prefs.setStringList('meal_order_$category', mealIds);
  }

  final List<String> categories = [
    AppLocalKeys.proteins.tr(),
    AppLocalKeys.fats.tr(),
    AppLocalKeys.carbs.tr(),
    AppLocalKeys.vegetables.tr(),
    AppLocalKeys.naturalSupplements.tr(),
  ];
  int selectedTab = 0;

  getData() async {
    context.read<MealCubit>().getMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalKeys.manageFoods.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontSize: 21.sp,
              ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          log("refreshed");
          await _initOrder();
          getData();
        },
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 8.h),
              SizedBox(
                height: 44.h,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final isSelected = selectedTab == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedTab = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.lightBlue : Colors.grey[100],
                          borderRadius: BorderRadius.circular(22.r),
                          border: Border.all(
                            color: isSelected ? AppColors.lightBlue : Colors.transparent,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.lightBlue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.grey,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: BlocBuilder<MealCubit, MealState>(
                  builder: (context, state) {
                    return state.maybeMap(
                      loading: (_) =>
                          const Center(child: CircularProgressIndicator(color: AppColors.lightBlue)),
                      failure: (value) => Center(
                        child: Text(value.message,
                            style: TextStyle(color: Colors.red, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
                      loaded: (value) {
                        final filteredMeals = value.meals
                            .where((meal) => meal.foodCategory == selectedTab)
                            .toList();
                        if (filteredMeals.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant_menu_rounded, size: 70.sp, color: Colors.grey[300]),
                                SizedBox(height: 12.h),
                                Text(
                                  AppLocalKeys.noMealsFound.tr(),
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Cairo",
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (_isLoadingOrder) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.lightBlue));
                        }

                        final categoryOrder = _mealOrders[selectedTab] ?? {};
                        filteredMeals.sort((a, b) {
                          final orderA = categoryOrder[a.id.toString()] ?? filteredMeals.length;
                          final orderB = categoryOrder[b.id.toString()] ?? filteredMeals.length;
                          return orderA.compareTo(orderB);
                        });

                        return ReorderableListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(top: 4.h, bottom: 90.h),
                          itemCount: filteredMeals.length,
                          itemBuilder: (context, index) => MealCard(
                            key: Key('meal_${filteredMeals[index].id}'),
                            meal: filteredMeals[index],
                          ),
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (oldIndex < newIndex) newIndex -= 1;
                              final item = filteredMeals.removeAt(oldIndex);
                              filteredMeals.insert(newIndex, item);

                              final order = filteredMeals.map((m) => m.id.toString()).toList();
                              _saveMealOrder(selectedTab, order);

                              _mealOrders[selectedTab] = {};
                              for (int i = 0; i < order.length; i++) {
                                _mealOrders[selectedTab]![order[i]] = i;
                              }
                            });
                          },
                          buildDefaultDragHandles: true,
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

import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_cubit.dart';
import 'package:team_ar/features/manage_meals_screen/logic/meal_state.dart';
import 'package:team_ar/features/select_meals/widgets/meal_category.dart';

class MealList extends StatefulWidget {
  const MealList({super.key});

  @override
  State<MealList> createState() => _MealListState();
}

class _MealListState extends State<MealList> {
  @override
  void initState() {
    super.initState();
    context.read<MealCubit>().getMeals();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MealCubit, MealState>(
      listener: (context, state) {
        state.maybeWhen(
          assigned: () {
            // After pressing Next/Finish: refetch once from server
            context.read<MealCubit>().getMeals();
          },
          orElse: () {},
        );
      },
      child: BlocBuilder<MealCubit, MealState>(
      buildWhen: (previous, current) => current.maybeWhen(
        loading: () => true,
        loaded: (_) => true,
        failure: (_) => true,

        orElse: () => false,
      ),
      builder: (context, state) {
        return state.maybeMap(
          loading: (_) => const Center(child: CircularProgressIndicator()),
          loaded: (value) {
            final meals = value.meals;
            
            final proteinsMeals = meals.where((meal) => meal.foodCategory == 0).toList();
            final fatsMeals = meals.where((meal) => meal.foodCategory == 1).toList();
            final carbsMeals = meals.where((meal) => meal.foodCategory == 2).toList();
            final vegetablesMeals = meals.where((meal) => meal.foodCategory == 3).toList();
            final naturalSupplementsMeals = meals.where((meal) => meal.foodCategory == 4).toList();

            // Do NOT wrap with Expanded here; parent already wraps MealList with Expanded
            return ListView(
              children: [
                MealCategory(
                  title: AppLocalKeys.proteins.tr(),
                  meals: proteinsMeals,
                ),
                MealCategory(
                  title: AppLocalKeys.fats.tr(),
                  meals: fatsMeals,
                ),
                MealCategory(
                  title: AppLocalKeys.carbs.tr(),
                  meals: carbsMeals,
                ),
                MealCategory(
                  title: AppLocalKeys.vegetables.tr(),
                  meals: vegetablesMeals,
                ),
                MealCategory(
                  title: AppLocalKeys.naturalSupplements.tr(),
                  meals: naturalSupplementsMeals,
                ),
              ],
            );
          },
          failure: (value) => Center(
            child: Text(
              value.message,
              style: const TextStyle(color: Colors.red),
            ),
          ),

          orElse: () => const SizedBox.shrink(),
        );
      },
    ),
    );
  }
}

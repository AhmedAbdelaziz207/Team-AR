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
    return BlocBuilder<MealCubit, MealState>(
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

            final categories = meals
                .map((e) => e.foodCategory)
                .whereType<String>()
                .toSet()
                .toList();

            return ListView(
              children: categories.map((category) {

                return MealCategory(
                  title: category,
                  meals: meals,
                );
              }).toList(),
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
    );
  }
}

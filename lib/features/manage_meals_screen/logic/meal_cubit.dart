import 'dart:developer';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/manage_meals_screen/repos/diet_meal_repository.dart';
import 'package:team_ar/features/select_meals/model/user_meal_request.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/network/api_result.dart';
import '../model/meal_model.dart';
import 'meal_state.dart';

class MealCubit extends Cubit<MealState> {
  MealCubit() : super(const MealState.initial());

  String? userId;
  int mealNum = 1;

  final nameController = TextEditingController();
  final caloriesController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final proteinController = TextEditingController();
  int mealType = 0;
  File? image;

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }

    emit(MealState.imagePicked(image!));
  }

  final DietMealRepository mealRepository =
      DietMealRepository(getIt<ApiService>());

  File? dietImage = File("path");

  void getMeals() async {
    emit(
      const MealState.loading(),
    );

    final ApiResult<List<DietMealModel>?> result =
        await mealRepository.getDietMeals();

    result.when(
      success: (data) {
        emit(MealState.loaded(meals: data ?? []));
      },
      failure: (error) {
        emit(
          MealState.failure(
            message:
                error.getErrorsMessage() ?? AppLocalKeys.unexpectedError.tr(),
          ),
        );
      },
    );
  }

  void deleteMeal(int id) async {
    await mealRepository.deleteMeal(id);
  }

  void addMeal() async {
    emit(const MealState.loading());
    final result = await mealRepository.addDietMeal(
      diet: DietMealModel(
        id: 0,
        name: nameController.text,
        numOfCalories: double.parse(caloriesController.text) / 100,
        numOfCarbs: double.parse(carbsController.text) / 100,
        numOfFats: double.parse(fatController.text) / 100,
        numOfProtein: double.parse(proteinController.text) / 100,
        foodCategory: mealType,
      ),
      dietImage: image!,
    );

    result.when(
      success: (data) {
        emit(const MealState.added());
      },
      failure: (error) {
        emit(
          MealState.failure(
            message:
                error.getErrorsMessage() ?? AppLocalKeys.unexpectedError.tr(),
          ),
        );
      },
    );
  }

  double totalCalories = 0;
  double totalFats = 0;
  double totalCarbs = 0;
  double totalProtein = 0;
  double calculateTotalCalories(List<DietMealModel> meals) {
    double calories = 0;
    double fats = 0;
    double carbs = 0;
    double protein = 0;

    for (var meal in meals) {
      if (meal.isSelected ?? false) {
        final grams = meal.numOfGrams ?? 0;

        calories += (meal.numOfCalories ?? 0) * grams;
        fats     += (meal.numOfFats ?? 0) * grams;
        carbs    += (meal.numOfCarbs ?? 0) * grams;
        protein  += (meal.numOfProtein ?? 0) * grams;
      }
    }

    totalCalories = calories;
    totalFats     = fats;
    totalCarbs    = carbs;
    totalProtein  = protein;
    log("fats : $fats , carbs : $carbs , protein : $protein");

    if (state is MealsLoaded) {
      emit(MealState.loaded(meals: meals));
    }

    return calories;
  }
  void toggleMealSelection(int mealId, double quantity) {
    final currentState = state;

    if (currentState is MealsLoaded) {
      final updatedMeals = currentState.meals.map((meal) {
        if (meal.id == mealId) {
          return meal.copyWith(isSelected: !(meal.isSelected ?? false));
        }
        return meal;
      }).toList();

      totalCalories = calculateTotalCalories(updatedMeals);

      emit(MealState.loaded(meals: updatedMeals));
    }
  }

  void updateMealQuantity(int mealId, double newQuantity) {
    final currentState = state;

    if (currentState is MealsLoaded) {
      final updatedMeals = currentState.meals.map((meal) {
        if (meal.id == mealId) {
          return meal.copyWith(numOfGrams: newQuantity);
        }
        return meal;
      }).toList();

      totalCalories = calculateTotalCalories(updatedMeals);

      emit(MealState.loaded(meals: updatedMeals));
    }
  }


  Future<void> assignDietMealForUser(String userId, {bool? isUpdate}) async {
    log("isUpdate Meal : $isUpdate");

    // Step 0: Validate state
    final currentState = state;
    if (currentState is! MealsLoaded) return;

    final allMeals = currentState.meals;

    // ✅ Step 1: Check if any item is selected
    final selectedMeals =
        allMeals.where((meal) => meal.isSelected == true).toList();
    if (selectedMeals.isEmpty) {
      // emit(const MealState.failure(message: "Please select at least one meal."));
      return;
    }

    // emit(const MealState.loading());

    final selectedFoods = selectedMeals
        .map((meal) => FoodItem(
              foodId: meal.id!,
              note: "", // or attach a note if you support it
              numOfGrams: meal.numOfGrams ?? 100,
            ))
        .toList();

    final userMeal = UserMealRequestModel(
      applicationUserId: userId,
      foods: selectedFoods,
      foodType: mealNum,
    );

    final result = await mealRepository.assignDietMealToTrainee(
      userMeal,
      isUpdate: isUpdate ?? false,
    );

    result.when(
      success: (_) {
        // ✅ Step 2: Reset all meals to unselected/default
        final resetMeals = allMeals
            .map((meal) => meal.copyWith(
                  isSelected: false,
                  numOfGrams: 100,
                ))
            .toList();

        mealNum++;
        emit(MealState.loaded(meals: resetMeals));
        emit(const MealState.assigned());
      },
      failure: (error) {
        emit(MealState.failure(
          message: error.getErrorsMessage() ?? "Assigning failed",
        ));
      },
    );
  }
}

import 'dart:developer';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/network/api_error_model.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/manage_meals_screen/repos/diet_meal_repository.dart';
import 'package:team_ar/features/select_meals/model/user_meal_request.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/network/api_result.dart';
import '../model/meal_model.dart';
import 'meal_state.dart';

class MealCubit extends Cubit<MealState> {
  MealCubit() : super(const MealState.initial()) {
    mealName = getMealName(mealNum);
  }

  String? userId;
  int mealNum = 1;
  String mealName = "";
  bool initializedFromScreen = false; // prevent repeated re-initialization


  final nameController = TextEditingController();
  final arabicNameController = TextEditingController();
  final caloriesController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();
  final proteinController = TextEditingController();
  final usageInstructionsController = TextEditingController();
  final noteController = TextEditingController();
  int mealType = 0;
  File? image;

  // Prevent unnecessary refetching between steps
  bool _mealsFetched = false;
  List<DietMealModel>? _cachedMeals;

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // ضغط الصورة قبل استخدامها
      final compressedImage = await compressImage(File(pickedImage.path));
      image = compressedImage;
      emit(MealState.imagePicked(image!));
    }
  }

  Future<File> compressImage(File file) async {
    final dir = await Directory.systemTemp.createTemp();
    final targetPath =
        "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70, // ضبط جودة الصورة
      minWidth: 800, // الحد الأدنى للعرض
      minHeight: 800, // الحد الأدنى للارتفاع
    );

    return File(result!.path);
  }

  final DietMealRepository mealRepository =
      DietMealRepository(getIt<ApiService>());

  File? dietImage = File("path");

  Future<void> getMeals() async {
    // If already fetched, reuse cached data
    if (_mealsFetched && _cachedMeals != null) {
      if (!isClosed) emit(MealState.loaded(meals: _cachedMeals!));
      return;
    }

    emit(const MealState.loading());

    final ApiResult<List<DietMealModel>?> result =
        await mealRepository.getDietMeals();

    result.when(
      success: (data) {
        if (isClosed) return;
        _cachedMeals = data ?? [];
        _mealsFetched = true;
        emit(MealState.loaded(meals: _cachedMeals!));
      },
      failure: (error) {
      if (!isClosed) {
        emit(
          MealState.failure(
            message:
                error.getErrorsMessage() ?? AppLocalKeys.unexpectedError.tr(),
          ),
        );
      }
    }
    );
  }

  Future<void> updateMeal(DietMealModel meal) async {
    try {
      // Client-side validation
      final name = nameController.text.trim();
      final arabicName = arabicNameController.text.trim();
      if (name.isEmpty) {
        emit(MealState.failure(message: AppLocalKeys.fieldRequired.tr()));
        return;
      }

      double? calories = double.tryParse(caloriesController.text.trim());
      double? carbs = double.tryParse(carbsController.text.trim());
      double? fats = double.tryParse(fatController.text.trim());
      double? protein = double.tryParse(proteinController.text.trim());

      if (calories == null ||
          carbs == null ||
          fats == null ||
          protein == null) {
        emit(const MealState.failure(message: "Please enter valid numbers"));
        return;
      }

      emit(const MealState.loading());

      final result = await mealRepository
          .updateDietMeal(
            diet: meal.copyWith(
              name: name,
              arabicName: arabicName.isEmpty ? meal.arabicName : arabicName,
              numOfCalories: calories / 100,
              numOfCarbs: carbs / 100,
              numOfFats: fats / 100,
              numOfProtein: protein / 100,
            ),
            imageUrl: image?.path ?? "",
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () => ApiResult.failure(
              ApiErrorModel(
                message: 'انتهي الوقت, حاول مرة اخرى',
                statusCode: 408,
              ),
            ),
          );

      if (!isClosed) {
        result.when(
          success: (updated) async {
            await getMeals();
            if (isClosed) return;
            emit(const MealState.added()); // Success state to trigger snackbar
          },
          failure: (error) {
            emit(MealState.failure(
              message:
                  error.getErrorsMessage() ?? AppLocalKeys.unexpectedError.tr(),
            ));
          },
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(const MealState.failure(
          message: 'حدث خطأ أثناء تحديث الوجبة. يرجى المحاولة مرة أخرى',
        ));
      }
      log('Error in updateMeal: $e');
    }
  }

  void deleteMeal(int id) async {
    await mealRepository.deleteMeal(id);
    await getMeals();
  }

  

  static const Duration _timeoutDuration = Duration(seconds: 10);

  Future<void> addMeal() async {
    // Client-side validation
    final name = nameController.text.trim();
    final arabicName = arabicNameController.text.trim();
    if (name.isEmpty) {
      emit(MealState.failure(message: AppLocalKeys.fieldRequired.tr()));
      return;
    }
    if (image == null) {
      emit(MealState.failure(message: AppLocalKeys.pleaseSelectImage.tr()));
      return;
    }

    double? calories = double.tryParse(caloriesController.text.trim());
    double? carbs = double.tryParse(carbsController.text.trim());
    double? fats = double.tryParse(fatController.text.trim());
    double? protein = double.tryParse(proteinController.text.trim());

    log("=== VALIDATION DEBUG ===");
    log("Calories: $calories, Carbs: $carbs, Fats: $fats, Protein: $protein");
    log("Meal Type: $mealType");

    // Skip nutritional validation for natural supplements
    if (mealType != 4 && (calories == null || carbs == null || fats == null || protein == null)) {
      log("Validation failed for regular meal - missing nutritional values");
      emit(const MealState.failure(message: "Please enter valid numbers"));
      return;
    }
    
    // For natural supplements, set default values if not provided
    if (mealType == 4) {
      calories = 0;
      carbs = 0;
      fats = 0;
      protein = 0;
      log("Set default nutritional values for natural supplement");
    }

    emit(const MealState.loading());

    try {
      // For natural supplements (mealType == 4), use usage instructions as note
      final note = mealType == 4 ? usageInstructionsController.text.trim() : "";
      
      log("=== ADD MEAL DEBUG ===");
      log("Meal Type: $mealType");
      log("Note: '$note'");
      log("Usage Instructions Controller: '${usageInstructionsController.text}'");
      log("Is Natural Supplement: ${mealType == 4}");
      
      final dietMeal = DietMealModel(
        id: 0,
        name: name,
        arabicName: arabicName.isEmpty ? null : arabicName,
        numOfCalories: (calories ?? 0) / 100,
        numOfCarbs: (carbs ?? 0) / 100,
        numOfFats: (fats ?? 0) / 100,
        numOfProtein: (protein ?? 0) / 100,
        numOfGrams: 1,
        foodCategory: mealType,
        note: note,
      );
      
      log("DietMeal note field: '${dietMeal.note}'");
      
      final result = await mealRepository
          .addDietMeal(
            diet: dietMeal,
            dietImage: image!,
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () => ApiResult.failure(
              ApiErrorModel(
                message: 'انتهي الوقت, حاول مرة اخرى',
                statusCode: 408,
              ),
            ),
          );

      if (!isClosed) {
        result.when(
          success: (data) {
            emit(const MealState.added());
          },
          failure: (error) {
            emit(
              MealState.failure(
                message: error.getErrorsMessage() ??
                    AppLocalKeys.unexpectedError.tr(),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          const MealState.failure(
            message:
                'An error occurred while adding the meal. Please try again.',
          ),
        );
      }
      log('Error in addMeal: $e');
    }
  }

  double totalCalories = 0;
  double totalFats = 0;
  double totalCarbs = 0;
  double totalProtein = 0;

  void resetTotals() {
    totalCalories = 0;
    totalFats = 0;
    totalCarbs = 0;
    totalProtein = 0;
  }

  double calculateTotalCalories(List<DietMealModel> meals) {
    double calories = 0;
    double fats = 0;
    double carbs = 0;
    double protein = 0;

    for (var meal in meals) {
      if (meal.isSelected ?? false) {
        // Skip natural supplements (category 4) in calorie calculations
        if (meal.foodCategory == 4) continue;
        
        final grams = meal.numOfGrams ?? 0;

        calories += (meal.numOfCalories ?? 0) * grams;
        fats += (meal.numOfFats ?? 0) * grams;
        carbs += (meal.numOfCarbs ?? 0) * grams;
        protein += (meal.numOfProtein ?? 0) * grams;
      }
    }

    totalCalories = calories;
    totalFats = fats;
    totalCarbs = carbs;
    totalProtein = protein;
    log("fats : $fats , carbs : $carbs , protein : $protein");

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

  void toggleNaturalSupplementSelection(int mealId, String usageInstructions) {
    final currentState = state;
    log("usageInstructions $usageInstructions");
    if (currentState is MealsLoaded) {
      final updatedMeals = currentState.meals.map((meal) {
        if (meal.id == mealId) {
          return meal.copyWith(
            isSelected: !(meal.isSelected ?? false),
            usageInstructions: usageInstructions,
            numOfGrams: 0, // Natural supplements don't use grams
          );
        }
        return meal;
      }).toList();

      // Natural supplements don't contribute to calorie calculation
      totalCalories = calculateTotalCalories(updatedMeals);

      emit(MealState.loaded(meals: updatedMeals));
    }
  }

  void updateNaturalSupplementUsage(int mealId, String usageInstructions) {
    final currentState = state;

    if (currentState is MealsLoaded) {
      final updatedMeals = currentState.meals.map((meal) {
        if (meal.id == mealId) {
          return meal.copyWith(usageInstructions: usageInstructions);
        }
        return meal;
      }).toList();

      emit(MealState.loaded(meals: updatedMeals));
    }
  }

  Future<void> assignDietMealForUser(String userId, {bool? isUpdate}) async {
    log("isUpdate Meal : $isUpdate");
    log("usageInstructionsController ${noteController.text}");

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
              note: noteController.text, // Include usage instructions for natural supplements
              numOfGrams: meal.numOfGrams ?? 100,
            ))
        .toList();

    final userMeal = UserMealRequestModel(
      applicationUserId: userId,
      foods: selectedFoods,
      foodType: mealNum,
      Note: "",
    );

    // Emit assigning state so UI can show loading on Next/Finish button
    emit(const MealState.assignLoading());

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
                  usageInstructions: null, // Reset usage instructions
                ))
            .toList();

        // Reset footer values
        resetTotals();

        // Update counters and title BEFORE emitting state so UI updates together
        mealNum++;
        mealName = getMealName(mealNum);

        // Update cache and emit without refetching
        _cachedMeals = resetMeals;
        _mealsFetched = true;
        emit(MealState.loaded(meals: _cachedMeals!));
        emit(const MealState.assigned());
      },
      failure: (error) {
        emit(MealState.failure(
          message: error.getErrorsMessage() ?? "Assigning failed",
        ));
      },
    );
  }

  getMealName(int mealNum) {
    switch (mealNum) {
      case 1:
        return AppLocalKeys.firstMeal.tr();
      case 2:
        return AppLocalKeys.secondMeal.tr();
      case 3:
        return AppLocalKeys.thirdMeal.tr();
      case 4:
        return AppLocalKeys.fourthMeal.tr();
      case 5:
        return AppLocalKeys.fifthMeal.tr();
      default:
        return "";
    }
  }
}

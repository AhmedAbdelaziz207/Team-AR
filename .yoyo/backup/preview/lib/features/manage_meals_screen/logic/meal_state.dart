import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/meal_model.dart';

part 'meal_state.freezed.dart';

@freezed
class MealState with _$MealState {
  const factory MealState.initial() = _Initial;

  const factory MealState.loading() = MailLoading;
  const factory MealState.added() = MailAdded;
  const factory MealState.assigned() = MailAssigned;
  const factory MealState.assignLoading() = MailAssignLoading;

  const factory MealState.imagePicked(File image) = ImagePicked;

  const factory MealState.failure({required String message}) = MealFailure;

  const factory MealState.totalCalories({required int calories}) =
      UpdatedCalories;

  const factory MealState.loaded({required List<DietMealModel> meals}) =
      MealsLoaded;

  const factory MealState.nextMeal() = NextMeal;

}

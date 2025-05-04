import 'package:easy_localization/easy_localization.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/manage_meals_screen/model/meal_model.dart';
part 'user_diet.g.dart';

@JsonSerializable()
class UserDiet {
  @JsonKey(name: 'applicationUserId')
  final String? id;
  final String? name;

  @JsonKey(name: 'food') // maps to the JSON array you shared
  final DietMealModel? meal;
  final int? foodType;

  final int? totalItems;
  final int? totalCalories;
  final String? note;

  const UserDiet({
    this.id,
    this.name,
    this.meal,
    this.totalItems,
    this.totalCalories,
    this.note,
    this.foodType,
  });

  factory UserDiet.fromJson(Map<String, dynamic> json) =>
      _$UserDietFromJson(json);

  Map<String, dynamic> toJson() => _$UserDietToJson(this);

  getMealName() {
    switch (foodType) {
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
      case 6:
        return AppLocalKeys.sixthMeal.tr();
      default:
        return AppLocalKeys.firstMeal.tr();
    }
  }
}

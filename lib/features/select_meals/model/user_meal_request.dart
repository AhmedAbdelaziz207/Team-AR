import 'package:json_annotation/json_annotation.dart';

part 'user_meal_request.g.dart';

@JsonSerializable()
class UserMealRequestModel {
  final String applicationUserId;
  final int foodType;
  final List<FoodItem> foods;

  UserMealRequestModel({
    required this.applicationUserId,
    required this.foodType,
    required this.foods,
  });

  factory UserMealRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UserMealRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserMealRequestModelToJson(this);
}

@JsonSerializable()
class FoodItem {
  final int? foodId;
  final String? note;
  final double? numOfGrams;

  FoodItem({
     this.foodId,
     this.note,
     this.numOfGrams,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);

  Map<String, dynamic> toJson() => _$FoodItemToJson(this);
}

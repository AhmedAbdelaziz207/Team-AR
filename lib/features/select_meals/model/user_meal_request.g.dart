// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_meal_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserMealRequestModel _$UserMealRequestModelFromJson(
        Map<String, dynamic> json) =>
    UserMealRequestModel(
      applicationUserId: json['applicationUserId'] as String,
      foodType: (json['foodType'] as num).toInt(),
      foods: (json['foods'] as List<dynamic>)
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserMealRequestModelToJson(
        UserMealRequestModel instance) =>
    <String, dynamic>{
      'applicationUserId': instance.applicationUserId,
      'foodType': instance.foodType,
      'foods': instance.foods,
    };

FoodItem _$FoodItemFromJson(Map<String, dynamic> json) => FoodItem(
      foodId: (json['foodId'] as num?)?.toInt(),
      note: json['note'] as String?,
      numOfGrams: (json['numOfGrams'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FoodItemToJson(FoodItem instance) => <String, dynamic>{
      'foodId': instance.foodId,
      'note': instance.note,
      'numOfGrams': instance.numOfGrams,
    };

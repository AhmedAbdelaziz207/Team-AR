// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_diet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDiet _$UserDietFromJson(Map<String, dynamic> json) => UserDiet(
      id: json['applicationUserId'] as String?,
      name: json['name'] as String?,
      meal: json['food'] == null
          ? null
          : DietMealModel.fromJson(json['food'] as Map<String, dynamic>),
      totalItems: (json['totalItems'] as num?)?.toInt(),
      totalCalories: (json['totalCalories'] as num?)?.toInt(),
      note: json['note'] as String?,
      foodType: (json['foodType'] as num?)?.toInt(),
      numOfGrams: (json['numOfGrams'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserDietToJson(UserDiet instance) => <String, dynamic>{
      'applicationUserId': instance.id,
      'name': instance.name,
      'food': instance.meal,
      'foodType': instance.foodType,
      'numOfGrams': instance.numOfGrams,
      'totalItems': instance.totalItems,
      'totalCalories': instance.totalCalories,
      'note': instance.note,
    };

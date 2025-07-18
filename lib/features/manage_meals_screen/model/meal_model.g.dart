// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DietMealModel _$DietMealModelFromJson(Map<String, dynamic> json) =>
    DietMealModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      isSelected: json['isSelected'] as bool? ?? false,
      numOfGrams: (json['numOfGrams'] as num?)?.toInt() ?? 100,
      imageURL: json['imageURL'] as String?,
      numOfCalories: (json['numOfCalories'] as num?)?.toInt(),
      numOfProtein: (json['numOfProtein'] as num?)?.toInt(),
      numOfCarbs: (json['numOfCarbs'] as num?)?.toInt(),
      numOfFats: (json['numOfFats'] as num?)?.toInt(),
      foodCategory: (json['foodCategory'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DietMealModelToJson(DietMealModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isSelected': instance.isSelected,
      'imageURL': instance.imageURL,
      'numOfGrams': instance.numOfGrams,
      'numOfCalories': instance.numOfCalories,
      'numOfProtein': instance.numOfProtein,
      'numOfCarbs': instance.numOfCarbs,
      'numOfFats': instance.numOfFats,
      'foodCategory': instance.foodCategory,
    };

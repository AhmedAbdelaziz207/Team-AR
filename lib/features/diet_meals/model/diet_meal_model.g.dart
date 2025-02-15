// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DietMealModel _$DietMealModelFromJson(Map<String, dynamic> json) =>
    DietMealModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      numOfCalories: (json['numOfCalories'] as num?)?.toDouble(),
      numOfProtein: (json['numOfProtein'] as num?)?.toDouble(),
      imageURL: json['imageURL'] as String?,
    );

Map<String, dynamic> _$DietMealModelToJson(DietMealModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'numOfCalories': instance.numOfCalories,
      'numOfProtein': instance.numOfProtein,
      'imageURL': instance.imageURL,
    };

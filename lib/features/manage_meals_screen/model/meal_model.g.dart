// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DietMealModel _$DietMealModelFromJson(Map<String, dynamic> json) =>
    DietMealModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      arabicName: (json['arabicName'] ?? json['ArabicName']) as String?,
      isSelected: json['isSelected'] as bool? ?? false,
      numOfGrams: (json['numOfGrams'] as num?)?.toDouble() ?? 100,
      imageURL: json['imageURL'] as String?,
      numOfCalories: (json['numOfCalories'] as num?)?.toDouble(),
      numOfProtein: (json['numOfProtein'] as num?)?.toDouble(),
      numOfCarbs: (json['numOfCarps'] as num?)?.toDouble(),
      numOfFats: (json['numOfFats'] as num?)?.toDouble(),
      foodCategory: (json['foodCategory'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DietMealModelToJson(DietMealModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'arabicName': instance.arabicName,
      'isSelected': instance.isSelected,
      'imageURL': instance.imageURL,
      'numOfGrams': instance.numOfGrams,
      'numOfCalories': instance.numOfCalories,
      'numOfProtein': instance.numOfProtein,
      'numOfCarps': instance.numOfCarbs,
      'numOfFats': instance.numOfFats,
      'foodCategory': instance.foodCategory,
    };

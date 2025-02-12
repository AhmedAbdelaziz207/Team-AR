import 'dart:io';
import 'package:json_annotation/json_annotation.dart';

part 'diet_meal_model.g.dart';

@JsonSerializable()
class DietMealModel {
  final int? id;
  final String? name;
  final double? numOfCalories;
  final double? numOfProtein;
  final String? imageURL;
  // ignore: non_constant_identifier_names
  @JsonKey(includeFromJson: false, includeToJson: false)
  final File? image;

  DietMealModel({
    required this.id,
    required this.name,
    required this.numOfCalories,
    required this.numOfProtein,
    this.imageURL,
    this.image,
  });

  /// Factory method to create an instance from JSON
  factory DietMealModel.fromJson(Map<String, dynamic> json) =>
      _$DietMealModelFromJson(json);

  /// Method to convert the model instance to JSON
  Map<String, dynamic> toJson() => _$DietMealModelToJson(this);
}

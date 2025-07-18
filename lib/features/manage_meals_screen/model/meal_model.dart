import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal_model.g.dart';

@JsonSerializable()
class DietMealModel extends Equatable {
  final int? id;
  final String? name;
  final bool? isSelected;
  final String? imageURL;
  final double? numOfGrams;
  final double? numOfCalories;
  final double? numOfProtein;
  final double? numOfCarbs;
  final double? numOfFats;
  final int? foodCategory;
  @JsonKey(ignore: true)
  final String? image;

  DietMealModel({
    this.id,
    this.name,
    this.isSelected = false,
    this.numOfGrams = 100,
    this.imageURL,
    this.numOfCalories,
    this.numOfProtein,
    this.numOfCarbs,
    this.numOfFats,
    this.foodCategory,
    this.image,
  });

  factory DietMealModel.fromJson(Map<String, dynamic> json) =>
      _$DietMealModelFromJson(json);

  Map<String, dynamic> toJson() => _$DietMealModelToJson(this);

  // copyWith method
  DietMealModel copyWith({
    int? id,
    String? name,
    bool? isSelected,
    String? imageURL,
    double? numOfGrams,
    double? numOfCalories,
    double? numOfProtein,
    double? numOfCarbs,
    double? numOfFats,
    int? foodCategory,
    String? image,
  }) {
    return DietMealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
      imageURL: imageURL ?? this.imageURL,
      numOfGrams: numOfGrams ?? this.numOfGrams,
      numOfCalories: numOfCalories ?? this.numOfCalories,
      numOfProtein: numOfProtein ?? this.numOfProtein,
      numOfCarbs: numOfCarbs ?? this.numOfCarbs,
      numOfFats: numOfFats ?? this.numOfFats,
      foodCategory: foodCategory ?? this.foodCategory,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [id, name, imageURL, isSelected, numOfGrams];
}

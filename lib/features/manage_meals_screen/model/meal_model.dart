import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal_model.g.dart';

@JsonSerializable()
class DietMealModel extends Equatable {
  final int? id;
  final String? name;
  @JsonKey(name: 'arabicName')
  final String? arabicName;
  final bool? isSelected;
  final String? imageURL;
  final double? numOfGrams;
  final double? numOfCalories;
  final double? numOfProtein;
  @JsonKey(name: "numOfCarps")
  final double? numOfCarbs;
  final double? numOfFats;
  final int? foodCategory;
  final String? note;
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? image;
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? usageInstructions;

  DietMealModel({
    this.id,
    this.name,
    this.arabicName,
    this.isSelected = false,
    this.numOfGrams = 100,
    this.imageURL,
    this.numOfCalories,
    this.numOfProtein,
    this.numOfCarbs,
    this.numOfFats,
    this.foodCategory,
    this.note,
    this.image,
    this.usageInstructions,
  });

  factory DietMealModel.fromJson(Map<String, dynamic> json) =>
      _$DietMealModelFromJson(json);

  Map<String, dynamic> toJson() => _$DietMealModelToJson(this);

  // copyWith method
  DietMealModel copyWith({
    int? id,
    String? name,
    String? arabicName,
    bool? isSelected,
    String? imageURL,
    double? numOfGrams,
    double? numOfCalories,
    double? numOfProtein,
    double? numOfCarbs,
    double? numOfFats,
    int? foodCategory,
    String? note,
    String? image,
    String? usageInstructions,
  }) {
    return DietMealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicName: arabicName ?? this.arabicName,
      isSelected: isSelected ?? this.isSelected,
      imageURL: imageURL ?? this.imageURL,
      numOfGrams: numOfGrams ?? this.numOfGrams,
      numOfCalories: numOfCalories ?? this.numOfCalories,
      numOfProtein: numOfProtein ?? this.numOfProtein,
      numOfCarbs: numOfCarbs ?? this.numOfCarbs,
      numOfFats: numOfFats ?? this.numOfFats,
      foodCategory: foodCategory ?? this.foodCategory,
      note: note ?? this.note,
      image: image ?? this.image,
      usageInstructions: usageInstructions ?? this.usageInstructions,
    );
  }

  @override
  List<Object?> get props => [id, name, arabicName, imageURL, isSelected, numOfGrams];
}

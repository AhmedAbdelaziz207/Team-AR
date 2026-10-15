import 'meal_ingredient_model.dart';

class MealModel {
  final String id;
  final String dietPlanId;
  final String mealType;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final String? cookingVideoUrl;
  final List<MealIngredientModel> ingredients;
  final bool isConsumed;

  const MealModel({
    required this.id,
    required this.dietPlanId,
    required this.mealType,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    this.cookingVideoUrl,
    this.ingredients = const [],
    this.isConsumed = false,
  });

  factory MealModel.fromJson(
    Map<String, dynamic> json, {
    List<MealIngredientModel> ingredients = const [],
    bool isConsumed = false,
  }) {
    return MealModel(
      id: json['id'] as String,
      dietPlanId: json['diet_plan_id'] as String? ?? '',
      mealType: json['meal_type'] as String? ?? 'breakfast',
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (json['total_protein'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (json['total_carbs'] as num?)?.toDouble() ?? 0.0,
      totalFats: (json['total_fats'] as num?)?.toDouble() ?? 0.0,
      cookingVideoUrl: json['cooking_video_url'] as String?,
      ingredients: ingredients,
      isConsumed: isConsumed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diet_plan_id': dietPlanId,
      'meal_type': mealType,
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbs': totalCarbs,
      'total_fats': totalFats,
      if (cookingVideoUrl != null) 'cooking_video_url': cookingVideoUrl,
    };
  }

  MealModel copyWith({
    String? id,
    String? dietPlanId,
    String? mealType,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFats,
    String? cookingVideoUrl,
    List<MealIngredientModel>? ingredients,
    bool? isConsumed,
  }) {
    return MealModel(
      id: id ?? this.id,
      dietPlanId: dietPlanId ?? this.dietPlanId,
      mealType: mealType ?? this.mealType,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFats: totalFats ?? this.totalFats,
      cookingVideoUrl: cookingVideoUrl ?? this.cookingVideoUrl,
      ingredients: ingredients ?? this.ingredients,
      isConsumed: isConsumed ?? this.isConsumed,
    );
  }
}

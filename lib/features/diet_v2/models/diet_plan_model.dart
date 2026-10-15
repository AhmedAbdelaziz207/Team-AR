import 'meal_model.dart';

class DietPlanModel {
  final String id;
  final String traineeId;
  final String coachId;
  final String planType;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFats;
  final double waterTargetLiters;
  final String? coachInstructions;
  final DateTime createdAt;
  final List<MealModel> meals;

  const DietPlanModel({
    required this.id,
    required this.traineeId,
    required this.coachId,
    this.planType = 'Moderate Carb Day',
    this.targetCalories = 2000.0,
    this.targetProtein = 150.0,
    this.targetCarbs = 200.0,
    this.targetFats = 60.0,
    this.waterTargetLiters = 4.0,
    this.coachInstructions,
    required this.createdAt,
    this.meals = const [],
  });

  factory DietPlanModel.fromJson(Map<String, dynamic> json, {List<MealModel> meals = const []}) {
    return DietPlanModel(
      id: json['id'] as String,
      traineeId: json['trainee_id'] as String? ?? '',
      coachId: json['coach_id'] as String? ?? '',
      planType: json['plan_type'] as String? ?? 'Moderate Carb Day',
      targetCalories: (json['target_calories'] as num?)?.toDouble() ?? 2000.0,
      targetProtein: (json['target_protein'] as num?)?.toDouble() ?? 150.0,
      targetCarbs: (json['target_carbs'] as num?)?.toDouble() ?? 200.0,
      targetFats: (json['target_fats'] as num?)?.toDouble() ?? 60.0,
      waterTargetLiters: (json['water_target_liters'] as num?)?.toDouble() ?? 4.0,
      coachInstructions: json['coach_instructions'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      meals: meals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainee_id': traineeId,
      'coach_id': coachId,
      'plan_type': planType,
      'target_calories': targetCalories,
      'target_protein': targetProtein,
      'target_carbs': targetCarbs,
      'target_fats': targetFats,
      'water_target_liters': waterTargetLiters,
      if (coachInstructions != null) 'coach_instructions': coachInstructions,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DietPlanModel copyWith({
    String? id,
    String? traineeId,
    String? coachId,
    String? planType,
    double? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFats,
    double? waterTargetLiters,
    String? coachInstructions,
    DateTime? createdAt,
    List<MealModel>? meals,
  }) {
    return DietPlanModel(
      id: id ?? this.id,
      traineeId: traineeId ?? this.traineeId,
      coachId: coachId ?? this.coachId,
      planType: planType ?? this.planType,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFats: targetFats ?? this.targetFats,
      waterTargetLiters: waterTargetLiters ?? this.waterTargetLiters,
      coachInstructions: coachInstructions ?? this.coachInstructions,
      createdAt: createdAt ?? this.createdAt,
      meals: meals ?? this.meals,
    );
  }
}

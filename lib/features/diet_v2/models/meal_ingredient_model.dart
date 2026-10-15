class MealIngredientModel {
  final String id;
  final String mealId;
  final String name;
  final String quantityUnit;
  final double calories;
  final String? iconKey;

  const MealIngredientModel({
    required this.id,
    required this.mealId,
    required this.name,
    required this.quantityUnit,
    required this.calories,
    this.iconKey,
  });

  factory MealIngredientModel.fromJson(Map<String, dynamic> json) {
    return MealIngredientModel(
      id: json['id'] as String,
      mealId: json['meal_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantityUnit: json['quantity_unit'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      iconKey: json['icon_key'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_id': mealId,
      'name': name,
      'quantity_unit': quantityUnit,
      'calories': calories,
      if (iconKey != null) 'icon_key': iconKey,
    };
  }
}

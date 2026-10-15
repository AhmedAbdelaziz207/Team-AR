class MealLog {
  final String id;
  final String userId;
  final int mealId; // 1 to 6 (foodType)
  final String date; // YYYY-MM-DD
  final bool completed;
  final DateTime? completedAt;
  final DateTime? createdAt;

  const MealLog({
    required this.id,
    required this.userId,
    required this.mealId,
    required this.date,
    required this.completed,
    this.completedAt,
    this.createdAt,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      mealId: (json['meal_id'] as num?)?.toInt() ?? 0,
      date: json['date'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'meal_id': mealId,
        'date': date,
        'completed': completed,
        if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}

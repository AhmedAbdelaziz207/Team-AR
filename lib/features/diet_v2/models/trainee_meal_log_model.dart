class TraineeMealLogModel {
  final String? id;
  final String mealId;
  final String traineeId;
  final DateTime loggedAt;
  final bool isConsumed;

  const TraineeMealLogModel({
    this.id,
    required this.mealId,
    required this.traineeId,
    required this.loggedAt,
    this.isConsumed = true,
  });

  factory TraineeMealLogModel.fromJson(Map<String, dynamic> json) {
    return TraineeMealLogModel(
      id: json['id'] as String?,
      mealId: json['meal_id'] as String? ?? '',
      traineeId: json['trainee_id'] as String? ?? '',
      loggedAt: json['logged_at'] != null
          ? DateTime.tryParse(json['logged_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isConsumed: json['is_consumed'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'meal_id': mealId,
      'trainee_id': traineeId,
      'logged_at': loggedAt.toIso8601String(),
      'is_consumed': isConsumed,
    };
  }

  TraineeMealLogModel copyWith({
    String? id,
    String? mealId,
    String? traineeId,
    DateTime? loggedAt,
    bool? isConsumed,
  }) {
    return TraineeMealLogModel(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      traineeId: traineeId ?? this.traineeId,
      loggedAt: loggedAt ?? this.loggedAt,
      isConsumed: isConsumed ?? this.isConsumed,
    );
  }
}

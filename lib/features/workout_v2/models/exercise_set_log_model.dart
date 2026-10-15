class ExerciseSetLogModel {
  final String? id;
  final String? exerciseLogId;
  final int setNumber;
  final double weight;
  final String weightUnit;
  final int reps;
  final bool isCompleted;

  const ExerciseSetLogModel({
    this.id,
    this.exerciseLogId,
    required this.setNumber,
    required this.weight,
    this.weightUnit = 'kg',
    required this.reps,
    this.isCompleted = false,
  });

  factory ExerciseSetLogModel.fromJson(Map<String, dynamic> json) {
    return ExerciseSetLogModel(
      id: json['id'] as String?,
      exerciseLogId: json['exercise_log_id'] as String?,
      setNumber: json['set_number'] as int? ?? 1,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      weightUnit: json['weight_unit'] as String? ?? 'kg',
      reps: json['reps'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      if (exerciseLogId != null && exerciseLogId!.isNotEmpty)
        'exercise_log_id': exerciseLogId,
      'set_number': setNumber,
      'weight': weight,
      'weight_unit': weightUnit,
      'reps': reps,
      'is_completed': isCompleted,
    };
  }

  ExerciseSetLogModel copyWith({
    String? id,
    String? exerciseLogId,
    int? setNumber,
    double? weight,
    String? weightUnit,
    int? reps,
    bool? isCompleted,
  }) {
    return ExerciseSetLogModel(
      id: id ?? this.id,
      exerciseLogId: exerciseLogId ?? this.exerciseLogId,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

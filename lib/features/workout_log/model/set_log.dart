class SetLog {
  final String? id;
  final String? sessionId;
  final int exerciseId;
  final String? exerciseName;
  final int setNumber;
  final double weightKg;
  final int reps;
  final int? feeling; // 1=سهل 2=متوسط 3=صعب 4=أقصى
  final DateTime? createdAt;

  const SetLog({
    this.id,
    this.sessionId,
    required this.exerciseId,
    this.exerciseName,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.feeling,
    this.createdAt,
  });

  factory SetLog.fromJson(Map<String, dynamic> json) => SetLog(
        id: json['id'] as String?,
        sessionId: json['session_id'] as String?,
        exerciseId: json['exercise_id'] as int,
        exerciseName: json['exercise_name'] as String?,
        setNumber: json['set_number'] as int,
        weightKg: (json['weight_kg'] as num).toDouble(),
        reps: json['reps'] as int,
        feeling: json['feeling'] as int?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (sessionId != null) 'session_id': sessionId,
        'exercise_id': exerciseId,
        if (exerciseName != null) 'exercise_name': exerciseName,
        'set_number': setNumber,
        'weight_kg': weightKg,
        'reps': reps,
        if (feeling != null) 'feeling': feeling,
      };

  /// نسخة جديدة بدون id (لإرسالها للخادم)
  SetLog copyWithoutId() => SetLog(
        sessionId: sessionId,
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        setNumber: setNumber,
        weightKg: weightKg,
        reps: reps,
        feeling: feeling,
      );
}

import 'exercise_set_log_model.dart';

class ExerciseLogModel {
  final String? id;
  final String exerciseId;
  final String traineeId;
  final DateTime date;
  final String effortRating;
  final String? coachFeedbackNotes;
  final bool completed;
  final List<ExerciseSetLogModel> sets;

  const ExerciseLogModel({
    this.id,
    required this.exerciseId,
    required this.traineeId,
    required this.date,
    this.effortRating = 'moderate',
    this.coachFeedbackNotes,
    this.completed = false,
    this.sets = const [],
  });

  factory ExerciseLogModel.fromJson(Map<String, dynamic> json, {List<ExerciseSetLogModel> sets = const []}) {
    return ExerciseLogModel(
      id: json['id'] as String?,
      exerciseId: json['exercise_id'] as String? ?? '',
      traineeId: json['trainee_id'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      effortRating: json['effort_rating'] as String? ?? 'moderate',
      coachFeedbackNotes: json['coach_feedback_notes'] as String?,
      completed: json['completed'] as bool? ?? false,
      sets: sets,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'exercise_id': exerciseId,
      'trainee_id': traineeId,
      'date': date.toIso8601String(),
      'effort_rating': effortRating,
      if (coachFeedbackNotes != null) 'coach_feedback_notes': coachFeedbackNotes,
      'completed': completed,
    };
  }

  ExerciseLogModel copyWith({
    String? id,
    String? exerciseId,
    String? traineeId,
    DateTime? date,
    String? effortRating,
    String? coachFeedbackNotes,
    bool? completed,
    List<ExerciseSetLogModel>? sets,
  }) {
    return ExerciseLogModel(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      traineeId: traineeId ?? this.traineeId,
      date: date ?? this.date,
      effortRating: effortRating ?? this.effortRating,
      coachFeedbackNotes: coachFeedbackNotes ?? this.coachFeedbackNotes,
      completed: completed ?? this.completed,
      sets: sets ?? this.sets,
    );
  }
}

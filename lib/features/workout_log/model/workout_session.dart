import 'set_log.dart';

class WorkoutSession {
  final String? id;
  final String userId;
  final int? workoutDayId;
  final DateTime date;
  final String? notes;
  final List<SetLog> sets;
  final DateTime? createdAt;

  const WorkoutSession({
    this.id,
    required this.userId,
    this.workoutDayId,
    required this.date,
    this.notes,
    this.sets = const [],
    this.createdAt,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json,
      {List<SetLog>? sets}) =>
      WorkoutSession(
        id: json['id'] as String?,
        userId: json['user_id'] as String,
        workoutDayId: json['workout_day_id'] as int?,
        date: DateTime.parse(json['date'] as String),
        notes: json['notes'] as String?,
        sets: sets ?? [],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        if (workoutDayId != null) 'workout_day_id': workoutDayId,
        'date': date.toIso8601String().split('T').first,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}

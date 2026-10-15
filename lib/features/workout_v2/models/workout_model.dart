import 'exercise_model.dart';

class WorkoutModel {
  final String id;
  final String coachId;
  final String traineeId;
  final String title;
  final List<String> targetMuscles;
  final String? pdfAttachmentUrl;
  final String? introVideoUrl;
  final String? scheduledDate;
  final String? dayOfWeek;
  final DateTime createdAt;
  final List<ExerciseModel> exercises;

  const WorkoutModel({
    required this.id,
    required this.coachId,
    required this.traineeId,
    required this.title,
    this.targetMuscles = const [],
    this.pdfAttachmentUrl,
    this.introVideoUrl,
    this.scheduledDate,
    this.dayOfWeek,
    required this.createdAt,
    this.exercises = const [],
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json, {List<ExerciseModel> exercises = const []}) {
    List<String> muscles = [];
    if (json['target_muscles'] != null) {
      muscles = List<String>.from(json['target_muscles']);
    }

    return WorkoutModel(
      id: json['id'] as String,
      coachId: json['coach_id'] as String? ?? '',
      traineeId: json['trainee_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Push Day',
      targetMuscles: muscles,
      pdfAttachmentUrl: json['pdf_attachment_url'] as String?,
      introVideoUrl: json['intro_video_url'] as String?,
      scheduledDate: json['scheduled_date'] as String?,
      dayOfWeek: json['day_of_week'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      exercises: exercises,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'coach_id': coachId,
      'trainee_id': traineeId,
      'title': title,
      'target_muscles': targetMuscles,
      'pdf_attachment_url': pdfAttachmentUrl,
      'intro_video_url': introVideoUrl,
      'scheduled_date': scheduledDate,
      'day_of_week': dayOfWeek,
      'created_at': createdAt.toIso8601String(),
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  WorkoutModel copyWith({
    String? id,
    String? coachId,
    String? traineeId,
    String? title,
    List<String>? targetMuscles,
    String? pdfAttachmentUrl,
    String? introVideoUrl,
    String? scheduledDate,
    String? dayOfWeek,
    DateTime? createdAt,
    List<ExerciseModel>? exercises,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      traineeId: traineeId ?? this.traineeId,
      title: title ?? this.title,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      pdfAttachmentUrl: pdfAttachmentUrl ?? this.pdfAttachmentUrl,
      introVideoUrl: introVideoUrl ?? this.introVideoUrl,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      createdAt: createdAt ?? this.createdAt,
      exercises: exercises ?? this.exercises,
    );
  }
}

class SmartWorkoutResult {
  final bool isRecoveryMode;
  final WorkoutModel? activeWorkout; // التمرين الفعال أو تمرين الغد في حال الاستشفاء
  final Duration? remainingCooldown; // المدة المتبقية لانتهاء الاستشفاء
  final DateTime? lastWorkoutFinishedAt; // متى أنهى المتدرب آخر تمرين
  final int currentDayIndex; // ترتيب اليوم التدريبي (0: اليوم الأول، 1: الثاني...)
  final int totalDaysCount; // إجمالي أيام الجدول المسندة
  final List<WorkoutModel> allAssignedWorkouts; // كامل أيام الأسبوع للمدرب أو للاستعراض

  const SmartWorkoutResult({
    required this.isRecoveryMode,
    this.activeWorkout,
    this.remainingCooldown,
    this.lastWorkoutFinishedAt,
    this.currentDayIndex = 0,
    this.totalDaysCount = 0,
    this.allAssignedWorkouts = const [],
  });
}

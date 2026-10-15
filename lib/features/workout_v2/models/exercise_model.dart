class ExerciseModel {
  final String id;
  final String workoutId;
  final String name;
  final String? videoGuideUrl;
  final String? technicalTip;
  final int targetSets;
  final String targetRepsRange;
  final int restSeconds;
  final int rir;
  final String tempo;
  final int orderIndex;

  const ExerciseModel({
    required this.id,
    required this.workoutId,
    required this.name,
    this.videoGuideUrl,
    this.technicalTip,
    this.targetSets = 3,
    this.targetRepsRange = '8-10',
    this.restSeconds = 120,
    this.rir = 2,
    this.tempo = '3-2-2',
    this.orderIndex = 0,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      workoutId: json['workout_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      videoGuideUrl: json['video_guide_url'] as String?,
      technicalTip: json['technical_tip'] as String?,
      targetSets: json['target_sets'] as int? ?? 3,
      targetRepsRange: json['target_reps_range'] as String? ?? '8-10',
      restSeconds: json['rest_seconds'] as int? ?? 120,
      rir: json['rir'] as int? ?? 2,
      tempo: json['tempo'] as String? ?? '3-2-2',
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'workout_id': workoutId,
      'name': name,
      'video_guide_url': videoGuideUrl,
      'technical_tip': technicalTip,
      'target_sets': targetSets,
      'target_reps_range': targetRepsRange,
      'rest_seconds': restSeconds,
      'rir': rir,
      'tempo': tempo,
      'order_index': orderIndex,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  ExerciseModel copyWith({
    String? id,
    String? workoutId,
    String? name,
    String? videoGuideUrl,
    String? technicalTip,
    int? targetSets,
    String? targetRepsRange,
    int? restSeconds,
    int? rir,
    String? tempo,
    int? orderIndex,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      videoGuideUrl: videoGuideUrl ?? this.videoGuideUrl,
      technicalTip: technicalTip ?? this.technicalTip,
      targetSets: targetSets ?? this.targetSets,
      targetRepsRange: targetRepsRange ?? this.targetRepsRange,
      restSeconds: restSeconds ?? this.restSeconds,
      rir: rir ?? this.rir,
      tempo: tempo ?? this.tempo,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}

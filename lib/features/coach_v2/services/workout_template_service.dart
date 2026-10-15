import 'dart:convert';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';

class ExerciseTemplateItem {
  final String name;
  final String technicalTip;
  final int targetSets;
  final String targetRepsRange;
  final int restSeconds;
  final int rir;
  final String tempo;
  final String? videoUrl;

  const ExerciseTemplateItem({
    required this.name,
    required this.technicalTip,
    required this.targetSets,
    required this.targetRepsRange,
    required this.restSeconds,
    required this.rir,
    required this.tempo,
    this.videoUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'technicalTip': technicalTip,
        'targetSets': targetSets,
        'targetRepsRange': targetRepsRange,
        'restSeconds': restSeconds,
        'rir': rir,
        'tempo': tempo,
        if (videoUrl != null) 'videoUrl': videoUrl,
      };

  factory ExerciseTemplateItem.fromJson(Map<String, dynamic> json) =>
      ExerciseTemplateItem(
        name: json['name'] as String? ?? 'تمرين',
        technicalTip: json['technicalTip'] as String? ?? '',
        targetSets: json['targetSets'] as int? ?? 3,
        targetRepsRange: json['targetRepsRange'] as String? ?? '8-10',
        restSeconds: json['restSeconds'] as int? ?? 90,
        rir: json['rir'] as int? ?? 2,
        tempo: json['tempo'] as String? ?? '2-0-1-0',
        videoUrl: json['videoUrl'] as String?,
      );
}

class WorkoutTemplateModel {
  final String id;
  final String title;
  final List<String> targetMuscles;
  final String? introVideoUrl;
  final String? pdfAttachmentUrl;
  final List<ExerciseTemplateItem> exercises;
  final bool isCustom;

  const WorkoutTemplateModel({
    required this.id,
    required this.title,
    required this.targetMuscles,
    this.introVideoUrl,
    this.pdfAttachmentUrl,
    required this.exercises,
    this.isCustom = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetMuscles': targetMuscles,
        if (introVideoUrl != null) 'introVideoUrl': introVideoUrl,
        if (pdfAttachmentUrl != null) 'pdfAttachmentUrl': pdfAttachmentUrl,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'isCustom': isCustom,
      };

  factory WorkoutTemplateModel.fromJson(Map<String, dynamic> json) =>
      WorkoutTemplateModel(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'جدول تدريبي',
        targetMuscles: json['targetMuscles'] != null
            ? List<String>.from(json['targetMuscles'] as List)
            : const [],
        introVideoUrl: json['introVideoUrl'] as String?,
        pdfAttachmentUrl: json['pdfAttachmentUrl'] as String?,
        exercises: json['exercises'] != null
            ? (json['exercises'] as List)
                .map((e) =>
                    ExerciseTemplateItem.fromJson(e as Map<String, dynamic>))
                .toList()
            : const [],
        isCustom: json['isCustom'] as bool? ?? true,
      );
}

class WorkoutTemplateService {
  static const String _prefTemplatesKey = 'coach_custom_workout_templates_v2';

  /// جلب كافة القوالب (المخصصة التي أنشأها المدرب)
  static Future<List<WorkoutTemplateModel>> getAllTemplates() async {
    return getCustomTemplatesOnly();
  }

  /// حفظ أو تحديث قالب للمدرب في مكتبته الخاصة
  static Future<void> saveCustomTemplate(WorkoutTemplateModel template) async {
    final customList = await getCustomTemplatesOnly();
    // إذا كان نفس القالب موجود بالمعرّف نحدثه، وإلا نضيفه
    final existingIndex = customList.indexWhere((t) => t.id == template.id);
    if (existingIndex != -1) {
      customList[existingIndex] = template;
    } else {
      customList.insert(0, template);
    }

    final encoded = jsonEncode(customList.map((t) => t.toJson()).toList());
    await SharedPreferencesHelper.setData(_prefTemplatesKey, encoded);
  }

  /// حذف قالب من مكتبة المدرب
  static Future<void> deleteCustomTemplate(String templateId) async {
    final customList = await getCustomTemplatesOnly();
    customList.removeWhere((t) => t.id == templateId);

    final encoded = jsonEncode(customList.map((t) => t.toJson()).toList());
    await SharedPreferencesHelper.setData(_prefTemplatesKey, encoded);
  }

  /// جلب القوالب الخاصة بالمدرب
  static Future<List<WorkoutTemplateModel>> getCustomTemplatesOnly() async {
    final List<WorkoutTemplateModel> list = [];
    try {
      final jsonStr =
          await SharedPreferencesHelper.getString(_prefTemplatesKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr) as List;
        for (final item in decoded) {
          list.add(
              WorkoutTemplateModel.fromJson(item as Map<String, dynamic>));
        }
      }
    } catch (_) {}
    return list;
  }

}


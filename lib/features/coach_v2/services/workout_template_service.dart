import 'dart:convert';
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  static const String _prefTemplatesLastUpdatedKey =
      'coach_templates_last_updated_v2';
  static const String _prefHiddenTemplatesKey = 'coach_hidden_templates_v2';
  static const Duration _cacheTtl = Duration(minutes: 5);

  /// القوالب القياسية الافتراضية المعتمدة (تظهر دائماً لضمان عدم فراغ المكتبة)
  static final List<WorkoutTemplateModel> _defaultTemplates = [
    const WorkoutTemplateModel(
      id: 'default_push_day',
      title: 'جدول الدفع (Push Day - الصدر والكتف والترايسبس)',
      targetMuscles: ['الصدر', 'الكتف الأمامي والجانبي', 'الترايسبس'],
      isCustom: false,
      exercises: [
        ExerciseTemplateItem(
          name: 'دمبل تجميع عالي (Incline Dumbbell Press)',
          technicalTip:
              'زاوية البنش 30 درجة، النزول بتحكم كامل والصعود بانقباض عضلي',
          targetSets: 3,
          targetRepsRange: '8-10',
          restSeconds: 90,
          rir: 2,
          tempo: '3-1-1',
        ),
        ExerciseTemplateItem(
          name: 'بار فلات (Flat Barbell Bench Press)',
          technicalTip:
              'القبضة أوسع قليلاً من عرض الكتفين، لمس أسفل الصدر بتحكم',
          targetSets: 3,
          targetRepsRange: '8-10',
          restSeconds: 120,
          rir: 2,
          tempo: '3-1-1',
        ),
        ExerciseTemplateItem(
          name: 'متوازي (Chest Dips)',
          technicalTip: 'الميل للأمام قليلاً للتركيز على عضلات الصدر السفلية',
          targetSets: 3,
          targetRepsRange: '10-12',
          restSeconds: 90,
          rir: 2,
          tempo: '2-1-1',
        ),
        ExerciseTemplateItem(
          name: 'رفرفة كتف جانبي بالدمبل (Lateral Raises)',
          technicalTip:
              'رفع الذراعين بمستوى الكتف دون تأرجح، ثبات ثانية في القمة',
          targetSets: 4,
          targetRepsRange: '12-15',
          restSeconds: 60,
          rir: 1,
          tempo: '2-0-1',
        ),
        ExerciseTemplateItem(
          name: 'ترايسبس حبل (Triceps Rope Pushdown)',
          technicalTip:
              'تثبيت الكوعين بجانب الجسم وفتح الحبل عند النزول لأقصى انقباض',
          targetSets: 3,
          targetRepsRange: '12-15',
          restSeconds: 60,
          rir: 2,
          tempo: '2-0-1',
        ),
      ],
    ),
    const WorkoutTemplateModel(
      id: 'default_pull_day',
      title: 'جدول السحب (Pull Day - الظهر والبايسبس)',
      targetMuscles: ['عضلات الظهر', 'الكتف الخلفي', 'البايسبس'],
      isCustom: false,
      exercises: [
        ExerciseTemplateItem(
          name: 'سحب ظهر عالي واسع (Lat Pulldown)',
          technicalTip:
              'النزول لأعلى الصدر مع عصر عضلات الظهر، تجنب التأرجح بالظهر',
          targetSets: 3,
          targetRepsRange: '8-10',
          restSeconds: 90,
          rir: 2,
          tempo: '3-1-1',
        ),
        ExerciseTemplateItem(
          name: 'سحب أرضي ضيق (Seated Cable Row)',
          technicalTip:
              'الاستقامة مع سحب المقبض لأسفل البطن وإرجاع الأكتاف للخلف',
          targetSets: 3,
          targetRepsRange: '10-12',
          restSeconds: 90,
          rir: 2,
          tempo: '2-1-1',
        ),
        ExerciseTemplateItem(
          name: 'فيس بول للأكتاف الخلفية (Face Pulls)',
          technicalTip:
              'سحب الحبل باتجاه العينين مع تدوير اليدين للخارج لتفعيل الكتف الخلفي',
          targetSets: 3,
          targetRepsRange: '12-15',
          restSeconds: 60,
          rir: 2,
          tempo: '2-0-1',
        ),
        ExerciseTemplateItem(
          name: 'بايسبس بالبار (Barbell Biceps Curl)',
          technicalTip:
              'تثبيت الكوعين بجانب الجذع ورفع البار بتحكم كامل دون استغلال قوة الظهر',
          targetSets: 3,
          targetRepsRange: '10-12',
          restSeconds: 75,
          rir: 2,
          tempo: '2-1-1',
        ),
        ExerciseTemplateItem(
          name: 'هامر بالدمبل (Dumbbell Hammer Curls)',
          technicalTip: 'قبضة رأسية محايدة لتشغيل العضلة العضدية وعضلات الساعد',
          targetSets: 3,
          targetRepsRange: '10-12',
          restSeconds: 60,
          rir: 2,
          tempo: '2-0-1',
        ),
      ],
    ),
    const WorkoutTemplateModel(
      id: 'default_legs_day',
      title: 'جدول الأرجل (Legs Day - الأرجل والسمانة)',
      targetMuscles: ['الأرجل الأمامية والخلفية', 'السمانة'],
      isCustom: false,
      exercises: [
        ExerciseTemplateItem(
          name: 'باربل سكوات (Barbell Squat)',
          technicalTip:
              'النزول لعمق موازٍ للأرض مع الحفاظ على استقامة الظهر ووزن الجسم على الكعبين',
          targetSets: 4,
          targetRepsRange: '8-10',
          restSeconds: 120,
          rir: 2,
          tempo: '3-1-1',
        ),
        ExerciseTemplateItem(
          name: 'دفع أرجل على الجهاز (Leg Press)',
          technicalTip:
              'النزول بزاوية 90 درجة وعدم قفل الركبتين عند الصعود للحفاظ على المفاصل',
          targetSets: 3,
          targetRepsRange: '10-12',
          restSeconds: 90,
          rir: 2,
          tempo: '3-0-1',
        ),
        ExerciseTemplateItem(
          name: 'مرجحة أرجل خلفية (Lying Leg Curls)',
          technicalTip:
              'التركيز على انقباض الهامسترينج في القمة والنزول ببطء شديد',
          targetSets: 3,
          targetRepsRange: '12-15',
          restSeconds: 75,
          rir: 2,
          tempo: '3-1-1',
        ),
        ExerciseTemplateItem(
          name: 'طعن بالدمبل (Dumbbell Walking Lunges)',
          technicalTip:
              'خطوات واسعة مع نزول الركبة الخلفية قرب الأرض وثبات الجذع مستقيماً',
          targetSets: 3,
          targetRepsRange: '10-12 لكل رجل',
          restSeconds: 90,
          rir: 2,
          tempo: '2-0-1',
        ),
        ExerciseTemplateItem(
          name: 'سمانة واقف (Standing Calf Raise)',
          technicalTip:
              'إطالة كاملة للسمانة في الأسفل وثبات ثانيتين في أعلى نقطة',
          targetSets: 4,
          targetRepsRange: '15-20',
          restSeconds: 60,
          rir: 1,
          tempo: '2-2-1',
        ),
      ],
    ),
  ];

  /// جلب كافة القوالب بذكاء (Stale-While-Revalidate مع TTL وإمكانية التحديث القسري)
  static Future<List<WorkoutTemplateModel>> getAllTemplates(
      {bool forceRefresh = false}) async {
    // 1. فحص هل الكاش المحلي منتهي الصلاحية أو تم طلب التحديث القسري
    final lastUpdatedStr =
        await SharedPreferencesHelper.getString(_prefTemplatesLastUpdatedKey);
    DateTime? lastUpdated;
    if (lastUpdatedStr != null && lastUpdatedStr.isNotEmpty) {
      lastUpdated = DateTime.tryParse(lastUpdatedStr);
    }

    final bool isExpired = lastUpdated == null ||
        DateTime.now().difference(lastUpdated) > _cacheTtl;
    final bool shouldFetchCloud = forceRefresh || isExpired;

    List<WorkoutTemplateModel> customTemplates = await getCustomTemplatesOnly();

    // 2. إذا حان وقت المزامنة السحابية
    if (shouldFetchCloud || customTemplates.isEmpty) {
      try {
        final cloudTemplates = await _fetchCloudTemplates();
        if (cloudTemplates.isNotEmpty || forceRefresh) {
          // دمج السحابة كمرجع رئيسي: كل قالب سحابي يحدّث أو يضاف للقائمة المحلية
          final Map<String, WorkoutTemplateModel> mergedMap = {};

          // نبدأ بالقوالب السحابية لأنها الأحدث
          for (final ct in cloudTemplates) {
            mergedMap[ct.id] = ct;
          }

          // نضيف أي قوالب مخصصة محلية أنشأها المدرب ولم تتزامن بعد
          for (final local in customTemplates) {
            if (!mergedMap.containsKey(local.id) &&
                !mergedMap.values.any((m) =>
                    m.title.trim().toLowerCase() ==
                    local.title.trim().toLowerCase())) {
              mergedMap[local.id] = local;
            }
          }

          customTemplates = mergedMap.values.toList();
          // حفظ القائمة المدمجة فوراً في الذاكرة المحلية
          final encoded =
              jsonEncode(customTemplates.map((t) => t.toJson()).toList());
          await SharedPreferencesHelper.setData(_prefTemplatesKey, encoded);
          await SharedPreferencesHelper.setData(
              _prefTemplatesLastUpdatedKey, DateTime.now().toIso8601String());
          log('✅ [WorkoutTemplateService] تم تحديث كاش مكتبة القوالب بنجاح من السيرفر (${customTemplates.length} قالب)');
        }
      } catch (e) {
        log('⚠️ [WorkoutTemplateService] Cloud template fetch fallback (استخدام الكاش المحلي): $e');
      }
    }

    final List<WorkoutTemplateModel> result = List.from(customTemplates);

    // 3. جلب قائمة المعرفات المحذوفة من قبل المدرب
    final hiddenIds = await _getHiddenTemplateIds();

    // 4. دمج القوالب الافتراضية إذا لم تكن محذوفة ولم تكن مكررة
    for (final def in _defaultTemplates) {
      if (!hiddenIds.contains(def.id) &&
          !result.any((t) =>
              t.id == def.id ||
              t.title.trim().toLowerCase() == def.title.trim().toLowerCase())) {
        result.add(def);
      }
    }

    return result.where((t) => !hiddenIds.contains(t.id)).toList();
  }

  /// إبطال كاش القوالب فورياً لإجبار الطلب القادم على الجلب من السيرفر
  static Future<void> invalidateCache() async {
    await SharedPreferencesHelper.remove(_prefTemplatesLastUpdatedKey);
  }

  /// حفظ أو تحديث قالب للمدرب في مكتبته الخاصة مع إبطال الكاش فورياً ومزامنة المعرّف
  static Future<void> saveCustomTemplate(WorkoutTemplateModel template) async {
    String finalId = template.id;

    // محاولة حفظه سحابياً في Supabase أولاً للحصول على الـ UUID الحقيقي
    try {
      final cloudId = await _syncTemplateToCloud(template);
      if (cloudId != null && cloudId.isNotEmpty) {
        finalId = cloudId;
      }
    } catch (e) {
      log('⚠️ [WorkoutTemplateService] Cloud template sync error: $e');
    }

    final savedTemplate = WorkoutTemplateModel(
      id: finalId,
      title: template.title,
      targetMuscles: template.targetMuscles,
      introVideoUrl: template.introVideoUrl,
      pdfAttachmentUrl: template.pdfAttachmentUrl,
      exercises: template.exercises,
      isCustom: true,
    );

    final customList = await getCustomTemplatesOnly();
    final existingIndex = customList.indexWhere((t) =>
        t.id == finalId ||
        t.title.trim().toLowerCase() == template.title.trim().toLowerCase());
    if (existingIndex != -1) {
      customList[existingIndex] = savedTemplate;
    } else {
      customList.insert(0, savedTemplate);
    }

    final encoded = jsonEncode(customList.map((t) => t.toJson()).toList());
    await SharedPreferencesHelper.setData(_prefTemplatesKey, encoded);
    await SharedPreferencesHelper.setData(
        _prefTemplatesLastUpdatedKey, DateTime.now().toIso8601String());

    // إلغاء كونه محذوفاً في حال كان معرّفاً مكرراً
    await _unhideTemplateId(finalId);
  }

  /// حذف قالب من مكتبة المدرب وإبطال الكاش فورياً
  static Future<void> deleteCustomTemplate(String templateId) async {
    final customList = await getCustomTemplatesOnly();
    customList.removeWhere((t) => t.id == templateId);

    final encoded = jsonEncode(customList.map((t) => t.toJson()).toList());
    await SharedPreferencesHelper.setData(_prefTemplatesKey, encoded);
    await SharedPreferencesHelper.setData(
        _prefTemplatesLastUpdatedKey, DateTime.now().toIso8601String());

    // حفظ المعرّف كمحذوف حتى لا يعود إذا كان قالباً افتراضياً
    await _hideTemplateId(templateId);

    // محاولة الحذف من Supabase
    try {
      final client = Supabase.instance.client;
      await client.from('exercises').delete().eq('workout_id', templateId);
      await client.from('workouts').delete().eq('id', templateId);
    } catch (_) {}
  }

  /// جلب القوالب الخاصة بالمدرب المخزنة محلياً
  static Future<List<WorkoutTemplateModel>> getCustomTemplatesOnly() async {
    final List<WorkoutTemplateModel> list = [];
    try {
      final jsonStr =
          await SharedPreferencesHelper.getString(_prefTemplatesKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr) as List;
        for (final item in decoded) {
          list.add(WorkoutTemplateModel.fromJson(item as Map<String, dynamic>));
        }
      }
    } catch (_) {}
    return list;
  }

  // ─── إدارة القوالب المحذوفة ───

  static Future<Set<String>> _getHiddenTemplateIds() async {
    try {
      final jsonStr =
          await SharedPreferencesHelper.getString(_prefHiddenTemplatesKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr) as List;
        return decoded.map((e) => e.toString()).toSet();
      }
    } catch (_) {}
    return {};
  }

  static Future<void> _hideTemplateId(String id) async {
    final hidden = await _getHiddenTemplateIds();
    hidden.add(id);
    await SharedPreferencesHelper.setData(
        _prefHiddenTemplatesKey, jsonEncode(hidden.toList()));
  }

  static Future<void> _unhideTemplateId(String id) async {
    final hidden = await _getHiddenTemplateIds();
    if (hidden.remove(id)) {
      await SharedPreferencesHelper.setData(
          _prefHiddenTemplatesKey, jsonEncode(hidden.toList()));
    }
  }

  // ─── المزامنة السحابية مع Supabase ───

  static Future<List<WorkoutTemplateModel>> _fetchCloudTemplates() async {
    final client = Supabase.instance.client;
    final workoutsRes = await client
        .from('workouts')
        .select()
        .eq('trainee_id', 'coach_template')
        .order('created_at', ascending: false);

    final List<WorkoutTemplateModel> list = [];
    for (final w in (workoutsRes as List)) {
      final workoutId = w['id'] as String;
      final exercisesRes = await client
          .from('exercises')
          .select()
          .eq('workout_id', workoutId)
          .order('order_index', ascending: true);

      final exercises = (exercisesRes as List)
          .map((e) => ExerciseTemplateItem(
                name: e['name'] as String? ?? 'تمرين',
                technicalTip: e['technical_tip'] as String? ?? '',
                targetSets: e['target_sets'] as int? ?? 3,
                targetRepsRange: e['target_reps_range'] as String? ?? '8-10',
                restSeconds: e['rest_seconds'] as int? ?? 90,
                rir: e['rir'] as int? ?? 2,
                tempo: e['tempo'] as String? ?? '2-0-1-0',
                videoUrl: e['video_guide_url'] as String?,
              ))
          .toList();

      list.add(WorkoutTemplateModel(
        id: workoutId,
        title: w['title'] as String? ?? 'جدول تدريبي',
        targetMuscles: w['target_muscles'] != null
            ? List<String>.from(w['target_muscles'] as List)
            : const [],
        introVideoUrl:
            w['introVideoUrl'] as String? ?? w['intro_video_url'] as String?,
        pdfAttachmentUrl: w['pdfAttachmentUrl'] as String? ??
            w['pdf_attachment_url'] as String?,
        exercises: exercises,
        isCustom: true,
      ));
    }
    return list;
  }

  static Future<String?> _syncTemplateToCloud(WorkoutTemplateModel tmpl) async {
    final client = Supabase.instance.client;
    final workoutPayload = {
      'coach_id': 'admin_template',
      'trainee_id': 'coach_template',
      'title': tmpl.title,
      'target_muscles': tmpl.targetMuscles,
      if (tmpl.introVideoUrl != null) 'intro_video_url': tmpl.introVideoUrl,
      if (tmpl.pdfAttachmentUrl != null)
        'pdf_attachment_url': tmpl.pdfAttachmentUrl,
    };

    // upsert workout
    String workoutId = tmpl.id;
    final isUuid = RegExp(
            r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
        .hasMatch(workoutId);

    if (isUuid) {
      await client.from('workouts').upsert({
        'id': workoutId,
        ...workoutPayload,
      });
      // clean old exercises for this template
      await client.from('exercises').delete().eq('workout_id', workoutId);
    } else {
      final inserted = await client
          .from('workouts')
          .insert(workoutPayload)
          .select('id')
          .single();
      workoutId = inserted['id'] as String;
    }

    // insert exercises
    for (int i = 0; i < tmpl.exercises.length; i++) {
      final ex = tmpl.exercises[i];
      await client.from('exercises').insert({
        'workout_id': workoutId,
        'name': ex.name,
        'video_guide_url': ex.videoUrl,
        'technical_tip': ex.technicalTip,
        'target_sets': ex.targetSets,
        'target_reps_range': ex.targetRepsRange,
        'rest_seconds': ex.restSeconds,
        'rir': ex.rir,
        'tempo': ex.tempo,
        'order_index': i,
      });
    }
    return workoutId;
  }
}

import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise_log_model.dart';
import '../models/exercise_model.dart';
import '../models/exercise_set_log_model.dart';
import '../models/workout_model.dart';

class WorkoutRepositoryV2 {
  final SupabaseClient? _supabase;

  WorkoutRepositoryV2([SupabaseClient? client]) : _supabase = client;

  SupabaseClient get _client => _supabase ?? Supabase.instance.client;

  /// جلب التمرين المخصص للمتدرب مع تمارينه المرتبة
  Future<WorkoutModel?> getWorkoutForTrainee(String traineeId) async {
    try {
      // 1. جلب أحدث تمرين مخصص للمتدرب
      final workoutRes = await _client
          .from('workouts')
          .select()
          .eq('trainee_id', traineeId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (workoutRes == null) return null;

      final workoutId = workoutRes['id'] as String;

      // 2. جلب التمارين التابعة لهذا اليوم
      final exercisesRes = await _client
          .from('exercises')
          .select()
          .eq('workout_id', workoutId)
          .order('order_index', ascending: true);

      final exercises = (exercisesRes as List)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return WorkoutModel.fromJson(workoutRes, exercises: exercises);
    } catch (e) {
      log('Error getting workout for trainee: $e');
      return null;
    }
  }

  /// جلب كافة خطط وأيام التمارين المسندة للمتدرب (البرنامج الأسبوعي)
  Future<List<WorkoutModel>> getAllWorkoutsForTrainee(String traineeId) async {
    try {
      final workoutsRes = await _client
          .from('workouts')
          .select()
          .eq('trainee_id', traineeId)
          .order('created_at', ascending: true);

      final List<WorkoutModel> list = [];
      for (final wJson in (workoutsRes as List)) {
        final workoutId = wJson['id'] as String;
        final exercisesRes = await _client
            .from('exercises')
            .select()
            .eq('workout_id', workoutId)
            .order('order_index', ascending: true);

        final exercises = (exercisesRes as List)
            .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
            .toList();

        list.add(WorkoutModel.fromJson(wJson, exercises: exercises));
      }
      return list;
    } catch (e) {
      log('Error getting all workouts for trainee: $e');
      return [];
    }
  }

  /// حذف خطة تمرين للمتدرب
  Future<bool> deleteWorkout(String workoutId) async {
    try {
      await _client.from('exercises').delete().eq('workout_id', workoutId);
      await _client.from('workouts').delete().eq('id', workoutId);
      log('✅ [WorkoutRepositoryV2] Workout deleted: $workoutId');
      return true;
    } catch (e) {
      log('❌ [WorkoutRepositoryV2] Error deleting workout: $e');
      return false;
    }
  }

  /// إزالة وإلغاء ملف الـ PDF المرفق للمتدرب
  Future<bool> clearPdfAttachmentForTrainee(String traineeId) async {
    try {
      await _client
          .from('workouts')
          .update({'pdf_attachment_url': null})
          .eq('trainee_id', traineeId);
      log('✅ [WorkoutRepositoryV2] Cleared PDF attachment for trainee: $traineeId');
      return true;
    } catch (e) {
      log('❌ [WorkoutRepositoryV2] Error clearing PDF for trainee: $e');
      return false;
    }
  }

  /// تعيين أو تحديث ملف الـ PDF المرفق للمتدرب
  Future<bool> updatePdfAttachmentForTrainee(
      String traineeId, String pdfUrl) async {
    try {
      await _client
          .from('workouts')
          .update({'pdf_attachment_url': pdfUrl})
          .eq('trainee_id', traineeId);
      log('✅ [WorkoutRepositoryV2] Updated PDF attachment for trainee: $traineeId');
      return true;
    } catch (e) {
      log('❌ [WorkoutRepositoryV2] Error updating PDF for trainee: $e');
      return false;
    }
  }

  /// جلب آخر سجل تمرين أنجزه المتدرب
  Future<ExerciseLogModel?> getLastCompletedLog(String traineeId) async {
    try {
      final res = await _client
          .from('exercise_logs')
          .select()
          .eq('trainee_id', traineeId)
          .eq('completed', true)
          .order('date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (res == null) return null;
      return ExerciseLogModel.fromJson(res);
    } catch (e) {
      log('Error getting last completed log: $e');
      return null;
    }
  }

  /// النظام الذكي لجلب التمرين الفعال أو تفعيل وضع الاستشفاء (Recovery Window)
  Future<SmartWorkoutResult> getSmartActiveWorkout(
    String traineeId, {
    int recoveryHours = 20,
  }) async {
    try {
      final allWorkouts = await getAllWorkoutsForTrainee(traineeId);
      if (allWorkouts.isEmpty) {
        return const SmartWorkoutResult(isRecoveryMode: false);
      }

      final lastLog = await getLastCompletedLog(traineeId);
      if (lastLog == null) {
        // المتدرب لم يسجل أي تمرين بعد -> يرى اليوم الأول مباشرة
        return SmartWorkoutResult(
          isRecoveryMode: false,
          activeWorkout: allWorkouts.first,
          currentDayIndex: 0,
          totalDaysCount: allWorkouts.length,
          allAssignedWorkouts: allWorkouts,
        );
      }

      // تحديد أي تمرين تم إنجازه أخيراً
      int lastWorkoutIndex = allWorkouts.indexWhere(
        (w) => w.exercises.any((ex) => ex.id == lastLog.exerciseId),
      );
      if (lastWorkoutIndex == -1) {
        lastWorkoutIndex = 0;
      }

      final now = DateTime.now();
      final difference = now.difference(lastLog.date);
      final totalCooldownMinutes = recoveryHours * 60;
      final nextWorkoutIndex = (lastWorkoutIndex + 1) % allWorkouts.length;
      final nextWorkout = allWorkouts[nextWorkoutIndex];

      // إذا مر وقت أقل من الـ 20 ساعة منذ آخر تمرين، ندخل في وضع الاستشفاء
      if (difference.inMinutes < totalCooldownMinutes) {
        final remainingMinutes = totalCooldownMinutes - difference.inMinutes;
        return SmartWorkoutResult(
          isRecoveryMode: true,
          activeWorkout: nextWorkout,
          remainingCooldown: Duration(minutes: remainingMinutes),
          lastWorkoutFinishedAt: lastLog.date,
          currentDayIndex: nextWorkoutIndex,
          totalDaysCount: allWorkouts.length,
          allAssignedWorkouts: allWorkouts,
        );
      }

      // مرت الـ 20 ساعة بنجاح! يتم فتح تمرين اليوم التالي في السلسلة
      return SmartWorkoutResult(
        isRecoveryMode: false,
        activeWorkout: nextWorkout,
        currentDayIndex: nextWorkoutIndex,
        totalDaysCount: allWorkouts.length,
        allAssignedWorkouts: allWorkouts,
      );
    } catch (e) {
      log('Error evaluating smart active workout: $e');
      return const SmartWorkoutResult(isRecoveryMode: false);
    }
  }

  /// جلب تمرين محدد عبر الـ ID
  Future<WorkoutModel?> getWorkoutById(String workoutId) async {
    try {
      final workoutRes = await _client
          .from('workouts')
          .select()
          .eq('id', workoutId)
          .maybeSingle();

      if (workoutRes == null) return null;

      final exercisesRes = await _client
          .from('exercises')
          .select()
          .eq('workout_id', workoutId)
          .order('order_index', ascending: true);

      final exercises = (exercisesRes as List)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return WorkoutModel.fromJson(workoutRes, exercises: exercises);
    } catch (e) {
      log('Error getting workout by id: $e');
      return null;
    }
  }

  /// جلب الأداء السابق لآخر جلسة قام بها المتدرب لهذا التمرين بالذات
  Future<ExerciseLogModel?> getPreviousExerciseLog(
      String exerciseId, String traineeId) async {
    try {
      final logRes = await _client
          .from('exercise_logs')
          .select()
          .eq('exercise_id', exerciseId)
          .eq('trainee_id', traineeId)
          .order('date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (logRes == null) return null;

      final logId = logRes['id'] as String;

      // جلب المجموعات السابقة
      final setsRes = await _client
          .from('exercise_set_logs')
          .select()
          .eq('exercise_log_id', logId)
          .order('set_number', ascending: true);

      final sets = (setsRes as List)
          .map((s) => ExerciseSetLogModel.fromJson(s as Map<String, dynamic>))
          .toList();

      return ExerciseLogModel.fromJson(logRes, sets: sets);
    } catch (e) {
      log('Error getting previous exercise log: $e');
      return null;
    }
  }

  /// حفظ سجل تمرين فردي مع مجموعاته
  Future<bool> saveExerciseLog({
    required ExerciseLogModel exerciseLog,
    required List<ExerciseSetLogModel> sets,
  }) async {
    try {
      // 1. إدخال أو تحديث سجل التمرين
      final logInsert = await _client
          .from('exercise_logs')
          .insert(exerciseLog.toJson())
          .select()
          .single();

      final logId = logInsert['id'] as String;

      // 2. إدخال تفاصيل المجموعات
      if (sets.isNotEmpty) {
        final setsData = sets.map((s) {
          final json = s.toJson();
          json['exercise_log_id'] = logId;
          return json;
        }).toList();

        await _client.from('exercise_set_logs').insert(setsData);
      }

      return true;
    } catch (e) {
      log('Error saving exercise log: $e');
      return false;
    }
  }

  /// إنشاء يوم تمرين جديد من المدرب
  Future<String?> createWorkout(WorkoutModel workout) async {
    final payload = workout.toJson();
    log('--------------------------------------------------');
    log('🏋️‍♂️ [WorkoutRepositoryV2] createWorkout INITIATED');
    log('📦 [WorkoutRepositoryV2] Table: workouts');
    log('📋 [WorkoutRepositoryV2] Full Payload: $payload');
    log('--------------------------------------------------');

    try {
      final res = await _client
          .from('workouts')
          .insert(payload)
          .select('id')
          .single();

      final createdId = res['id'] as String?;
      log('✅ [WorkoutRepositoryV2] Workout Created Successfully! id: $createdId');
      return createdId;
    } on PostgrestException catch (e, stack) {
      log('❌ [WorkoutRepositoryV2] PostgrestException creating workout:');
      log('   • Code: ${e.code}');
      log('   • Message: ${e.message}');
      log('   • Details: ${e.details}');
      log('   • Hint: ${e.hint}');
      log('   • Payload sent: $payload');
      log('   • StackTrace: $stack');
      return null;
    } catch (e, stack) {
      log('❌ [WorkoutRepositoryV2] Unexpected Error creating workout: $e');
      log('   • Payload sent: $payload');
      log('   • StackTrace: $stack');
      return null;
    }
  }

  /// إضافة تمرين إلى جدول معين
  Future<bool> addExercise(ExerciseModel exercise) async {
    final payload = exercise.toJson();
    log('➡️ [WorkoutRepositoryV2] addExercise: "${exercise.name}" (workout_id: ${exercise.workoutId})');
    log('📋 [WorkoutRepositoryV2] Exercise Payload: $payload');

    try {
      await _client.from('exercises').insert(payload);
      log('✅ [WorkoutRepositoryV2] Exercise "${exercise.name}" inserted successfully.');
      return true;
    } on PostgrestException catch (e, stack) {
      log('❌ [WorkoutRepositoryV2] PostgrestException adding exercise "${exercise.name}":');
      log('   • Code: ${e.code}');
      log('   • Message: ${e.message}');
      log('   • Details: ${e.details}');
      log('   • Hint: ${e.hint}');
      log('   • Payload sent: $payload');
      log('   • StackTrace: $stack');
      return false;
    } catch (e, stack) {
      log('❌ [WorkoutRepositoryV2] Error adding exercise: $e');
      log('   • Payload sent: $payload');
      log('   • StackTrace: $stack');
      return false;
    }
  }

  /// جلب سجلات جميع التمارين لمتدرب معين (للمدرب)
  Future<List<ExerciseLogModel>> getTraineeHistory(String traineeId) async {
    try {
      final logsRes = await _client
          .from('exercise_logs')
          .select()
          .eq('trainee_id', traineeId)
          .order('date', ascending: false);

      final List<ExerciseLogModel> list = [];
      for (final item in logsRes as List) {
        final logId = item['id'] as String;
        final setsRes = await _client
            .from('exercise_set_logs')
            .select()
            .eq('exercise_log_id', logId)
            .order('set_number', ascending: true);

        final sets = (setsRes as List)
            .map((s) => ExerciseSetLogModel.fromJson(s as Map<String, dynamic>))
            .toList();

        list.add(ExerciseLogModel.fromJson(item as Map<String, dynamic>, sets: sets));
      }
      return list;
    } catch (e) {
      log('Error getting trainee history: $e');
      return [];
    }
  }
}

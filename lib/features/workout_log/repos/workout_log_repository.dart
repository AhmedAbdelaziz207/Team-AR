import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:team_ar/features/workout_log/model/set_log.dart';
import 'package:team_ar/features/workout_log/model/workout_session.dart';

/// مفتاح التخزين المحلي للطوابير غير المرفوعة
const String _kPendingLogsKey = 'pending_workout_logs';

class WorkoutLogRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─── حفظ جلسة جديدة ─────────────────────────────────────────
  Future<String?> saveSession({
    required String userId,
    required int exerciseId,
    required String exerciseName,
    required List<SetLog> sets,
    String? notes,
  }) async {
    try {
      // 1. أنشئ الـ session
      final sessionData = {
        'user_id': userId,
        'date': DateTime.now().toIso8601String().split('T').first,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final sessionRes = await _supabase
          .from('workout_sessions')
          .insert(sessionData)
          .select('id')
          .single();

      final sessionId = sessionRes['id'] as String;

      // 2. أنشئ سجلات المجموعات
      final setsData = sets.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        return {
          'session_id': sessionId,
          'exercise_id': exerciseId,
          'exercise_name': exerciseName,
          'set_number': i + 1,
          'weight_kg': s.weightKg,
          'reps': s.reps,
          if (s.feeling != null) 'feeling': s.feeling,
        };
      }).toList();

      await _supabase.from('set_logs').insert(setsData);

      log('WorkoutLogRepo: Session $sessionId saved with ${sets.length} sets');
      return sessionId;
    } catch (e) {
      log('WorkoutLogRepo: Error saving session: $e');
      rethrow;
    }
  }

  // ─── آخر جلسة لهذا التمرين ──────────────────────────────────
  Future<List<SetLog>> getLastSessionSets({
    required String userId,
    required int exerciseId,
  }) async {
    try {
      // ابحث عن آخر session لهذا المستخدم والتمرين
      final sessionRes = await _supabase
          .from('workout_sessions')
          .select('id')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      if (sessionRes.isEmpty) return [];

      // ابحث عن set_logs بنفس exercise_id في هذه الـ sessions
      final sessionIds =
          (sessionRes as List).map((s) => s['id'] as String).toList();

      final setsRes = await _supabase
          .from('set_logs')
          .select()
          .eq('exercise_id', exerciseId)
          .inFilter('session_id', sessionIds)
          .order('created_at', ascending: false)
          .limit(20);

      if ((setsRes as List).isEmpty) return [];

      // خذ فقط آخر session التي فيها هذا التمرين
      final latestSessionId = setsRes.first['session_id'] as String;
      final lastSets = setsRes
          .where((s) => s['session_id'] == latestSessionId)
          .map((s) => SetLog.fromJson(s))
          .toList();

      lastSets.sort((a, b) => a.setNumber.compareTo(b.setNumber));
      return lastSets;
    } catch (e) {
      log('WorkoutLogRepo: Error fetching last session: $e');
      return [];
    }
  }

  // ─── كل سجلات تمرين معين لمستخدم (للمدرب) ──────────────────
  Future<List<WorkoutSession>> getSessionsForTrainee({
    required String userId,
    int? exerciseId,
    int limit = 20,
  }) async {
    try {
      var query = _supabase
          .from('workout_sessions')
          .select('*, set_logs(*)')
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(limit);

      final res = await query;
      return (res as List).map((s) {
        final rawSets = s['set_logs'] as List? ?? [];
        final sets =
            rawSets.map((sl) => SetLog.fromJson(sl as Map<String, dynamic>)).toList();
        return WorkoutSession.fromJson(s as Map<String, dynamic>, sets: sets);
      }).toList();
    } catch (e) {
      log('WorkoutLogRepo: Error fetching trainee sessions: $e');
      return [];
    }
  }

  // ─── تحقق من الرقم القياسي (PR) ─────────────────────────────
  Future<double?> getPersonalRecord({
    required String userId,
    required int exerciseId,
  }) async {
    try {
      final res = await _supabase
          .from('set_logs')
          .select('weight_kg, workout_sessions!inner(user_id)')
          .eq('workout_sessions.user_id', userId)
          .eq('exercise_id', exerciseId)
          .order('weight_kg', ascending: false)
          .limit(1);

      if ((res as List).isEmpty) return null;
      return (res.first['weight_kg'] as num).toDouble();
    } catch (e) {
      log('WorkoutLogRepo: Error fetching PR: $e');
      return null;
    }
  }

  // ─── تنبيه المدرب للمنقطعين (هدية 1) ───────────────────────
  Future<Set<String>> getActiveUserIdsInLastDays({int days = 5}) async {
    try {
      final cutoff = DateTime.now()
          .subtract(Duration(days: days))
          .toIso8601String()
          .split('T')
          .first;

      final workoutRes = await _supabase
          .from('workout_sessions')
          .select('user_id')
          .gte('date', cutoff);

      final mealRes = await _supabase
          .from('meal_logs')
          .select('user_id')
          .gte('date', cutoff)
          .eq('completed', true);

      final Set<String> activeIds = {};
      for (final r in (workoutRes as List)) {
        final uid = r['user_id']?.toString();
        if (uid != null && uid.isNotEmpty) activeIds.add(uid);
      }
      for (final r in (mealRes as List)) {
        final uid = r['user_id']?.toString();
        if (uid != null && uid.isNotEmpty) activeIds.add(uid);
      }
      return activeIds;
    } catch (e) {
      log('WorkoutLogRepo: Error fetching active users: $e');
      return {};
    }
  }

  // ─── Offline Queue ───────────────────────────────────────────

  /// حفظ محلي عند انقطاع الإنترنت
  Future<void> savePendingLocally({
    required String userId,
    required int exerciseId,
    required String exerciseName,
    required List<SetLog> sets,
    String? notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_kPendingLogsKey);
    final List<dynamic> queue = existing != null ? jsonDecode(existing) : [];

    queue.add({
      'user_id': userId,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'sets': sets.map((s) => s.toJson()).toList(),
      if (notes != null) 'notes': notes,
      'queued_at': DateTime.now().toIso8601String(),
    });

    await prefs.setString(_kPendingLogsKey, jsonEncode(queue));
    log('WorkoutLogRepo: Saved ${queue.length} pending sessions locally');
  }

  /// رفع الطابور المحلي عند عودة الإنترنت
  Future<void> syncPendingLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_kPendingLogsKey);
    if (existing == null || existing.isEmpty) return;

    List<dynamic> queue;
    try {
      queue = jsonDecode(existing);
    } catch (_) {
      await prefs.remove(_kPendingLogsKey);
      return;
    }

    if (queue.isEmpty) return;
    log('WorkoutLogRepo: Syncing ${queue.length} pending sessions...');

    final List<dynamic> failed = [];

    for (final item in queue) {
      try {
        final sets = (item['sets'] as List)
            .map((s) => SetLog.fromJson(s as Map<String, dynamic>))
            .toList();

        await saveSession(
          userId: item['user_id'] as String,
          exerciseId: item['exercise_id'] as int,
          exerciseName: item['exercise_name'] as String? ?? '',
          sets: sets,
          notes: item['notes'] as String?,
        );
      } catch (e) {
        log('WorkoutLogRepo: Failed to sync item: $e');
        failed.add(item);
      }
    }

    if (failed.isEmpty) {
      await prefs.remove(_kPendingLogsKey);
      log('WorkoutLogRepo: All pending sessions synced ✅');
    } else {
      await prefs.setString(_kPendingLogsKey, jsonEncode(failed));
      log('WorkoutLogRepo: ${failed.length} sessions still pending');
    }
  }

  Future<int> getPendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_kPendingLogsKey);
    if (existing == null || existing.isEmpty) return 0;
    try {
      return (jsonDecode(existing) as List).length;
    } catch (_) {
      return 0;
    }
  }
}

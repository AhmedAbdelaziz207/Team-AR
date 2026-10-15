import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/workout_log/logic/workout_log_state.dart';
import 'package:team_ar/features/workout_log/model/set_log.dart';
import 'package:team_ar/features/workout_log/repos/workout_log_repository.dart';

class WorkoutLogCubit extends Cubit<WorkoutLogState> {
  final WorkoutLogRepository _repo;
  WorkoutLogRepository get repository => _repo;
  bool _isSaving = false;

  WorkoutLogCubit(this._repo) : super(const WorkoutLogState.initial());

  // ─── جلب آخر جلسة (الأداء السابق) ──────────────────────────
  Future<void> loadPreviousSession({
    required int exerciseId,
  }) async {
    emit(const WorkoutLogState.loadingPrevious());

    final userId =
        await SharedPreferencesHelper.getString(AppConstants.userId) ?? '';

    // مزامنة أي جلسات معلقة محلياً في الخلفية
    syncPending();

    try {
      final previous = await _repo.getLastSessionSets(
        userId: userId,
        exerciseId: exerciseId,
      );
      final pr = await _repo.getPersonalRecord(
        userId: userId,
        exerciseId: exerciseId,
      );
      emit(WorkoutLogState.ready(
        previousSets: previous,
        previousPR: pr ?? 0.0,
      ));
    } catch (e) {
      log('WorkoutLogCubit: loadPrevious error: $e');
      emit(const WorkoutLogState.ready(previousSets: []));
    }
  }

  // ─── حفظ الجلسة ─────────────────────────────────────────────
  Future<void> saveSession({
    required int exerciseId,
    required String exerciseName,
    required List<SetLog> sets,
    String? notes,
  }) async {
    if (_isSaving) return;
    if (sets.isEmpty) return;

    _isSaving = true;
    emit(const WorkoutLogState.saving());

    final userId =
        await SharedPreferencesHelper.getString(AppConstants.userId) ?? '';

    // الـ PR الحالي (قبل الحفظ)
    double currentPR = 0.0;
    if (state is WorkoutLogReady) {
      currentPR = (state as WorkoutLogReady).previousPR;
    }

    try {
      // تحقق من الاتصال
      final connectivity = await Connectivity().checkConnectivity();
      final hasInternet = !connectivity.contains(ConnectivityResult.none);

      if (hasInternet) {
        await _repo.saveSession(
          userId: userId,
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          sets: sets,
          notes: notes,
        );

        // كشف الـ PR
        final maxWeight =
            sets.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b);
        final isNewPR = maxWeight > currentPR;

        emit(WorkoutLogState.saved(
          savedSets: sets,
          isNewPR: isNewPR,
          bestWeightKg: maxWeight,
        ));
        log('WorkoutLogCubit: Session saved online. PR: $isNewPR');
      } else {
        // احفظ في الطابور المحلي
        await _repo.savePendingLocally(
          userId: userId,
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          sets: sets,
          notes: notes,
        );
        emit(const WorkoutLogState.savedOffline());
        log('WorkoutLogCubit: Session saved offline for later sync');
      }
    } catch (e) {
      log('WorkoutLogCubit: Error saving: $e');
      // عند الخطأ احفظ محليًا بدلًا من الفشل
      try {
        await _repo.savePendingLocally(
          userId: userId,
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          sets: sets,
          notes: notes,
        );
        emit(const WorkoutLogState.savedOffline());
      } catch (e2) {
        emit(WorkoutLogState.error(e2.toString()));
      }
    } finally {
      _isSaving = false;
    }
  }

  // ─── مزامنة الطابور عند عودة الإنترنت ───────────────────────
  Future<void> syncPending() async {
    try {
      await _repo.syncPendingLogs();
    } catch (e) {
      log('WorkoutLogCubit: Sync error: $e');
    }
  }
}

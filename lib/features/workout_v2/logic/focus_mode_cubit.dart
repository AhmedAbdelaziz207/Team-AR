import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/exercise_log_model.dart';
import '../models/exercise_model.dart';
import '../models/exercise_set_log_model.dart';
import '../models/workout_model.dart';
import '../repos/workout_repository_v2.dart';

class FocusExerciseItem {
  final ExerciseModel exercise;
  final ExerciseLogModel? previousLog;
  final List<ExerciseSetLogModel> sets;
  final String effortRating;

  const FocusExerciseItem({
    required this.exercise,
    this.previousLog,
    required this.sets,
    this.effortRating = 'moderate',
  });

  FocusExerciseItem copyWith({
    ExerciseModel? exercise,
    ExerciseLogModel? previousLog,
    List<ExerciseSetLogModel>? sets,
    String? effortRating,
  }) {
    return FocusExerciseItem(
      exercise: exercise ?? this.exercise,
      previousLog: previousLog ?? this.previousLog,
      sets: sets ?? this.sets,
      effortRating: effortRating ?? this.effortRating,
    );
  }
}

class FocusModeState {
  final WorkoutModel workout;
  final List<FocusExerciseItem> items;
  final int elapsedSeconds;
  final bool isRestTimerActive;
  final int restSecondsRemaining;
  final int restTotalSeconds;
  final String? activeExerciseName;
  final bool isLongRest;
  final bool isRestCompletedAlert;
  final String? nextExerciseOrSetName;
  final bool isGuidedMode;
  final int? currentlyPlayingExerciseIndex;
  final bool isSaving;
  final bool isFinished;
  final String? errorMessage;

  const FocusModeState({
    required this.workout,
    this.items = const [],
    this.elapsedSeconds = 0,
    this.isRestTimerActive = false,
    this.restSecondsRemaining = 0,
    this.restTotalSeconds = 0,
    this.activeExerciseName,
    this.isLongRest = false,
    this.isRestCompletedAlert = false,
    this.nextExerciseOrSetName,
    this.isGuidedMode = true,
    this.currentlyPlayingExerciseIndex,
    this.isSaving = false,
    this.isFinished = false,
    this.errorMessage,
  });

  String get formattedElapsedTime {
    final hours = elapsedSeconds ~/ 3600;
    final mins = (elapsedSeconds % 3600) ~/ 60;
    final secs = elapsedSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get restProgress {
    if (restTotalSeconds <= 0) return 0.0;
    return restSecondsRemaining / restTotalSeconds;
  }

  int get totalSetsCount {
    int count = 0;
    for (final item in items) {
      count += item.sets.length;
    }
    return count;
  }

  int get completedSetsCount {
    int count = 0;
    for (final item in items) {
      count += item.sets.where((s) => s.isCompleted).length;
    }
    return count;
  }

  double get overallProgress {
    if (totalSetsCount == 0) return 0.0;
    return (completedSetsCount / totalSetsCount).clamp(0.0, 1.0);
  }

  double get totalVolumeLifted {
    double total = 0.0;
    for (final item in items) {
      for (final s in item.sets) {
        if (s.isCompleted) {
          total += (s.weight * s.reps);
        }
      }
    }
    return total;
  }

  int get completedExercisesCount {
    return items
        .where((item) =>
            item.sets.isNotEmpty && item.sets.every((s) => s.isCompleted))
        .length;
  }

  FocusModeState copyWith({
    WorkoutModel? workout,
    List<FocusExerciseItem>? items,
    int? elapsedSeconds,
    bool? isRestTimerActive,
    int? restSecondsRemaining,
    int? restTotalSeconds,
    String? activeExerciseName,
    bool? isLongRest,
    bool? isRestCompletedAlert,
    String? nextExerciseOrSetName,
    bool? isGuidedMode,
    int? currentlyPlayingExerciseIndex,
    bool clearPlayingVideo = false,
    bool? isSaving,
    bool? isFinished,
    String? errorMessage,
  }) {
    return FocusModeState(
      workout: workout ?? this.workout,
      items: items ?? this.items,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRestTimerActive: isRestTimerActive ?? this.isRestTimerActive,
      restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
      restTotalSeconds: restTotalSeconds ?? this.restTotalSeconds,
      activeExerciseName: activeExerciseName ?? this.activeExerciseName,
      isLongRest: isLongRest ?? this.isLongRest,
      isRestCompletedAlert: isRestCompletedAlert ?? this.isRestCompletedAlert,
      nextExerciseOrSetName:
          nextExerciseOrSetName ?? this.nextExerciseOrSetName,
      isGuidedMode: isGuidedMode ?? this.isGuidedMode,
      currentlyPlayingExerciseIndex: clearPlayingVideo
          ? null
          : (currentlyPlayingExerciseIndex ??
              this.currentlyPlayingExerciseIndex),
      isSaving: isSaving ?? this.isSaving,
      isFinished: isFinished ?? this.isFinished,
      errorMessage: errorMessage,
    );
  }
}

class FocusModeCubit extends Cubit<FocusModeState> {
  final WorkoutRepositoryV2 _repo;
  Timer? _stopwatchTimer;
  Timer? _restTimer;

  FocusModeCubit(
    this._repo,
    WorkoutModel workout, {
    bool initialGuidedMode = true,
  }) : super(
            FocusModeState(workout: workout, isGuidedMode: initialGuidedMode)) {
    _startStopwatch();
  }

  /// التبديل السلس بين الوضع الشامل (فيديو + شرح) ووضع التركيز السريع
  void toggleViewMode() {
    HapticFeedback.selectionClick();
    emit(state.copyWith(isGuidedMode: !state.isGuidedMode));
  }

  void setGuidedMode(bool value) {
    if (state.isGuidedMode != value) {
      HapticFeedback.selectionClick();
      emit(state.copyWith(isGuidedMode: value));
    }
  }

  void setPlayingExerciseVideo(int? index) {
    if (index == null) {
      emit(state.copyWith(clearPlayingVideo: true));
    } else {
      emit(state.copyWith(currentlyPlayingExerciseIndex: index));
    }
  }

  void _startStopwatch() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
    });
  }

  Future<void> initSession(String traineeId) async {
    final List<FocusExerciseItem> items = [];
    for (final ex in state.workout.exercises) {
      final prev = await _repo.getPreviousExerciseLog(ex.id, traineeId);
      final count = ex.targetSets > 0 ? ex.targetSets : 3;

      final sets = List.generate(count, (i) {
        double initW = 0.0;
        int initR = 0;
        if (prev != null && i < prev.sets.length) {
          initW = prev.sets[i].weight;
          initR = prev.sets[i].reps;
        }
        return ExerciseSetLogModel(
          setNumber: i + 1,
          weight: initW,
          reps: initR,
          isCompleted: false,
        );
      });

      items.add(FocusExerciseItem(
        exercise: ex,
        previousLog: prev,
        sets: sets,
      ));
    }
    emit(state.copyWith(items: items));
  }

  /// تبديل إكمال المجموعة — تفعيل مؤقت الراحة التلقائي
  void toggleSetComplete(int exerciseIndex, int setIndex, bool isCompleted) {
    if (exerciseIndex < 0 || exerciseIndex >= state.items.length) return;
    final item = state.items[exerciseIndex];
    if (setIndex < 0 || setIndex >= item.sets.length) return;

    final updatedSets = List<ExerciseSetLogModel>.from(item.sets);
    updatedSets[setIndex] =
        updatedSets[setIndex].copyWith(isCompleted: isCompleted);

    final updatedItems = List<FocusExerciseItem>.from(state.items);
    updatedItems[exerciseIndex] = item.copyWith(sets: updatedSets);

    emit(state.copyWith(items: updatedItems));

    // إذا تم تحديد المجموعة كمكتملة، شغّل مؤقت الراحة التلقائي!
    if (isCompleted) {
      final bool isLastSetOfExercise = (setIndex == updatedSets.length - 1);
      final bool hasNextExercise = (exerciseIndex + 1 < state.items.length);

      String nextTarget;
      int restSeconds;

      if (isLastSetOfExercise) {
        // راحة كبيرة بين تمرين وآخر
        if (hasNextExercise) {
          final nextExName = state.items[exerciseIndex + 1].exercise.name;
          nextTarget = 'التمرين التالي: $nextExName';
        } else {
          nextTarget = 'أكملت كافة تمارين الجلسة!';
        }
        restSeconds = item.exercise.restSeconds > 0
            ? (item.exercise.restSeconds + 30)
            : 150;
      } else {
        // راحة قصيرة بين مجموعات نفس التمرين
        nextTarget = 'المجموعة ${setIndex + 2} من ${item.exercise.name}';
        restSeconds =
            item.exercise.restSeconds > 0 ? item.exercise.restSeconds : 90;

        // نسخ تلقائي ذكي للوزن والتكرار للمجموعة التالية إذا لم تكن مسجلة بعد
        if (setIndex + 1 < updatedSets.length) {
          final next = updatedSets[setIndex + 1];
          if (next.weight == 0 && next.reps == 0 && !next.isCompleted) {
            updatedSets[setIndex + 1] = next.copyWith(
              weight: updatedSets[setIndex].weight,
              reps: updatedSets[setIndex].reps,
            );
            updatedItems[exerciseIndex] = item.copyWith(sets: updatedSets);
            emit(state.copyWith(items: updatedItems));
          }
        }
      }

      HapticFeedback.heavyImpact();
      startRestTimer(
        restSeconds,
        exerciseName: item.exercise.name,
        isLongRest: isLastSetOfExercise,
        nextTargetName: nextTarget,
      );
    }
  }

  /// تشغيل مؤقت الراحة التلقائي مع دعم التمييز بين الراحة القصيرة والكبيرة
  void startRestTimer(
    int seconds, {
    String? exerciseName,
    bool isLongRest = false,
    String? nextTargetName,
  }) {
    _restTimer?.cancel();
    emit(state.copyWith(
      isRestTimerActive: true,
      isRestCompletedAlert: false,
      restSecondsRemaining: seconds,
      restTotalSeconds: seconds,
      activeExerciseName: exerciseName,
      isLongRest: isLongRest,
      nextExerciseOrSetName: nextTargetName,
    ));

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.restSecondsRemaining <= 1) {
        timer.cancel();
        // إطلاق نغمة واهتزاز قوي متعدد النبضات
        _triggerRestAlarm();
        emit(state.copyWith(
          isRestTimerActive: false,
          isRestCompletedAlert: true,
          restSecondsRemaining: 0,
        ));
      } else {
        emit(state.copyWith(
          restSecondsRemaining: state.restSecondsRemaining - 1,
        ));
      }
    });
  }

  /// تنبيه اهتزاز وصوت متعدد النبضات لإيقاظ وتنبيه المتدرب
  void _triggerRestAlarm() {
    for (int i = 0; i < 5; i++) {
      Timer(Duration(milliseconds: i * 220), () {
        HapticFeedback.heavyImpact();
        HapticFeedback.vibrate();
        SystemSound.play(SystemSoundType.alert);
      });
    }
  }

  /// إخفاء تنبيه انتهاء الراحة
  void dismissRestAlert() {
    emit(state.copyWith(isRestCompletedAlert: false));
  }

  /// زيادة أو إنقاص وقت الراحة (مثلاً +15s أو -15s)
  void adjustRestTime(int deltaSeconds) {
    if (!state.isRestTimerActive) return;
    final newRemaining =
        (state.restSecondsRemaining + deltaSeconds).clamp(5, 600);
    final newTotal =
        (state.restTotalSeconds + deltaSeconds).clamp(newRemaining, 600);
    HapticFeedback.selectionClick();
    emit(state.copyWith(
      restSecondsRemaining: newRemaining,
      restTotalSeconds: newTotal,
    ));
  }

  /// تخطي وقت الراحة
  void skipRestTimer() {
    _restTimer?.cancel();
    HapticFeedback.lightImpact();
    emit(state.copyWith(
      isRestTimerActive: false,
      restSecondsRemaining: 0,
    ));
  }

  /// تعديل وزن أو تكرار مجموعة معينة
  void updateSetValues(int exerciseIndex, int setIndex,
      {double? weight, int? reps}) {
    if (exerciseIndex < 0 || exerciseIndex >= state.items.length) return;
    final item = state.items[exerciseIndex];
    if (setIndex < 0 || setIndex >= item.sets.length) return;

    final updatedSets = List<ExerciseSetLogModel>.from(item.sets);
    updatedSets[setIndex] =
        updatedSets[setIndex].copyWith(weight: weight, reps: reps);

    final updatedItems = List<FocusExerciseItem>.from(state.items);
    updatedItems[exerciseIndex] = item.copyWith(sets: updatedSets);

    emit(state.copyWith(items: updatedItems));
  }

  /// إضافة مجموعة داخل وضع التركيز
  void addSetToExercise(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= state.items.length) return;
    final item = state.items[exerciseIndex];
    final updatedSets = List<ExerciseSetLogModel>.from(item.sets);
    final last = updatedSets.isNotEmpty ? updatedSets.last : null;

    updatedSets.add(ExerciseSetLogModel(
      setNumber: updatedSets.length + 1,
      weight: last?.weight ?? 0.0,
      reps: last?.reps ?? 10,
      isCompleted: false,
    ));

    final updatedItems = List<FocusExerciseItem>.from(state.items);
    updatedItems[exerciseIndex] = item.copyWith(sets: updatedSets);

    emit(state.copyWith(items: updatedItems));
  }

  /// حذف مجموعة من تمرين معين
  void removeSetFromExercise(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= state.items.length) return;
    final item = state.items[exerciseIndex];
    if (setIndex < 0 || setIndex >= item.sets.length) return;
    if (item.sets.length <= 1) return; // الحفاظ على مجموعة واحدة على الأقل

    final updatedSets = List<ExerciseSetLogModel>.from(item.sets)
      ..removeAt(setIndex);
    final renumbered = <ExerciseSetLogModel>[];
    for (int i = 0; i < updatedSets.length; i++) {
      renumbered.add(updatedSets[i].copyWith(setNumber: i + 1));
    }

    final updatedItems = List<FocusExerciseItem>.from(state.items);
    updatedItems[exerciseIndex] = item.copyWith(sets: renumbered);
    emit(state.copyWith(items: updatedItems));
  }

  /// تحديث تقييم المجهود للتمرين في وضع التركيز
  void updateExerciseEffort(int exerciseIndex, String rating) {
    if (exerciseIndex < 0 || exerciseIndex >= state.items.length) return;
    final updatedItems = List<FocusExerciseItem>.from(state.items);
    updatedItems[exerciseIndex] =
        updatedItems[exerciseIndex].copyWith(effortRating: rating);
    emit(state.copyWith(items: updatedItems));
  }

  /// إنهاء وحفظ الجلسة
  Future<bool> finishSession(String traineeId) async {
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();
    emit(state.copyWith(isSaving: true, isRestTimerActive: false));

    try {
      for (final item in state.items) {
        final completedSets = item.sets.where((s) => s.isCompleted).toList();
        if (completedSets.isNotEmpty) {
          final logModel = ExerciseLogModel(
            exerciseId: item.exercise.id,
            traineeId: traineeId,
            date: DateTime.now(),
            effortRating: item.effortRating,
            completed: true,
          );
          await _repo.saveExerciseLog(
              exerciseLog: logModel, sets: completedSets);
        }
      }

      emit(state.copyWith(isSaving: false, isFinished: true));
      return true;
    } catch (e) {
      emit(state.copyWith(
          isSaving: false, errorMessage: 'تعذر إنهاء وحفظ الجلسة: $e'));
      return false;
    }
  }

  @override
  Future<void> close() {
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();
    return super.close();
  }
}

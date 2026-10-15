import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/exercise_log_model.dart';
import '../models/exercise_model.dart';
import '../models/exercise_set_log_model.dart';
import '../repos/workout_repository_v2.dart';

class SingleExerciseState {
  final ExerciseModel exercise;
  final ExerciseLogModel? previousLog;
  final List<ExerciseSetLogModel> sets;
  final String unit;
  final String effortRating;
  final bool isLoading;
  final bool isSaving;
  final bool isSaved;
  final String? errorMessage;

  const SingleExerciseState({
    required this.exercise,
    this.previousLog,
    this.sets = const [],
    this.unit = 'kg',
    this.effortRating = 'moderate',
    this.isLoading = false,
    this.isSaving = false,
    this.isSaved = false,
    this.errorMessage,
  });

  SingleExerciseState copyWith({
    ExerciseModel? exercise,
    ExerciseLogModel? previousLog,
    List<ExerciseSetLogModel>? sets,
    String? unit,
    String? effortRating,
    bool? isLoading,
    bool? isSaving,
    bool? isSaved,
    String? errorMessage,
  }) {
    return SingleExerciseState(
      exercise: exercise ?? this.exercise,
      previousLog: previousLog ?? this.previousLog,
      sets: sets ?? this.sets,
      unit: unit ?? this.unit,
      effortRating: effortRating ?? this.effortRating,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      errorMessage: errorMessage,
    );
  }
}

class SingleExerciseCubit extends Cubit<SingleExerciseState> {
  final WorkoutRepositoryV2 _repo;

  SingleExerciseCubit(this._repo, ExerciseModel exercise)
      : super(SingleExerciseState(exercise: exercise));

  Future<void> initExercise(String traineeId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final prevLog = await _repo.getPreviousExerciseLog(state.exercise.id, traineeId);

      // إنشاء المجموعات الأولية بناءً على target_sets
      final initialSets = List.generate(
        state.exercise.targetSets > 0 ? state.exercise.targetSets : 3,
        (i) {
          double initW = 0.0;
          int initReps = 0;
          if (prevLog != null && i < prevLog.sets.length) {
            initW = prevLog.sets[i].weight;
            initReps = prevLog.sets[i].reps;
          }
          return ExerciseSetLogModel(
            setNumber: i + 1,
            weight: initW,
            reps: initReps,
            weightUnit: state.unit,
          );
        },
      );

      emit(state.copyWith(
        isLoading: false,
        previousLog: prevLog,
        sets: initialSets,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'تعذر جلب الأداء السابق: $e'));
    }
  }

  void toggleUnit(String newUnit) {
    if (state.unit == newUnit) return;
    emit(state.copyWith(unit: newUnit));
  }

  void updateSet(int index, {double? weight, int? reps, bool? isCompleted}) {
    final updated = List<ExerciseSetLogModel>.from(state.sets);
    if (index >= 0 && index < updated.length) {
      updated[index] = updated[index].copyWith(
        weight: weight,
        reps: reps,
        isCompleted: isCompleted,
      );
      emit(state.copyWith(sets: updated));
    }
  }

  void addSet() {
    final updated = List<ExerciseSetLogModel>.from(state.sets);
    final lastSet = updated.isNotEmpty ? updated.last : null;
    updated.add(ExerciseSetLogModel(
      setNumber: updated.length + 1,
      weight: lastSet?.weight ?? 0.0,
      reps: lastSet?.reps ?? 10,
      weightUnit: state.unit,
    ));
    emit(state.copyWith(sets: updated));
  }

  void removeSet(int index) {
    if (state.sets.length <= 1) return;
    final updated = List<ExerciseSetLogModel>.from(state.sets)..removeAt(index);
    // إعادة ترقيم المجموعات
    for (int i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(setNumber: i + 1);
    }
    emit(state.copyWith(sets: updated));
  }

  /// نسخ أداء الجلسة السابقة بالكامل إلى المجموعات الحالية بلمسة واحدة
  void copyPreviousPerformance() {
    if (state.previousLog == null || state.previousLog!.sets.isEmpty) return;
    final prevSets = state.previousLog!.sets;
    final copiedSets = List.generate(prevSets.length, (i) {
      return ExerciseSetLogModel(
        setNumber: i + 1,
        weight: prevSets[i].weight,
        reps: prevSets[i].reps,
        weightUnit: state.unit,
        isCompleted: false,
      );
    });
    emit(state.copyWith(sets: copiedSets));
  }

  void setEffortRating(String rating) {
    emit(state.copyWith(effortRating: rating));
  }

  Future<bool> saveExercise(String traineeId, {String? notes}) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      final logModel = ExerciseLogModel(
        exerciseId: state.exercise.id,
        traineeId: traineeId,
        date: DateTime.now(),
        effortRating: state.effortRating,
        coachFeedbackNotes: notes,
        completed: true,
      );

      final ok = await _repo.saveExerciseLog(
        exerciseLog: logModel,
        sets: state.sets,
      );

      if (ok) {
        emit(state.copyWith(isSaving: false, isSaved: true));
        return true;
      } else {
        emit(state.copyWith(isSaving: false, errorMessage: 'فشل حفظ تمرين اليوم'));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: 'خطأ أثناء الحفظ: $e'));
      return false;
    }
  }
}

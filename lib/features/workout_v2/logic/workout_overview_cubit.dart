import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/workout_model.dart';
import '../repos/workout_repository_v2.dart';

abstract class WorkoutOverviewState {
  const WorkoutOverviewState();
}

class WorkoutOverviewInitial extends WorkoutOverviewState {
  const WorkoutOverviewInitial();
}

class WorkoutOverviewLoading extends WorkoutOverviewState {
  const WorkoutOverviewLoading();
}

class WorkoutOverviewSuccess extends WorkoutOverviewState {
  final WorkoutModel workout;
  final int totalExercises;
  final int totalSets;
  final String estimatedReps;
  final int currentDayIndex;
  final int totalDaysCount;
  final List<WorkoutModel> allAssignedWorkouts;

  const WorkoutOverviewSuccess({
    required this.workout,
    required this.totalExercises,
    required this.totalSets,
    required this.estimatedReps,
    this.currentDayIndex = 0,
    this.totalDaysCount = 1,
    this.allAssignedWorkouts = const [],
  });
}

class WorkoutOverviewRecovery extends WorkoutOverviewState {
  final WorkoutModel nextWorkout;
  final Duration remainingCooldown;
  final DateTime lastWorkoutFinishedAt;
  final int currentDayIndex;
  final int totalDaysCount;

  const WorkoutOverviewRecovery({
    required this.nextWorkout,
    required this.remainingCooldown,
    required this.lastWorkoutFinishedAt,
    required this.currentDayIndex,
    required this.totalDaysCount,
  });
}

class WorkoutOverviewEmpty extends WorkoutOverviewState {
  const WorkoutOverviewEmpty();
}

class WorkoutOverviewError extends WorkoutOverviewState {
  final String message;
  const WorkoutOverviewError(this.message);
}

class WorkoutOverviewCubit extends Cubit<WorkoutOverviewState> {
  final WorkoutRepositoryV2 _repo;

  WorkoutOverviewCubit(this._repo) : super(const WorkoutOverviewInitial());

  Future<void> loadOverview(String traineeId) async {
    emit(const WorkoutOverviewLoading());
    try {
      final smartResult = await _repo.getSmartActiveWorkout(traineeId);
      if (smartResult.activeWorkout == null) {
        emit(const WorkoutOverviewEmpty());
        return;
      }

      if (smartResult.isRecoveryMode && smartResult.remainingCooldown != null) {
        emit(WorkoutOverviewRecovery(
          nextWorkout: smartResult.activeWorkout!,
          remainingCooldown: smartResult.remainingCooldown!,
          lastWorkoutFinishedAt:
              smartResult.lastWorkoutFinishedAt ?? DateTime.now(),
          currentDayIndex: smartResult.currentDayIndex,
          totalDaysCount: smartResult.totalDaysCount,
        ));
        return;
      }

      final workout = smartResult.activeWorkout!;
      final totalExercises = workout.exercises.length;
      final totalSets = workout.exercises.fold<int>(
        0,
        (sum, e) => sum + e.targetSets,
      );

      // تقدير إجمالي التكرارات
      final totalRepsMin = workout.exercises.fold<int>(0, (sum, e) {
        final parts = e.targetRepsRange.split('-');
        final minReps = int.tryParse(parts.first.trim()) ?? 8;
        return sum + (minReps * e.targetSets);
      });
      final totalRepsMax = workout.exercises.fold<int>(0, (sum, e) {
        final parts = e.targetRepsRange.split('-');
        final maxReps = int.tryParse(parts.last.trim()) ?? 10;
        return sum + (maxReps * e.targetSets);
      });

      emit(WorkoutOverviewSuccess(
        workout: workout,
        totalExercises: totalExercises,
        totalSets: totalSets,
        estimatedReps: '$totalRepsMin - $totalRepsMax',
        currentDayIndex: smartResult.currentDayIndex,
        totalDaysCount: smartResult.totalDaysCount,
        allAssignedWorkouts: smartResult.allAssignedWorkouts,
      ));
    } catch (e) {
      emit(WorkoutOverviewError('تعذر تحميل تفاصيل التمرين: $e'));
    }
  }

  /// تجاوز فترة الراحة واستعراض أو لعب التمرين فوراً
  void unlockWorkoutNow(WorkoutModel workout) {
    final totalExercises = workout.exercises.length;
    final totalSets = workout.exercises.fold<int>(
      0,
      (sum, e) => sum + e.targetSets,
    );

    final totalRepsMin = workout.exercises.fold<int>(0, (sum, e) {
      final parts = e.targetRepsRange.split('-');
      final minReps = int.tryParse(parts.first.trim()) ?? 8;
      return sum + (minReps * e.targetSets);
    });
    final totalRepsMax = workout.exercises.fold<int>(0, (sum, e) {
      final parts = e.targetRepsRange.split('-');
      final maxReps = int.tryParse(parts.last.trim()) ?? 10;
      return sum + (maxReps * e.targetSets);
    });

    emit(WorkoutOverviewSuccess(
      workout: workout,
      totalExercises: totalExercises,
      totalSets: totalSets,
      estimatedReps: '$totalRepsMin - $totalRepsMax',
    ));
  }

  /// اختيار وتصفح يوم تدريبي معين من الجدول المسند
  void selectWorkoutDay(WorkoutModel workout, int index) {
    final totalExercises = workout.exercises.length;
    final totalSets = workout.exercises.fold<int>(
      0,
      (sum, e) => sum + e.targetSets,
    );

    final totalRepsMin = workout.exercises.fold<int>(0, (sum, e) {
      final parts = e.targetRepsRange.split('-');
      final minReps = int.tryParse(parts.first.trim()) ?? 8;
      return sum + (minReps * e.targetSets);
    });
    final totalRepsMax = workout.exercises.fold<int>(0, (sum, e) {
      final parts = e.targetRepsRange.split('-');
      final maxReps = int.tryParse(parts.last.trim()) ?? 10;
      return sum + (maxReps * e.targetSets);
    });

    final currentAssigned = (state is WorkoutOverviewSuccess)
        ? (state as WorkoutOverviewSuccess).allAssignedWorkouts
        : [workout];

    emit(WorkoutOverviewSuccess(
      workout: workout,
      totalExercises: totalExercises,
      totalSets: totalSets,
      estimatedReps: '$totalRepsMin - $totalRepsMax',
      currentDayIndex: index,
      totalDaysCount: currentAssigned.length,
      allAssignedWorkouts: currentAssigned,
    ));
  }
}

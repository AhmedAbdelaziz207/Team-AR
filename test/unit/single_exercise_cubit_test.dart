import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/features/workout_v2/logic/single_exercise_cubit.dart';
import 'package:team_ar/features/workout_v2/models/exercise_log_model.dart';
import 'package:team_ar/features/workout_v2/models/exercise_model.dart';
import 'package:team_ar/features/workout_v2/models/exercise_set_log_model.dart';
import 'package:team_ar/features/workout_v2/repos/workout_repository_v2.dart';

class FakeWorkoutRepo extends WorkoutRepositoryV2 {
  ExerciseLogModel? fakePreviousLog;
  bool saveResult = true;

  @override
  Future<ExerciseLogModel?> getPreviousExerciseLog(
      String exerciseId, String traineeId) async {
    return fakePreviousLog;
  }

  @override
  Future<bool> saveExerciseLog({
    required ExerciseLogModel exerciseLog,
    required List<ExerciseSetLogModel> sets,
  }) async {
    return saveResult;
  }
}

void main() {
  group('SingleExerciseCubit Tests', () {
    late FakeWorkoutRepo repo;
    late ExerciseModel testExercise;

    setUp(() {
      repo = FakeWorkoutRepo();
      testExercise = const ExerciseModel(
        id: 'ex_bench',
        workoutId: 'wo_1',
        name: 'Incline Bench Press',
        targetSets: 3,
        targetRepsRange: '8-10',
        rir: 2,
        tempo: '3-0-1-0',
        restSeconds: 90,
        technicalTip: 'HORIZONTAL GRIP & Retract Scapula',
      );
    });

    test('initial state contains exercise and default configuration', () {
      final cubit = SingleExerciseCubit(repo, testExercise);
      expect(cubit.state.exercise.name, 'Incline Bench Press');
      expect(cubit.state.unit, 'kg');
      expect(cubit.state.sets, isEmpty);
      expect(cubit.state.isLoading, isFalse);
    });

    test('initExercise creates default sets count based on targetSets', () async {
      final cubit = SingleExerciseCubit(repo, testExercise);
      await cubit.initExercise('user_123');

      expect(cubit.state.sets.length, 3);
      expect(cubit.state.sets[0].setNumber, 1);
      expect(cubit.state.sets[1].setNumber, 2);
      expect(cubit.state.sets[2].setNumber, 3);
      expect(cubit.state.previousLog, isNull);
    });

    test('copyPreviousPerformance copies exact weights and reps from previous log', () async {
      final prevSets = [
        const ExerciseSetLogModel(setNumber: 1, weight: 80.0, reps: 10, isCompleted: true),
        const ExerciseSetLogModel(setNumber: 2, weight: 85.0, reps: 8, isCompleted: true),
        const ExerciseSetLogModel(setNumber: 3, weight: 90.0, reps: 6, isCompleted: true),
      ];

      repo.fakePreviousLog = ExerciseLogModel(
        id: 'prev_1',
        exerciseId: 'ex_bench',
        traineeId: 'user_123',
        date: DateTime.now().subtract(const Duration(days: 3)),
        sets: prevSets,
      );

      final cubit = SingleExerciseCubit(repo, testExercise);
      await cubit.initExercise('user_123');

      expect(cubit.state.previousLog, isNotNull);

      // Now invoke 1-tap copy previous performance
      cubit.copyPreviousPerformance();

      expect(cubit.state.sets.length, 3);
      expect(cubit.state.sets[0].weight, 80.0);
      expect(cubit.state.sets[0].reps, 10);
      expect(cubit.state.sets[0].isCompleted, isFalse);

      expect(cubit.state.sets[1].weight, 85.0);
      expect(cubit.state.sets[1].reps, 8);

      expect(cubit.state.sets[2].weight, 90.0);
      expect(cubit.state.sets[2].reps, 6);
    });

    test('updateSet updates weight, reps and completion state correctly', () async {
      final cubit = SingleExerciseCubit(repo, testExercise);
      await cubit.initExercise('user_123');

      cubit.updateSet(0, weight: 92.5, reps: 9, isCompleted: true);

      expect(cubit.state.sets[0].weight, 92.5);
      expect(cubit.state.sets[0].reps, 9);
      expect(cubit.state.sets[0].isCompleted, isTrue);
    });

    test('addSet and removeSet adjust sets and re-index correctly', () async {
      final cubit = SingleExerciseCubit(repo, testExercise);
      await cubit.initExercise('user_123');
      expect(cubit.state.sets.length, 3);

      cubit.addSet();
      expect(cubit.state.sets.length, 4);
      expect(cubit.state.sets[3].setNumber, 4);

      cubit.removeSet(1); // remove set 2
      expect(cubit.state.sets.length, 3);
      expect(cubit.state.sets[0].setNumber, 1);
      expect(cubit.state.sets[1].setNumber, 2);
      expect(cubit.state.sets[2].setNumber, 3);
    });

    test('toggleUnit changes unit between kg and lbs', () {
      final cubit = SingleExerciseCubit(repo, testExercise);
      expect(cubit.state.unit, 'kg');

      cubit.toggleUnit('lbs');
      expect(cubit.state.unit, 'lbs');
    });

    test('setEffortRating updates rating', () {
      final cubit = SingleExerciseCubit(repo, testExercise);
      cubit.setEffortRating('hard');
      expect(cubit.state.effortRating, 'hard');
    });

    test('saveExercise successfully calls repo and emits isSaved', () async {
      final cubit = SingleExerciseCubit(repo, testExercise);
      await cubit.initExercise('user_123');

      final success = await cubit.saveExercise('user_123', notes: 'Great pump');
      expect(success, isTrue);
      expect(cubit.state.isSaved, isTrue);
      expect(cubit.state.isSaving, isFalse);
    });
  });
}

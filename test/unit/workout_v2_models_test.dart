import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/features/workout_v2/models/exercise_model.dart';
import 'package:team_ar/features/workout_v2/models/exercise_set_log_model.dart';
import 'package:team_ar/features/workout_v2/models/workout_model.dart';

void main() {
  group('Workout V2 Models Tests', () {
    test('ExerciseModel serialization & deserialization with V2 coach targets', () {
      final json = {
        'id': 'ex_1',
        'workout_id': 'wo_1',
        'name': 'Flat Dumbbell Press',
        'target_sets': 3,
        'target_reps_range': '8-10',
        'rir': 2,
        'tempo': '3-0-1-0',
        'rest_seconds': 90,
        'technical_tip': 'Retract scapula and keep wrists stacked',
        'video_guide_url': 'https://example.com/press.mp4',
        'order_index': 0,
      };

      final exercise = ExerciseModel.fromJson(json);

      expect(exercise.id, 'ex_1');
      expect(exercise.name, 'Flat Dumbbell Press');
      expect(exercise.targetSets, 3);
      expect(exercise.rir, 2);
      expect(exercise.tempo, '3-0-1-0');
      expect(exercise.restSeconds, 90);
      expect(exercise.technicalTip, 'Retract scapula and keep wrists stacked');

      final serialized = exercise.toJson();
      expect(serialized['name'], 'Flat Dumbbell Press');
      expect(serialized['rir'], 2);
      expect(serialized['tempo'], '3-0-1-0');
      expect(serialized['rest_seconds'], 90);
    });

    test('ExerciseSetLogModel serialization and completion state', () {
      final json = {
        'id': 'set_log_1',
        'exercise_log_id': 'log_1',
        'set_number': 1,
        'weight': 32.5,
        'reps': 10,
        'is_completed': true,
      };

      final setLog = ExerciseSetLogModel.fromJson(json);

      expect(setLog.setNumber, 1);
      expect(setLog.weight, 32.5);
      expect(setLog.reps, 10);
      expect(setLog.isCompleted, isTrue);

      final copy = setLog.copyWith(weight: 35.0, reps: 8);
      expect(copy.weight, 35.0);
      expect(copy.reps, 8);
      expect(copy.isCompleted, isTrue);
    });

    test('WorkoutModel serialization with exercises list', () {
      final json = {
        'id': 'wo_1',
        'coach_id': 'c_1',
        'trainee_id': 't_1',
        'title': 'Upper Body Hypertrophy',
        'target_muscles': ['الصدر', 'الأكتاف', 'الترايسبس'],
        'intro_video_url': 'https://example.com/intro.mp4',
        'pdf_attachment_url': 'https://example.com/plan.pdf',
        'created_at': '2026-10-05T10:00:00.000Z',
      };

      final workout = WorkoutModel.fromJson(json, exercises: [
        const ExerciseModel(
          id: 'ex_1',
          workoutId: 'wo_1',
          name: 'Incline Dumbbell Bench',
          targetSets: 4,
          targetRepsRange: '10-12',
          rir: 2,
          tempo: '2-0-1-0',
          restSeconds: 75,
          technicalTip: '30 degree bench angle',
        )
      ]);

      expect(workout.id, 'wo_1');
      expect(workout.title, 'Upper Body Hypertrophy');
      expect(workout.targetMuscles.length, 3);
      expect(workout.exercises.length, 1);
      expect(workout.exercises.first.name, 'Incline Dumbbell Bench');
    });

    test('WorkoutModel PDF-only plan verification (empty exercises list & attached PDF)', () {
      final json = {
        'id': 'wo_pdf_only',
        'coach_id': 'c_1',
        'trainee_id': 't_99',
        'title': 'خطة تضخيم للمبتدئين 4 أيام PDF',
        'target_muscles': ['الصدر', 'الظهر', 'الأرجل'],
        'pdf_attachment_url': 'https://example.com/bulk_plan_v1.pdf',
        'created_at': '2026-10-06T12:00:00.000Z',
      };

      final workout = WorkoutModel.fromJson(json, exercises: []);

      expect(workout.id, 'wo_pdf_only');
      expect(workout.title, 'خطة تضخيم للمبتدئين 4 أيام PDF');
      expect(workout.pdfAttachmentUrl, 'https://example.com/bulk_plan_v1.pdf');
      expect(workout.exercises, isEmpty);
    });

    test('WorkoutModel Hybrid plan verification (exercises + attached PDF)', () {
      final json = {
        'id': 'wo_hybrid',
        'coach_id': 'c_1',
        'trainee_id': 't_42',
        'title': 'Push Day + Full Routine Reference',
        'target_muscles': ['الصدر', 'الترايسبس'],
        'pdf_attachment_url': 'https://example.com/full_guide.pdf',
        'created_at': '2026-10-06T14:00:00.000Z',
      };

      final workout = WorkoutModel.fromJson(json, exercises: [
        const ExerciseModel(
          id: 'ex_1',
          workoutId: 'wo_hybrid',
          name: 'Flat Dumbbell Press',
          targetSets: 3,
        ),
      ]);

      expect(workout.id, 'wo_hybrid');
      expect(workout.pdfAttachmentUrl, 'https://example.com/full_guide.pdf');
      expect(workout.exercises.length, 1);
      expect(workout.exercises.first.name, 'Flat Dumbbell Press');
    });
  });
}

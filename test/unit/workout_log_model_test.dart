import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/features/workout_log/model/set_log.dart';
import 'package:team_ar/features/workout_log/model/workout_session.dart';

void main() {
  group('Workout Log Models Tests', () {
    test('SetLog fromJson and toJson serialization', () {
      final json = {
        'id': 'set-123',
        'session_id': 'session-456',
        'exercise_id': 10,
        'exercise_name': 'Bench Press',
        'set_number': 1,
        'weight_kg': 80.5,
        'reps': 10,
        'feeling': 2,
        'created_at': '2026-10-05T10:00:00.000Z',
      };

      final setLog = SetLog.fromJson(json);

      expect(setLog.id, equals('set-123'));
      expect(setLog.sessionId, equals('session-456'));
      expect(setLog.exerciseId, equals(10));
      expect(setLog.exerciseName, equals('Bench Press'));
      expect(setLog.setNumber, equals(1));
      expect(setLog.weightKg, equals(80.5));
      expect(setLog.reps, equals(10));
      expect(setLog.feeling, equals(2));

      final serialized = setLog.toJson();
      expect(serialized['weight_kg'], equals(80.5));
      expect(serialized['reps'], equals(10));
      expect(serialized['set_number'], equals(1));
    });

    test('WorkoutSession fromJson and toJson serialization', () {
      final json = {
        'id': 'session-001',
        'user_id': 'user-abc',
        'workout_day_id': 3,
        'date': '2026-10-05',
        'notes': 'Great workout session',
        'created_at': '2026-10-05T12:00:00.000Z',
      };

      final session = WorkoutSession.fromJson(json);

      expect(session.id, equals('session-001'));
      expect(session.userId, equals('user-abc'));
      expect(session.workoutDayId, equals(3));
      expect(session.notes, equals('Great workout session'));

      final serialized = session.toJson();
      expect(serialized['user_id'], equals('user-abc'));
      expect(serialized['date'], equals('2026-10-05'));
      expect(serialized['notes'], equals('Great workout session'));
    });
  });
}

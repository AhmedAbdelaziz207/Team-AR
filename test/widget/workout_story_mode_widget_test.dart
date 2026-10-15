import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/features/workout_v2/models/exercise_model.dart';
import 'package:team_ar/features/workout_v2/models/workout_model.dart';
import 'package:team_ar/features/workout_v2/ui/workout_story_mode_screen.dart';

Widget _wrapWithScreenUtil(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('WorkoutStoryModeScreen Widget Tests', () {
    testWidgets('renders empty message when workout has no exercises', (tester) async {
      final emptyWorkout = WorkoutModel(
        id: 'w_empty',
        coachId: 'c1',
        traineeId: 't1',
        title: 'Empty Day',
        targetMuscles: const [],
        createdAt: DateTime.now(),
        exercises: const [],
      );

      await tester.pumpWidget(
        _wrapWithScreenUtil(WorkoutStoryModeScreen(workout: emptyWorkout)),
      );
      await tester.pump();

      expect(find.text('لا توجد تمارين لعرضها'), findsOneWidget);
    });

    testWidgets('renders exercise details, technical tip, and segments correctly', (tester) async {
      final workout = WorkoutModel(
        id: 'w_1',
        coachId: 'c1',
        traineeId: 't1',
        title: 'Leg Day Hypertrophy',
        targetMuscles: const ['الأرجل', 'الخلفيات'],
        createdAt: DateTime.now(),
        exercises: const [
          ExerciseModel(
            id: 'ex_1',
            workoutId: 'w_1',
            name: 'Romanian Deadlift',
            targetSets: 4,
            targetRepsRange: '8-10',
            rir: 2,
            tempo: '3-1-1-0',
            restSeconds: 90,
            technicalTip: 'Keep spine neutral and hinge hips',
            orderIndex: 0,
          ),
          ExerciseModel(
            id: 'ex_2',
            workoutId: 'w_1',
            name: 'Bulgarian Split Squat',
            targetSets: 3,
            targetRepsRange: '10-12',
            rir: 1,
            tempo: '2-0-1-0',
            restSeconds: 60,
            technicalTip: 'Drive through front heel',
            orderIndex: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapWithScreenUtil(WorkoutStoryModeScreen(workout: workout)),
      );
      await tester.pump();

      // Workout Title
      expect(find.text('Leg Day Hypertrophy'), findsOneWidget);

      // Exercise 1 details
      expect(find.textContaining('Romanian Deadlift'), findsOneWidget);
      expect(find.text('Keep spine neutral and hinge hips'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('المجموعات'), findsOneWidget);
      expect(find.text('8-10'), findsOneWidget);
      expect(find.text('التكرار'), findsOneWidget);

      // Progress bars: 2 segments
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));

      // Call to action button
      expect(find.text('بدء التمرين الآن ⚡'), findsOneWidget);

      // Advance story by tapping right side of the screen
      await tester.tapAt(const Offset(300, 300));
      await tester.pump();

      // Now on Exercise 2
      expect(find.textContaining('Bulgarian Split Squat'), findsOneWidget);
      expect(find.text('Drive through front heel'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('10-12'), findsOneWidget);
    });
  });
}

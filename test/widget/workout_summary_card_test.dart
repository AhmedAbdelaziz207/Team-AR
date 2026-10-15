import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/features/workout_log/model/set_log.dart';
import 'package:team_ar/features/workout_log/widgets/workout_summary_card.dart';

Widget _wrapWithScreenUtil(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('WorkoutSummaryCard Widget Tests', () {
    testWidgets('renders SizedBox.shrink when sets list is empty', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          const WorkoutSummaryCard(
            sets: [],
            unit: 'kg',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('عاش يا بطل! تم تسجيل تمرينك بنجاح 💪'), findsNothing);
    });

    testWidgets('renders max weight, total reps and set details correctly', (tester) async {
      final testSets = [
        const SetLog(
          exerciseId: 1,
          exerciseName: 'Bench Press',
          setNumber: 1,
          weightKg: 80.0,
          reps: 10,
        ),
        const SetLog(
          exerciseId: 1,
          exerciseName: 'Bench Press',
          setNumber: 2,
          weightKg: 85.0,
          reps: 8,
        ),
        const SetLog(
          exerciseId: 1,
          exerciseName: 'Bench Press',
          setNumber: 3,
          weightKg: 90.0,
          reps: 6,
        ),
      ];

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          WorkoutSummaryCard(
            sets: testSets,
            unit: 'kg',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header
      expect(find.text('عاش يا بطل! تم تسجيل تمرينك بنجاح 💪'), findsOneWidget);

      // Check stats: max weight = 90 kg, total reps = 24
      expect(find.text('90 kg'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);

      // Check set labels
      expect(find.text('مجموعة 1'), findsOneWidget);
      expect(find.text('مجموعة 2'), findsOneWidget);
      expect(find.text('مجموعة 3'), findsOneWidget);
    });
  });
}

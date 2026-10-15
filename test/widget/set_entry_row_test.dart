import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/features/workout_log/model/set_log.dart';
import 'package:team_ar/features/workout_log/widgets/set_entry_row.dart';

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
  group('SetEntryRow Widget Tests', () {
    testWidgets('renders set number and initial weight and reps', (tester) async {
      final weightCtrl = TextEditingController(text: '80');
      final repsCtrl = TextEditingController(text: '10');

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          SetEntryRow(
            index: 0,
            weightCtrl: weightCtrl,
            repsCtrl: repsCtrl,
            unit: 'kg',
            canDelete: false,
            onDelete: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget); // Set #1
      expect(find.text('80'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('stepper + increments weight by 2.5 kg', (tester) async {
      final weightCtrl = TextEditingController(text: '80');
      final repsCtrl = TextEditingController(text: '10');

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          SetEntryRow(
            index: 0,
            weightCtrl: weightCtrl,
            repsCtrl: repsCtrl,
            unit: 'kg',
            canDelete: false,
            onDelete: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find first + icon (weight plus button)
      final plusIcons = find.byIcon(Icons.add_rounded);
      expect(plusIcons, findsNWidgets(2)); // 1 for weight, 1 for reps

      await tester.tap(plusIcons.first);
      await tester.pump();

      expect(weightCtrl.text, equals('82.5'));
    });

    testWidgets('copy previous set copies weight and reps upon tap', (tester) async {
      final weightCtrl = TextEditingController(text: '0');
      final repsCtrl = TextEditingController(text: '0');

      const prevSet = SetLog(
        exerciseId: 1,
        exerciseName: 'Bench Press',
        setNumber: 1,
        weightKg: 95.0,
        reps: 8,
      );

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          SetEntryRow(
            index: 0,
            weightCtrl: weightCtrl,
            repsCtrl: repsCtrl,
            unit: 'kg',
            previousSetLog: prevSet,
            canDelete: false,
            onDelete: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check that previous performance text is displayed
      expect(find.textContaining('السابق: 95 kg × 8'), findsOneWidget);

      // Tap on the copy pill
      await tester.tap(find.textContaining('السابق: 95 kg × 8'));
      await tester.pump();

      expect(weightCtrl.text, equals('95'));
      expect(repsCtrl.text, equals('8'));
    });
  });
}

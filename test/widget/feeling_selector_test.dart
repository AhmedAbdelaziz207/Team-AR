import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/features/workout_log/widgets/feeling_selector.dart';

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
  group('FeelingSelector Widget Tests', () {
    testWidgets('renders all 4 feeling options', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          FeelingSelector(
            selected: null,
            onSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إحساس الجلسة'), findsOneWidget);
      expect(find.text('سهل'), findsOneWidget);
      expect(find.text('متوسط'), findsOneWidget);
      expect(find.text('صعب'), findsOneWidget);
      expect(find.text('أقصى'), findsOneWidget);
    });

    testWidgets('calls onSelected with correct value when option is tapped', (tester) async {
      int? selectedValue;

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          FeelingSelector(
            selected: null,
            onSelected: (val) {
              selectedValue = val;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('متوسط'));
      await tester.pump();

      expect(selectedValue, equals(2));

      await tester.tap(find.text('أقصى'));
      await tester.pump();

      expect(selectedValue, equals(4));
    });
  });
}

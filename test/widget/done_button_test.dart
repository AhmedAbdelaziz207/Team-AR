import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/features/diet/widgets/done_button.dart';

Widget _wrapWithScreenUtil(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

void main() {
  group('DoneButton Widget Tests', () {
    testWidgets('renders "تم الأكل" when isDone is false', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          DoneButton(
            isDone: false,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تم الأكل'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('renders "مكتملة" when isDone is true', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          DoneButton(
            isDone: true,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مكتملة'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          DoneButton(
            isDone: false,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('تم الأكل'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}

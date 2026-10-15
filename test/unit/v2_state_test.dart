import 'package:flutter_test/flutter_test.dart';
import 'package:team_ar/features/diet_v2/logic/diet_dashboard_cubit.dart';
import 'package:team_ar/features/diet_v2/models/diet_plan_model.dart';
import 'package:team_ar/features/diet_v2/models/meal_model.dart';
import 'package:team_ar/features/workout_v2/logic/focus_mode_cubit.dart';
import 'package:team_ar/features/workout_v2/models/workout_model.dart';

void main() {
  group('V2 State Logic Tests', () {
    test('FocusModeState formattedElapsedTime and restProgress calculations', () {
      final workout = WorkoutModel(
        id: 'w1',
        coachId: 'c1',
        traineeId: 't1',
        title: 'Push Day',
        targetMuscles: const ['Chest'],
        createdAt: DateTime.now(),
        exercises: const [],
      );

      // Under 1 hour
      final stateUnderHour = FocusModeState(
        workout: workout,
        elapsedSeconds: 125, // 2m 5s
        isRestTimerActive: true,
        restSecondsRemaining: 45,
        restTotalSeconds: 90,
      );

      expect(stateUnderHour.formattedElapsedTime, '02:05');
      expect(stateUnderHour.restProgress, 0.5);

      // Over 1 hour
      final stateOverHour = stateUnderHour.copyWith(
        elapsedSeconds: 3665, // 1h 1m 5s
        restSecondsRemaining: 90,
        restTotalSeconds: 90,
      );

      expect(stateOverHour.formattedElapsedTime, '01:01:05');
      expect(stateOverHour.restProgress, 1.0);
    });

    test('DietDashboardState macro sums and progress calculations', () {
      final meals = [
        const MealModel(
          id: 'm1',
          dietPlanId: 'dp1',
          mealType: 'breakfast',
          totalCalories: 500,
          totalProtein: 40,
          totalCarbs: 50,
          totalFats: 15,
          isConsumed: true,
        ),
        const MealModel(
          id: 'm2',
          dietPlanId: 'dp1',
          mealType: 'lunch',
          totalCalories: 800,
          totalProtein: 60,
          totalCarbs: 90,
          totalFats: 20,
          isConsumed: false,
        ),
      ];

      final plan = DietPlanModel(
        id: 'dp1',
        traineeId: 'user1',
        coachId: 'coach1',
        targetCalories: 2500,
        targetProtein: 180,
        targetCarbs: 280,
        targetFats: 70,
        waterTargetLiters: 4.0,
        createdAt: DateTime.now(),
        meals: meals,
      );

      final state = DietDashboardState(
        dietPlan: plan,
        waterConsumedLiters: 2.0,
      );

      // Only m1 is consumed
      expect(state.consumedCalories, 500.0);
      expect(state.consumedProtein, 40.0);
      expect(state.consumedCarbs, 50.0);
      expect(state.consumedFats, 15.0);

      // Remaining calories: 2500 - 500 = 2000
      expect(state.remainingCalories, 2000.0);
      expect(state.caloriesProgress, 0.2); // 500 / 2500

      // Water target is 4.0L, consumed is 2.0L => progress 0.5
      expect(state.waterProgress, 0.5);
    });
  });
}

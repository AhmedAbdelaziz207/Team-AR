import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/diet_plan_model.dart';
import '../repos/diet_repository_v2.dart';

class DietDashboardState {
  final DietPlanModel? dietPlan;
  final double waterConsumedLiters;
  final bool isLoading;
  final String? errorMessage;

  const DietDashboardState({
    this.dietPlan,
    this.waterConsumedLiters = 0.0,
    this.isLoading = false,
    this.errorMessage,
  });

  double get consumedCalories {
    if (dietPlan == null) return 0.0;
    return dietPlan!.meals
        .where((m) => m.isConsumed)
        .fold(0.0, (sum, m) => sum + m.totalCalories);
  }

  double get consumedProtein {
    if (dietPlan == null) return 0.0;
    return dietPlan!.meals
        .where((m) => m.isConsumed)
        .fold(0.0, (sum, m) => sum + m.totalProtein);
  }

  double get consumedCarbs {
    if (dietPlan == null) return 0.0;
    return dietPlan!.meals
        .where((m) => m.isConsumed)
        .fold(0.0, (sum, m) => sum + m.totalCarbs);
  }

  double get consumedFats {
    if (dietPlan == null) return 0.0;
    return dietPlan!.meals
        .where((m) => m.isConsumed)
        .fold(0.0, (sum, m) => sum + m.totalFats);
  }

  double get remainingCalories {
    if (dietPlan == null) return 0.0;
    final rem = dietPlan!.targetCalories - consumedCalories;
    return rem > 0 ? rem : 0.0;
  }

  double get caloriesProgress {
    if (dietPlan == null || dietPlan!.targetCalories <= 0) return 0.0;
    return (consumedCalories / dietPlan!.targetCalories).clamp(0.0, 1.0);
  }

  double get waterProgress {
    if (dietPlan == null || dietPlan!.waterTargetLiters <= 0) return 0.0;
    return (waterConsumedLiters / dietPlan!.waterTargetLiters).clamp(0.0, 1.0);
  }

  DietDashboardState copyWith({
    DietPlanModel? dietPlan,
    double? waterConsumedLiters,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DietDashboardState(
      dietPlan: dietPlan ?? this.dietPlan,
      waterConsumedLiters: waterConsumedLiters ?? this.waterConsumedLiters,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class DietDashboardCubit extends Cubit<DietDashboardState> {
  final DietRepositoryV2 _repo;

  DietDashboardCubit(this._repo) : super(const DietDashboardState());

  Future<void> loadDietDashboard(String traineeId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final plan = await _repo.getDietPlanForTrainee(traineeId);
      emit(state.copyWith(
        isLoading: false,
        dietPlan: plan,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر تحميل خطة التغذية: $e',
      ));
    }
  }

  Future<void> toggleMeal(String traineeId, String mealId, bool isConsumed) async {
    if (state.dietPlan == null) return;

    // تحديث فوري وسريع في الواجهة
    final updatedMeals = state.dietPlan!.meals.map((m) {
      if (m.id == mealId) {
        return m.copyWith(isConsumed: isConsumed);
      }
      return m;
    }).toList();

    emit(state.copyWith(
      dietPlan: state.dietPlan!.copyWith(meals: updatedMeals),
    ));

    // مزامنة مع Supabase في الخلفية
    await _repo.toggleMealConsumed(
      mealId: mealId,
      traineeId: traineeId,
      isConsumed: isConsumed,
    );
  }

  void addWater(double liters) {
    final updated = (state.waterConsumedLiters + liters).clamp(0.0, 10.0);
    emit(state.copyWith(waterConsumedLiters: updated));
  }
}

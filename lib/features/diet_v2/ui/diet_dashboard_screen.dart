import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import '../logic/diet_dashboard_cubit.dart';
import '../models/diet_plan_model.dart';
import '../models/meal_ingredient_model.dart';
import '../models/meal_model.dart';
import '../repos/diet_repository_v2.dart';

class DietDashboardScreen extends StatelessWidget {
  final String? userId;

  const DietDashboardScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = DietDashboardCubit(getIt<DietRepositoryV2>());
        _initTrainee(cubit);
        return cubit;
      },
      child: const _DietDashboardContent(),
    );
  }

  void _initTrainee(DietDashboardCubit cubit) async {
    final effectiveId =
        userId ?? await SharedPreferencesHelper.getString(AppConstants.userId);
    cubit.loadDietDashboard(effectiveId ?? 'test_trainee');
  }
}

class _DietDashboardContent extends StatefulWidget {
  const _DietDashboardContent();

  @override
  State<_DietDashboardContent> createState() => _DietDashboardContentState();
}

class _DietDashboardContentState extends State<_DietDashboardContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
  final List<String> _mealLabels = ['الفطار', 'الغداء', 'العشاء', 'سناك'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _mealTypes.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102E50),
        elevation: 0,
        leading: const AppBarBackButton(color: Colors.white),
        title: Text(
          'خطة التغذية والماكروز اليومية',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<DietDashboardCubit, DietDashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF102E50)),
            );
          }

          if (state.errorMessage != null && state.dietPlan == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restaurant_menu_rounded,
                        color: Colors.grey[400], size: 48.sp),
                    SizedBox(height: 12.h),
                    Text(
                      'لا توجد خطة غذائية نشطة اليوم',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF102E50),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'سيقوم المدرب بتعيين الماكروز والوجبات الخاصة بك قريباً',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final plan = state.dietPlan;
          if (plan == null) {
            return const Center(child: Text('لا توجد بيانات'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Daily Macros Dashboard Card
                _DailyMacrosDashboardCard(state: state, plan: plan),

                SizedBox(height: 14.h),

                // 2. Water Intake Tracker Card
                _WaterIntakeCard(
                  consumed: state.waterConsumedLiters,
                  target: plan.waterTargetLiters,
                  progress: state.waterProgress,
                  onAddWater: (val) =>
                      context.read<DietDashboardCubit>().addWater(val),
                ),

                SizedBox(height: 18.h),

                // 3. Tabbed Meals Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.15)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF102E50),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF102E50),
                    unselectedLabelColor: Colors.grey[500],
                    labelStyle: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                    ),
                    tabs: _mealLabels.map((l) => Tab(text: l)).toList(),
                  ),
                ),

                SizedBox(height: 14.h),

                // 4. TabBarView for Active Meal
                SizedBox(
                  height: 380.h,
                  child: TabBarView(
                    controller: _tabController,
                    children: _mealTypes.map((type) {
                      final meal = plan.meals.firstWhere(
                        (m) => m.mealType.toLowerCase() == type,
                        orElse: () => MealModel(
                          id: '',
                          dietPlanId: plan.id,
                          mealType: type,
                          totalCalories: 0,
                          totalProtein: 0,
                          totalCarbs: 0,
                          totalFats: 0,
                        ),
                      );

                      if (meal.id.isEmpty) {
                        return Center(
                          child: Text(
                            'لم يتم تحديد وجبة لهذا القسم',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        );
                      }

                      return _MealDetailsCard(
                        meal: meal,
                        onToggleConsumed: (val) async {
                          final userId =
                              await SharedPreferencesHelper.getString(
                                  AppConstants.userId);
                          if (context.mounted) {
                            context.read<DietDashboardCubit>().toggleMeal(
                                  userId ?? 'test_trainee',
                                  meal.id,
                                  val,
                                );
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DailyMacrosDashboardCard extends StatelessWidget {
  final DietDashboardState state;
  final DietPlanModel plan;

  const _DailyMacrosDashboardCard({
    required this.state,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Plan type and Calories remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.planType,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF102E50),
                    ),
                  ),
                  Text(
                    'المتبقي لليوم: ${state.remainingCalories.toInt()} kcal',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              // Calories Circle Summary
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF102E50).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Text(
                      '${state.consumedCalories.toInt()} / ${plan.targetCalories.toInt()}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF102E50),
                      ),
                    ),
                    Text(
                      'سعرة حرارية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Calories Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: state.caloriesProgress,
              minHeight: 8.h,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF102E50)),
            ),
          ),

          SizedBox(height: 16.h),

          // Macros Row: Protein, Carbs, Fats
          Row(
            children: [
              Expanded(
                child: _macroItem(
                  label: 'البروتين',
                  consumed: state.consumedProtein,
                  target: plan.targetProtein,
                  unit: 'g',
                  color: const Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _macroItem(
                  label: 'الكارب',
                  consumed: state.consumedCarbs,
                  target: plan.targetCarbs,
                  unit: 'g',
                  color: const Color(0xFFF59E0B),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _macroItem(
                  label: 'الدهون',
                  consumed: state.consumedFats,
                  target: plan.targetFats,
                  unit: 'g',
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroItem({
    required String label,
    required double consumed,
    required double target,
    required String unit,
    required Color color,
  }) {
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '${consumed.toInt()} / ${target.toInt()} $unit',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF102E50),
            ),
          ),
          SizedBox(height: 4.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4.h,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterIntakeCard extends StatelessWidget {
  final double consumed;
  final double target;
  final double progress;
  final ValueChanged<double> onAddWater;

  const _WaterIntakeCard({
    required this.consumed,
    required this.target,
    required this.progress,
    required this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.water_drop_rounded,
                color: const Color(0xFF0284C7), size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'استهلاك الماء اليومي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF102E50),
                      ),
                    ),
                    Text(
                      '${consumed.toStringAsFixed(1)} / ${target.toStringAsFixed(1)} L',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6.h,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          // +250ml quick add button
          ElevatedButton(
            onPressed: () => onAddWater(0.25),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            child: Text(
              '+250ml',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealDetailsCard extends StatelessWidget {
  final MealModel meal;
  final ValueChanged<bool> onToggleConsumed;

  const _MealDetailsCard({
    required this.meal,
    required this.onToggleConsumed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Meal Header: Calories & Logged Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${meal.totalCalories.toInt()} سعرة حرارية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF102E50),
                    ),
                  ),
                  Text(
                    'بروتين: ${meal.totalProtein.toInt()}g • كارب: ${meal.totalCarbs.toInt()}g • دهون: ${meal.totalFats.toInt()}g',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              // Consumed Status Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: meal.isConsumed
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  meal.isConsumed ? 'تم التناول ✅' : 'قيد الانتظار',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: meal.isConsumed
                        ? const Color(0xFF10B981)
                        : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 20, color: Color(0xFFEEEEEE)),

          // Ingredients List
          Expanded(
            child: meal.ingredients.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد مكونات مسجلة لهذه الوجبة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: meal.ingredients.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final ing = meal.ingredients[index];
                      return _IngredientTile(ingredient: ing);
                    },
                  ),
          ),

          SizedBox(height: 12.h),

          // "سجل الوجبة" Toggle Button
          SizedBox(
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: () => onToggleConsumed(!meal.isConsumed),
              icon: Icon(
                meal.isConsumed
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              label: Text(
                meal.isConsumed ? 'إلغاء تسجيل الوجبة' : 'سجل الوجبة (تم الأكل) 💪',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: meal.isConsumed
                    ? Colors.grey[700]
                    : const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final MealIngredientModel ingredient;

  const _IngredientTile({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_rounded,
                  color: const Color(0xFF102E50), size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                ingredient.name,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF102E50),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                ingredient.quantityUnit,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${ingredient.calories.toInt()} cal',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

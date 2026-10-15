import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/services/pdf_protection_service.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/diet/logic/meal_confirmation_cubit.dart';
import 'package:team_ar/features/diet/logic/meal_confirmation_state.dart';
import 'package:team_ar/features/diet/logic/user_diet_cubit.dart';
import 'package:team_ar/features/diet/logic/user_diet_state.dart';
import 'package:team_ar/features/diet/model/user_diet.dart';
import 'package:team_ar/features/diet/ui/meal_reminder_settings_screen.dart';
import 'package:team_ar/features/diet/widgets/meal_list.dart';

class UserDietScreen extends StatelessWidget {
  const UserDietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MealConfirmationCubit>()..loadStatus(),
      child: const _UserDietView(),
    );
  }
}

class _UserDietView extends StatefulWidget {
  const _UserDietView();

  @override
  State<_UserDietView> createState() => _UserDietViewState();
}

class _UserDietViewState extends State<_UserDietView> {
  Set<int> _presentMealIds = {};

  @override
  void initState() {
    super.initState();
    PdfProtectionService.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserDietCubit>().loadCachedDiet().then((_) {
        if (mounted) {
          context.read<UserDietCubit>().getUserDiet();
        }
      });
    });
  }

  @override
  void dispose() {
    PdfProtectionService.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: BlocBuilder<MealConfirmationCubit, MealConfirmationState>(
          builder: (context, mState) {
            if (mState.streak <= 0) return const SizedBox.shrink();
            return Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 4.w),
                    Text(
                      '${mState.streak}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.orange[300],
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        title: Text(
          AppLocalKeys.yourDietPlan.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm_rounded, color: Colors.white),
            tooltip: 'مواعيد التذكير',
            onPressed: () {
              final cubit = context.read<MealConfirmationCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: MealReminderSettingsScreen(
                      presentMealIds: _presentMealIds,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<UserDietCubit>().getUserDiet();
            await context.read<MealConfirmationCubit>().loadStatus(
                  presentMealIds: _presentMealIds,
                );
          },
          child: BlocConsumer<UserDietCubit, UserDietState>(
            listener: (context, state) {
              state.maybeWhen(
                success: (diet) {
                  final mealIds =
                      diet.map((e) => e.foodType).whereType<int>().toSet();
                  _presentMealIds = mealIds;
                  context.read<MealConfirmationCubit>().loadStatus(
                        presentMealIds: mealIds,
                      );
                },
                orElse: () {},
              );
            },
            builder: (context, state) {
              return state.maybeMap(
                orElse: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF102E50)),
                ),
                loading: (value) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF102E50)),
                ),
                success: (value) {
                  final userDietList = value.diet;

                  if (userDietList.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      children: [
                        SizedBox(height: 60.h),
                        Image.asset(AppAssets.hungry),
                        Center(
                          child: Text(
                            AppLocalKeys.noMeals.tr(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22.sp,
                              fontFamily: "Cairo",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Group meals by foodType
                  final Map<int, List<UserDiet>> grouped = {};
                  for (var diet in userDietList) {
                    if (diet.foodType == null) continue;
                    grouped.putIfAbsent(diet.foodType!, () => []).add(diet);
                  }

                  // Total calories
                  final num totalDayCalories = userDietList
                      .map((e) => e.meal?.numOfCalories ?? 0)
                      .fold(0, (sum, cal) => sum + cal);

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        // بطاقة إجمالي السعرات + شريط إنجاز الوجبات
                        if (grouped.isNotEmpty)
                          BlocBuilder<MealConfirmationCubit,
                              MealConfirmationState>(
                            builder: (context, mState) {
                              final totalMeals = grouped.keys.length;
                              final completedCount = grouped.keys
                                  .where((k) => mState.isMealDone(k))
                                  .length;
                              final progress = totalMeals > 0
                                  ? completedCount / totalMeals
                                  : 0.0;

                              return Container(
                                width: double.infinity,
                                margin: EdgeInsets.all(15.0.sp),
                                padding: EdgeInsets.all(16.0.sp),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF102E50),
                                      Color(0xFF1A4570),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF102E50)
                                          .withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.local_fire_department_rounded,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              AppLocalKeys.totalDailyCalories
                                                  .tr(),
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Cairo",
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "$totalDayCalories ${AppLocalKeys.calories.tr()}",
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Cairo",
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    // شريط تقدم الوجبات
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "إنجاز اليوم: $completedCount من $totalMeals وجبات",
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontFamily: "Cairo",
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "${(progress * 100).toInt()}%",
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontFamily: "Cairo",
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6.h),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6.r),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 6.h,
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.2),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          progress == 1.0
                                              ? const Color(0xFF10B981)
                                              : Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                        // قائمة مجموعات الوجبات
                        ...grouped.entries.map((entry) {
                          return MealsList(userDiet: entry.value);
                        }),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  );
                },
                failure: (value) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  children: [
                    SizedBox(height: 120.h),
                    Center(
                      child: Text(
                        value.errorMessage.message ??
                            AppLocalKeys.unexpectedError.tr(),
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.sp,
                          fontFamily: "Cairo",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

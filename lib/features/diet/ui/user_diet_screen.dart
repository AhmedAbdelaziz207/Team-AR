import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/diet/logic/user_diet_state.dart';
import 'package:team_ar/features/diet/widgets/meal_list.dart';
import 'package:team_ar/core/services/pdf_protection_service.dart';
import '../logic/user_diet_cubit.dart';
import '../model/user_diet.dart';

class UserDietScreen extends StatefulWidget {
  const UserDietScreen({super.key});

  @override
  State<UserDietScreen> createState() => _UserDietScreenState();
}

class _UserDietScreenState extends State<UserDietScreen> {
  @override
  void initState() {
    super.initState();
    PdfProtectionService.enable();
    // استدعاء الدوال في إطار ما بعد العرض الأول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserDietCubit>().loadCachedDiet().then((_) {
        // Always fetch from network to guarantee fresh data
        context.read<UserDietCubit>().getUserDiet();
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.h),
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: const SizedBox(),
          title: Text(
            AppLocalKeys.yourDietPlan.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
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
          onRefresh: () async => context.read<UserDietCubit>().getUserDiet(),
          child: BlocBuilder<UserDietCubit, UserDietState>(
            builder: (context, state) {
              return state.maybeMap(
                orElse: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                loading: (value) => const Center(
                  child: CircularProgressIndicator(),
                ),
                success: (value) {
                  final userDietList = value.diet;

                  // Return empty if null or empty
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
                    grouped
                        .putIfAbsent(diet.foodType!, () => [])
                        .add(diet);
                  }

                  // Calculate total calories from all meals
                  final num totalDayCalories = userDietList
                      .map((e) => e.meal?.numOfCalories ?? 0)
                      .fold(0, (sum, cal) => sum + cal);

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        // Display total calories at the top of first meal
                        if (grouped.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.all(15.0.sp),
                            padding: EdgeInsets.all(16.0.sp),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalKeys.totalDailyCalories.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Cairo",
                                    color: Colors.green[700],
                                  ),
                                ),
                                Text(
                                  "$totalDayCalories ${AppLocalKeys.calories.tr()}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Cairo",
                                    color: Colors.green[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Display meal groups
                        ...grouped.entries.map((entry) {
                          return MealsList(userDiet: entry.value);
                        }),
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

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/diet/logic/user_diet_state.dart';
import 'package:team_ar/features/diet/widgets/meal_list.dart';
import '../../manage_meals_screen/model/meal_model.dart';
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
    context.read<UserDietCubit>().getUserDiet();
    super.initState();
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
      body: BlocBuilder<UserDietCubit, UserDietState>(
        builder: (context, state) {
          return state is UserDietLoading
              ? const Center(child: CircularProgressIndicator())
              : DraggableScrollableSheet(
                  expand: true,
                  minChildSize: .8,
                  initialChildSize: .9,
                  builder: (context, controller) {
                    return BlocBuilder<UserDietCubit, UserDietState>(
                      builder: (context, state) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              topRight: Radius.circular(20.r),
                            ),
                          ),
                          child: state.maybeMap(
                            orElse: () => const Text("Not found "),
                            // success: (value) => value.diet.isEmpty
                            //     ?  Center(
                            //         child: Text(
                            //       AppLocalKeys.noMeals.tr(),
                            //       style: TextStyle(
                            //         color: AppColors.black,
                            //         fontSize: 20.sp,
                            //         fontWeight: FontWeight.bold,
                            //         fontFamily: "Cairo",
                            //       ),
                            //         ))
                            success: (value) {
                              final userDietList = value.diet;

                              // Return empty if null or empty
                              if (userDietList == null ||
                                  userDietList.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              // Group meals by foodType
                              final Map<int, List<UserDiet>> grouped = {};

                              for (var diet in userDietList) {
                                if (diet.foodType == null) continue;
                                grouped
                                    .putIfAbsent(diet.foodType!, () => [])
                                    .add(diet);
                              }

                              return SingleChildScrollView(
                                child: Column(
                                  children: grouped.entries.map((entry) {
                                    return MealsList(userDiet: entry.value);
                                  }).toList(),
                                ),
                              );
                            },

                            failure: (value) => Center(
                              child: Text(
                                value.errorMessage.message ??
                                    AppLocalKeys.unexpectedError.tr(),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}

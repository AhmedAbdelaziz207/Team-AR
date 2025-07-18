import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/core/widgets/plans_list_card.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_cubit.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_state.dart';
import 'package:team_ar/features/plans_screen/widget/plans_list.dart';
import '../../core/theme/app_colors.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String title = "مع ك.احمد رمضان شخصيا";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    Future.microtask(() {
      if (mounted) {
        context.read<UserPlansCubit>().getUserPlans();
      }
    });
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        title = _tabController.index == 0
            ? "مع ك.احمد رمضان شخصيا"
            : "مع احد مدربين التيم ";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.white,
        leading: const AppBarBackButton(),
        title: Text(
          AppLocalKeys.plans.tr(),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: AppColors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 21.sp,
                  ),
            ),
            SizedBox(height: 8.h),
            TabBar(
              unselectedLabelStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontSize: 16.sp, color: AppColors.secondaryColor),
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.newPrimaryColor,
                borderRadius: BorderRadius.circular(30.r),
              ),
              indicatorWeight: 0,
              labelStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontSize: 16.sp),
              labelColor: AppColors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                const Tab(text: "VIP"),
                Tab(text: AppLocalKeys.normal.tr()),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<UserPlansCubit, UserPlansState>(
              builder: (context, state) {
                if (state is UserPlansLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is UserPlansLoaded) {
                  final vipPlans = state.plans
                      .where((plan) => plan.packageType?.toLowerCase() == "vip")
                      .toList();
                  final normalPlans = state.plans
                      .where((plan) => plan.packageType?.toLowerCase() != "vip")
                      .toList();

                  return Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        PlansList(plans: vipPlans), // VIP Plans
                        PlansList(plans: normalPlans), // Normal Plans
                      ],
                    ),
                  );
                }
                if (state is UserPlansFailure) {
                  return const Center(
                    child: Text("Error"),
                  );
                }
                return const SizedBox();
              },
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/plans_screen/widget/plans_list_item.dart';
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
  String title = "";
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        title = _tabController.index == 0 ?  "مع ك.احمد رمضان شخصيا":"مع احد مدربين التيم ";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const AppBarBackButton(),
        title: Text(
          AppLocalKeys.plans.tr(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Column(
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
              color: AppColors.primaryColor,
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                PlansList()
            
            
                ,
                PlansList()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

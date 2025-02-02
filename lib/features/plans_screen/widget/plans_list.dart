import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_cubit.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_state.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';
import 'package:team_ar/features/plans_screen/widget/plans_list_item.dart';

class PlansList extends StatelessWidget {
  const PlansList({super.key, required this.plans});
  final List<UserPlan> plans;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: plans.length,
      itemBuilder: (context, index) {
        return SubscriptionCard(plan: plans[index]);
      },
    );
  }


}

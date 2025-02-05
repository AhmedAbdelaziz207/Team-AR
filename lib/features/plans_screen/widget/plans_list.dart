import 'package:flutter/material.dart';
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
        return PlansListItem(plan: plans[index]);
      },
    );
  }


}

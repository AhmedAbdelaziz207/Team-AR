import 'package:flutter/material.dart';
import 'package:team_ar/features/plans_screen/widget/plans_list_item.dart';

class PlansList extends StatelessWidget {
  const PlansList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => const SubscriptionCard(),
    );
  }
}

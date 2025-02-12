import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/widgets/status_badge.dart';
import '../../home/admin/data/trainee_model.dart';

class SubscribedUserCard extends StatelessWidget {
  const SubscribedUserCard({super.key, required this.trainer});
  final TraineeModel trainer;


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage:
              NetworkImage(trainer.image ?? AppConstants.avatarUrl2),
              radius: 24,
            ),
            const SizedBox(width: 10),
            Text(
              trainer.userName??"",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Text(trainer.phone ?? "0103090711",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        StatusBadge(
          status: trainer.status ?? "Active",
        ),
      ],
    );
  }
}

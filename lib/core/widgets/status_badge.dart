import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status == AppLocalKeys.active.tr() ? Colors.green[100] : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: status == AppLocalKeys.active.tr() ? Colors.green : Colors.grey,
          fontWeight: FontWeight.bold,
          fontFamily: "Cairo",
        ),
      ),
    );
  }
}
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/app_local_keys.dart';

class UsersTableHeader extends StatelessWidget {
  const UsersTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalKeys.trainee.tr(),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          AppLocalKeys.phone.tr(),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          AppLocalKeys.status.tr(),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

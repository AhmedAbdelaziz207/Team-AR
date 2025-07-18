import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/widgets/status_badge.dart';
import '../../home/admin/data/trainee_model.dart';

class SubscribedUserCard extends StatelessWidget {
  const SubscribedUserCard({
    super.key,
    required this.trainer,
  });

  final TraineeModel trainer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.userInfo,
          arguments: trainer,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: trainer.image == null
                    ? const AssetImage(
                        AppAssets.avatar,
                      )
                    : NetworkImage(
                        ApiEndPoints.usersImagesBaseUrl + trainer.image!,
                      ),
                radius: 24,
              ),
              const SizedBox(width: 10),
              Text(
                trainer.userName ?? "",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Text(
            trainer.phone ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          StatusBadge(
            status: trainer.remindDays! > 0
                ? AppLocalKeys.active.tr()
                : AppLocalKeys.expired.tr(),
          ),
        ],
      ),
    );
  }
}

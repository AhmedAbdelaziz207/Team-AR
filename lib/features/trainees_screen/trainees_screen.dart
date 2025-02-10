import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/admin_panal/widget/admin_user_card.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';

import '../../core/utils/app_local_keys.dart';

class TraineesScreen extends StatelessWidget {
  const TraineesScreen({super.key, required this.trainees});

  final List<TraineeModel> trainees;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppColors.white,
      appBar: AppBar(
        backgroundColor:  AppColors.white,
        leading: const AppBarBackButton() ,
        title: Text(
          AppLocalKeys.subscribedUsers.tr(),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontSize: 21.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemBuilder: (context, index) =>
                AdminUserCard(trainee: trainees[index]),
            itemCount: trainees.length,
          ),
        ),
      ),
    );
  }
}

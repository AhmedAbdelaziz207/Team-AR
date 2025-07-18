import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/features/home/admin/logic/trainees_cubit.dart';
import 'package:team_ar/features/home/admin/logic/trainees_state.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';
import 'admin_user_card.dart';

class SubscribedUsersSection extends StatefulWidget {
  const SubscribedUsersSection({super.key});

  @override
  State<SubscribedUsersSection> createState() => _SubscribedUsersSectionState();
}

class _SubscribedUsersSectionState extends State<SubscribedUsersSection> {
  @override
  void initState() {
    context.read<TraineeCubit>().getAllTrainees();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TraineeCubit, TraineeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppLocalKeys.subscribedUsers.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    final trainees =
                        state is TraineeSuccess ? state.trainees : [];
                    Navigator.pushNamed(context, Routes.adminTraineesScreen,
                        arguments: trainees);
                  },
                  child: Text(
                    AppLocalKeys.seeAll.tr(),
                    style: const TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            state.whenOrNull(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  success: (trainees) => SizedBox(
                    height: 100.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: trainees.length,
                      itemBuilder: (context, index) => AdminUserCard(
                        trainee: trainees[index],
                      ),
                      separatorBuilder: (context, index) => const SizedBox(
                        width: 16,
                      ),
                    ),
                  ),
                  failure: (error) => Center(
                    child: Text(error),
                  ),
                ) ??
                const SizedBox(),
          ],
        );
      },
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/home/admin/logic/trainees_cubit.dart';
import 'package:team_ar/features/home/admin/logic/trainees_state.dart';
import 'package:team_ar/features/users_management/widget/user_status_card.dart';
import 'package:team_ar/features/users_management/widget/users_table.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bar_back_button.dart';

class UsersAboutToExpireScreen extends StatefulWidget {
  const UsersAboutToExpireScreen({super.key});

  @override
  State<UsersAboutToExpireScreen> createState() =>
      _UsersAboutToExpireScreenState();
}

class _UsersAboutToExpireScreenState extends State<UsersAboutToExpireScreen> {
  @override
  void initState() {
    context.read<TraineeCubit>().getUsersAboutToExpired();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: const AppBarBackButton(),
        title: Text(
          AppLocalKeys.usersAboutToExpire.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontSize: 21.sp,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<TraineeCubit, TraineeState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<TraineeCubit>().getUsersAboutToExpired(),
              child: Column(
                children: [
                  const UsersTable(),

                  SizedBox(
                    height: 16.h,
                  ),
                  if (state is TraineeLoading) const LinearProgressIndicator(),
                  if (state is TraineeSuccess && state.trainees.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.trainees.length,
                        itemBuilder: (context, index) => InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.userInfo,
                              arguments: state.trainees[index],
                            );
                          },
                          child: UserStatusCard(
                            firstName: state.trainees[index].userName ?? "",
                            isActive: state.trainees[index].remindDays! > 0,
                            currentDays: state.trainees[index].remindDays!,
                          ),
                        ),
                      ),
                    ),
                  if (state is TraineeSuccess && state.trainees.isEmpty)
                    Center(
                      child: Text(
                        AppLocalKeys.noUsers.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                              fontSize: 21.sp,
                            ),
                      ),
                    ),
                  if (state is TraineeFailure)
                    Center(
                      child: Text(
                        state.errorMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.red,
                              fontSize: 21.sp,
                            ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

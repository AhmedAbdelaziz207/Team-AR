import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/widgets/plans_list_card.dart';
import 'package:team_ar/features/manage_plans/widget/plans_dialog.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_state.dart';
import '../../../core/utils/app_local_keys.dart';
import '../../../core/widgets/app_bar_back_button.dart';
import '../../plans_screen/logic/user_plans_cubit.dart';

class ManagePlansScreen extends StatefulWidget {
  const ManagePlansScreen({super.key});

  @override
  State<ManagePlansScreen> createState() => _ManagePlansScreenState();
}

class _ManagePlansScreenState extends State<ManagePlansScreen> {


  @override
  void initState() {
    getData();
    super.initState();
  }


  void getData() {
    context.read<UserPlansCubit>().getUserPlans();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar:  AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading:  const AppBarBackButton(),
        title: Text(
          AppLocalKeys.managePlans.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontSize: 21.sp,
              ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            getData();
          },
          child: Column(
            children: [
              SizedBox(height: 12.h),
              BlocBuilder<UserPlansCubit, UserPlansState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    plansLoading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    plansLoaded: (plans) => Expanded(
                      /// TODO: fix Delete Bug here
                      child: ListView.builder(
                        itemCount: plans.length,
                        itemBuilder: (context, index) => Dismissible(
                          onDismissed: (direction) {
                            context.read<UserPlansCubit>().deletePlan(
                                  plans[index].id!,
                                );
                            // plans.removeAt(index);
                          },
                          key: Key(plans[index].id.toString()),
                          child: PlansListCard(
                            plan: plans[index],
                            isAdmin: true,
                          ),
                        ),
                      ),
                    ),
                    plansFailure: (messageModel) => Center(
                      child: Center(
                        child: Text(
                          messageModel.message.toString(),
                          style: const TextStyle(color: AppColors.red),
                        ),
                      ),
                    ),
                    orElse: () {
                      return const SizedBox();
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showPlanDialog(context),
        backgroundColor: AppColors.mediumLavender,
        child: const Icon(
          Icons.add,
          color: AppColors.white,
        ),
      ),
    );
  }
}

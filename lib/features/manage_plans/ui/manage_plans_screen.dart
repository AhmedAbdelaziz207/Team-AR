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
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: const AppBarBackButton(),
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
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.newPrimaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.newPrimaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.newPrimaryColor, size: 24.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        "يمكنك تعديل الأسعار وتفاصيل الباقة بالنقر على زر التعديل، أو اسحب الكارت يمنياً/يساراً لحذف الباقة نهائياً.",
                        style: TextStyle(
                          color: AppColors.black.withOpacity(0.8),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              BlocBuilder<UserPlansCubit, UserPlansState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    plansLoading: () => const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.mediumLavender),
                      ),
                    ),
                    plansLoaded: (plans) {
                      if (plans.isEmpty) {
                        return Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.card_membership_rounded, size: 70.sp, color: Colors.grey[300]),
                                SizedBox(height: 12.h),
                                Text(
                                  "لا توجد باقات مضافة حالياً",
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 90.h, top: 4.h),
                          itemCount: plans.length,
                          itemBuilder: (context, index) => Dismissible(
                            key: Key(plans[index].id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.red[600],
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              alignment: AlignmentDirectional.centerEnd,
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocalKeys.delete.tr(),
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28.sp),
                                ],
                              ),
                            ),
                            onDismissed: (direction) {
                              context.read<UserPlansCubit>().deletePlan(
                                    plans[index].id!,
                                  );
                            },
                            child: PlansListCard(
                              plan: plans[index],
                              isAdmin: true,
                            ),
                          ),
                        ),
                      );
                    },
                    plansFailure: (messageModel) => Expanded(
                      child: Center(
                        child: Text(
                          messageModel.message.toString(),
                          style: TextStyle(color: AppColors.red, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    orElse: () => const SizedBox(),
                  );
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPlanDialog(context),
        backgroundColor: AppColors.mediumLavender,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
        icon: const Icon(
          Icons.add_circle_outline_rounded,
          color: AppColors.white,
        ),
        label: Text(
          "إضافة باقة جديدة",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}

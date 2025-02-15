
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_cubit.dart';
import 'package:team_ar/features/confirm_subscription/widget/confirm_subscription_form.dart';
import 'package:team_ar/features/plans_screen/widget/plans_list_item.dart';
import '../../core/utils/app_local_keys.dart';
import '../plans_screen/model/user_plan.dart';

class ConfirmSubscriptionScreen extends StatefulWidget {
  const ConfirmSubscriptionScreen({super.key, required this.userPlan});

  final UserPlan userPlan;

  @override
  State<ConfirmSubscriptionScreen> createState() =>
      _ConfirmSubscriptionScreenState();
}

class _ConfirmSubscriptionScreenState extends State<ConfirmSubscriptionScreen> {
  bool isSendImages = false;

  @override
  void initState() {
    context.read<ConfirmSubscriptionCubit>().userPlan = widget.userPlan;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        leading: const AppBarBackButton(),
        title: Text(
          AppLocalKeys.confirmSubscription.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 21.sp,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlansListItem(
                isSelected: true,
                plan: widget.userPlan,
              ),
              SizedBox(
                height: 16.h,
              ),
              Text(
                AppLocalKeys.enterYourInfo.tr(),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 18.sp),
              ),
              SizedBox(
                height: 4.h,
              ),
              Text(
                AppLocalKeys.forSubscription.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.lightGrey,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 21.h),
              const ConfirmSubscriptionForm(),
              SizedBox(
                height: 21.h,
              ),
              Row(
                children: [
                  Checkbox(
                    value: isSendImages,
                    onChanged: (value) {
                      isSendImages = value!;
                      context.read<ConfirmSubscriptionCubit>().isSendImages =
                          isSendImages;
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Expanded(
                    child: Text(
                      AppLocalKeys.sendBodyImages.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.lightGrey,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 21.h,
              ),
              Align(
                alignment: AlignmentDirectional.center,
                child: ElevatedButton(
                    onPressed: () {
                      // if (context
                      //         .read<ConfirmSubscriptionCubit>()
                      //         .formKey
                      //         .currentState!
                      //         .validate() &&
                      //     isSendImages) {
                      //   /// TODO: Navigate To Register Screen
                      //   log("✅ Navigate To Register Screen");
                      // }

                      Navigator.pushNamed(context, Routes.register);
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(150.w, 30.h),
                        backgroundColor:
                            AppColors.primaryColor.withOpacity(.8)),
                    child: Text(
                      AppLocalKeys.next.tr(),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.white,
                              ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}

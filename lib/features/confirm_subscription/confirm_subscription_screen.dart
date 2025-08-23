import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_cubit.dart';
import 'package:team_ar/features/confirm_subscription/logic/confirm_subscription_state.dart';
import 'package:team_ar/features/confirm_subscription/widget/confirm_subscription_form.dart';
import 'package:team_ar/core/widgets/plans_list_card.dart';
import 'package:team_ar/features/confirm_subscription/widget/register_bloc_listener.dart';
import 'package:team_ar/features/payment/screens/payment_screen.dart';
import '../../core/prefs/shared_pref_manager.dart';
import '../../core/utils/app_constants.dart';
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
    final cubit = context.read<ConfirmSubscriptionCubit>();
    cubit.userPlan = widget.userPlan;
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
          AppLocalKeys.confirmSubscription.tr(),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontSize: 21.sp, color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlansListCard(
                isSelected: true,
                plan: widget.userPlan,
              ),
              SizedBox(
                height: 16.h,
              ),
              Text(
                AppLocalKeys.enterYourInfo.tr(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 18.sp,
                    ),
              ),
              SizedBox(
                height: 4.h,
              ),
              Text(
                AppLocalKeys.forSubscription.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.lightGrey,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              SizedBox(height: 21.h),
              const ConfirmSubscriptionForm(),
              SizedBox(
                height: 21.h,
              ),
              if (!context.read<ConfirmSubscriptionCubit>().isAdmin)
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
              BlocBuilder<ConfirmSubscriptionCubit, ConfirmSubscriptionState>(
                builder: (context, state) {
                  return Align(
                    alignment: AlignmentDirectional.center,
                    child: state is SubscriptionLoading
                        ? const CircularProgressIndicator()
                        : MaterialButton(
                            onPressed: () async {
                              final role =
                                  await SharedPreferencesHelper.getString(
                                      AppConstants.userRole);
                              // التحقق من صحة البيانات - إزالة شرط إرسال الصور الإجباري
                              if (context
                                  .read<ConfirmSubscriptionCubit>()
                                  .formKey
                                  .currentState!
                                  .validate()) {
                                final cubit =
                                    context.read<ConfirmSubscriptionCubit>();

                                if (role?.toLowerCase() == "admin") {
                                  // إذا كان المستخدم مسؤول، استخدم السلوك القديم
                                  cubit.subscribe();
                                } else {
                                  // توجيه المستخدم إلى صفحة تسجيل الدخول أولاً
                                  // حفظ بيانات المستخدم مؤقتاً
                                //   cubit.subscribe();
                                  final userData = {
                                    'name': cubit.nameController.text,
                                    'email': cubit.emailController.text,
                                    'phone': cubit.phoneController.text,
                                    'plan': widget.userPlan.toJson(),
                                  };

                                  // حفظ البيانات في التخزين المؤقت
                                  await SharedPreferencesHelper.setString(
                                      'temp_subscription_data',
                                      jsonEncode(userData));

                                  // إضافة هذا الكود لحفظ بيانات المستخدم الكاملة في temp_user
                                  final user = cubit.getUser();
                                  final userJson = jsonEncode(user.toJson());
                                  await SharedPreferencesHelper.setString(
                                      'temp_user', userJson);
                                  // حفظ نسخة احتياطية أيضًا
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString('temp_user', userJson);
                                  print('✅ تم حفظ temp_user بنجاح');

                                  // التوجيه إلى صفحة الدفع بدلاً من تسجيل الدخول
                                  Navigator.push(
                                    context,  
                                    MaterialPageRoute(
                                      builder: (context) => PaymentScreen(
                                        plan: widget.userPlan,
                                        customerName: cubit.nameController.text,
                                        customerEmail:
                                            cubit.emailController.text,
                                        customerPhone:
                                            cubit.phoneController.text,
                                        isNewUser:
                                            true, // مهم: تحديد أن هذا مستخدم جديد
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            color: AppColors.newPrimaryColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 60.w, vertical: 4.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              AppLocalKeys.subscribe.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                      color: AppColors.white, fontSize: 18.sp),
                            )),
                  );
                },
              ),
              const RegisterBlocListener()
            ],
          ),
        ),
      ),
    );
  }
}

void showComingSoonDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Coming Soon'),
          ],
        ),
        content: const Text(
          'This feature will be enabled for users soon. Stay tuned!',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    },
  );
}

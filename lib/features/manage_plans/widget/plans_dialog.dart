import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_cubit.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_state.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';
import 'package:team_ar/features/plans_screen/repos/user_plans_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';
import '../../../core/widgets/custom_text_form_field.dart';

showPlanDialog(context, {isForEdit = false, UserPlan? plan}) {
  TextEditingController nameController = TextEditingController();
  TextEditingController newPriceController = TextEditingController();
  TextEditingController oldPriceController = TextEditingController();
  String selectedPackageType = "VIP";
  String selectedDuration = "30";
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  if (isForEdit && plan != null) {
    nameController.text = plan.name ?? "";
    newPriceController.text = plan.newPrice?.toString() ?? "";
    oldPriceController.text = plan.oldPrice?.toString() ?? "";
    selectedPackageType = plan.packageType?.toLowerCase() ?? "vip";
    selectedDuration = plan.duration?.toString() ?? "30";
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    builder: (context) {
      return BlocProvider(
        create: (context) => UserPlansCubit(getIt<UserPlansRepository>()),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalKeys.addPlan.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  CustomTextFormField(
                    suffixIcon: Icons.person,
                    controller: nameController,
                    hintText: AppLocalKeys.planName.tr(),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  CustomTextFormField(
                    controller: oldPriceController,
                    hintText: AppLocalKeys.priceBeforeDiscount.tr(),
                    keyboardType: const TextInputType.numberWithOptions(),
                    suffixIcon: Icons.price_change,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  CustomTextFormField(
                    controller: newPriceController,
                    hintText: AppLocalKeys.priceAfterDiscount.tr(),
                    keyboardType: const TextInputType.numberWithOptions(),
                    suffixIcon: Icons.price_change,
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalKeys.planType.tr(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 8.h,
                            ),
                            DropdownMenu(
                              initialSelection: selectedPackageType.toLowerCase(),
                              inputDecorationTheme: InputDecorationTheme(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              dropdownMenuEntries: [
                                DropdownMenuEntry(
                                  label: AppLocalKeys.normal.tr(),
                                  value: "normal",
                                ),
                                DropdownMenuEntry(
                                  label: AppLocalKeys.vip.tr(),
                                  value: "vip",
                                ),
                              ],
                              onSelected: (value) {
                                selectedPackageType =
                                    value!.toLowerCase().toString();
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalKeys.duration.tr(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 8.h,
                            ),
                            DropdownMenu(
                              initialSelection:
                                  isForEdit ? selectedDuration : "30",
                              inputDecorationTheme: InputDecorationTheme(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              dropdownMenuEntries: [
                                DropdownMenuEntry(
                                  label: "1 ${AppLocalKeys.months.tr()}",
                                  value: "30",
                                ),
                                DropdownMenuEntry(
                                  label: "3 ${AppLocalKeys.months.tr()}",
                                  value: "90",
                                ),
                                DropdownMenuEntry(
                                  label: "6 ${AppLocalKeys.months.tr()}",
                                  value: "180",
                                ),
                                DropdownMenuEntry(
                                  label: "12 ${AppLocalKeys.months.tr()}",
                                  value: "365",
                                ),
                              ],
                              onSelected: (value) {
                                selectedDuration = value.toString();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: BlocBuilder<UserPlansCubit, UserPlansState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: () {
                            if (isForEdit) {
                              context.read<UserPlansCubit>().editPlan(
                                    UserPlan(
                                      id: plan?.id,
                                      isActive: true,
                                      packageType: selectedPackageType,
                                      duration: int.parse(selectedDuration),
                                      name: nameController.text,
                                      newPrice:
                                          int.parse(newPriceController.text),
                                      oldPrice:
                                          int.parse(oldPriceController.text),
                                    ),
                                  );
                            } else {
                              if (formKey.currentState!.validate()) {
                                context.read<UserPlansCubit>().addPlan(
                                      UserPlan(
                                        id: 0,
                                        isActive: true,
                                        packageType: selectedPackageType,
                                        duration: int.parse(selectedDuration),
                                        name: nameController.text,
                                        newPrice:
                                            int.parse(newPriceController.text),
                                        oldPrice:
                                            int.parse(oldPriceController.text),
                                      ),
                                    );
                              }
                            }
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppLocalKeys.save.tr(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 21.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

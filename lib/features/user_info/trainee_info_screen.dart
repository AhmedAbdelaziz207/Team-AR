import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/core/widgets/plans_list_card.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/home/user/logic/user_cubit.dart';
import 'package:team_ar/features/home/user/logic/user_state.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_cubit.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_state.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';
import 'package:team_ar/features/user_info/model/trainee_model.dart';
import 'package:team_ar/features/user_info/widget/floating_menu.dart';

class TraineeInfoScreen extends StatefulWidget {
  final TraineeModel? traineeModel;

  const TraineeInfoScreen({super.key, this.traineeModel});

  @override
  State<TraineeInfoScreen> createState() => _TraineeInfoScreenState();
}

class _TraineeInfoScreenState extends State<TraineeInfoScreen> {
  @override
  void initState() {
    context.read<UserCubit>().getUser(
          widget.traineeModel?.id ?? "",
        );
    context.read<UserPlansCubit>().getUserPlan(
          widget.traineeModel?.packageId ?? 0,
        );
    super.initState();
  }

  late TrainerModel trainee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          AppLocalKeys.traineeInfo.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const AppBarBackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(context, AppLocalKeys.plan.tr()),
                IconButton(
                    onPressed: () {
                      _showPlanSelectionBottomSheet(context);
                    },
                    icon: Icon(
                      Icons.replay_circle_filled,
                      color: AppColors.primaryColor,
                      size: 25.sp,
                    ))
              ],
            ),

            BlocBuilder<UserPlansCubit, UserPlansState>(
              builder: (context, state) {
                if (state is UserPlansLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return PlansListCard(
                  plan: state is UserPlansLoaded ? state.plans[0] : UserPlan(),
                  isSelected: true,
                  backgroundColor: AppColors.primaryColor,
                );
              },
            ),

            const Divider(
              thickness: 1,
            ),
            const SizedBox(height: 16),

            // Basic Info
            BlocConsumer<UserCubit, UserState>(
              buildWhen: (_, state) =>
                  state is UserLoading ||
                  state is UserFailure ||
                  state is UserSuccess,
              listener: (context, state) {
                if (state is UpdateUserSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      "تم تحديث البيانات بنجاح",
                      style: TextStyle(color: AppColors.white),
                    ),
                    backgroundColor: AppColors.primaryColor,
                  ));
                }
                if (state is UpdateUserFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      "لم يتم تحديث البيانات بنجاح",
                      style: TextStyle(color: AppColors.white),
                    ),
                    backgroundColor: AppColors.red,
                  ));
                }
              },
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is UserFailure) {
                  return Center(child: Text(state.errorMessage));
                }

                if (state is UserSuccess) {
                  // Map TraineeModel (basic user data) to TrainerModel used by UI
                  final user = state.userData;
                  trainee = TrainerModel(
                    id: user.id,
                    userName: user.userName,
                    age: user.age,
                    image: user.image,
                    address: user.address,
                    phone: user.phone,
                    email: user.email,
                    password: user.password,
                    long: user.long,
                    weight: user.weight,
                    dailyWork: user.dailyWork,
                    areYouSmoker: user.areYouSmoker,
                    aimOfJoin: user.aimOfJoin,
                    anyPains: user.anyPains,
                    allergyOfFood: user.allergyOfFood,
                    foodSystem: user.foodSystem,
                    numberOfMeals: user.numberOfMeals,
                    lastExercise: user.lastExercise,
                    anyInfection: user.anyInfection,
                    abilityOfSystemMoney: user.abilityOfSystemMoney,
                    numberOfDays: user.numberOfDays,
                    gender: user.gender,
                    startPackage: user.startPackage,
                    endPackage: user.endPackage,
                    packageId: user.packageId,
                    exerciseId: user.exerciseId?.toString(),
                    role: user.role,
                    imageURL: user.image,
                  );

                  log("Trainee: ${trainee.userName.toString()}");

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, "Basic Info"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoText(
                              AppLocalKeys.name.tr(),
                              trainee.userName ?? "",
                              context,
                            ),
                            _buildInfoText(AppLocalKeys.gender.tr(),
                                trainee.gender ?? "", context),
                            _buildInfoText(AppLocalKeys.age.tr(),
                                "${trainee.age ?? 0}", context),
                            _buildInfoText(AppLocalKeys.weight.tr(),
                                "${trainee.weight ?? 0} kg", context),
                          ],
                        ),
                      ),
                      const Divider(),

                      // Contact Info
                      _buildSectionTitle(context, "Contact"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoText(AppLocalKeys.phone.tr(),
                                trainee.phone ?? "", context),
                            _buildInfoText(AppLocalKeys.email.tr(),
                                trainee.email ?? "", context),
                            _buildInfoText(
                              AppLocalKeys.address.tr(),
                              trainee.address ?? "",
                              context,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),

                      // Lifestyle
                      _buildSectionTitle(context, "Lifestyle"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoText(AppLocalKeys.aboutYourWork.tr(),
                                trainee.dailyWork ?? "", context),
                            _buildInfoText(AppLocalKeys.areYouSmoking.tr(),
                                trainee.areYouSmoker ?? "", context),
                            _buildInfoText(
                              AppLocalKeys.lastTimeTrained.tr(),
                              trainee.lastExercise ?? "",
                              context,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),

                      // Nutrition
                      _buildSectionTitle(context, "Nutrition"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoText(AppLocalKeys.foodSystem.tr(),
                                trainee.foodSystem ?? "", context),
                            _buildInfoText(AppLocalKeys.numberOfMeals.tr(),
                                "${trainee.numberOfMeals ?? 0}", context),
                            _buildInfoText(
                              AppLocalKeys.allergyOfFood.tr(),
                              trainee.allergyOfFood ?? "",
                              context,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),

                      // Health & Goals
                      _buildSectionTitle(context, "Health & Goals"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildInfoText(AppLocalKeys.aimOfJoin.tr(),
                                trainee.aimOfJoin ?? "", context),
                            _buildInfoText(AppLocalKeys.haveAnyPain,
                                trainee.anyPains ?? "", context),
                            _buildInfoText(AppLocalKeys.haveInfection,
                                trainee.anyInfection ?? "", context),
                            _buildInfoText(
                              AppLocalKeys.numberOfDaysForTraining,
                              "${trainee.numberOfDays ?? 0}",
                              context,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserSuccess) {
            // Use the mapped trainee instance created in the main builder if available
            // Fallback to mapping here as well in case of rebuild differences
            final user = state.userData;
            final mappedTrainee = TrainerModel(
              id: user.id,
              userName: user.userName,
              age: user.age,
              image: user.image,
              address: user.address,
              phone: user.phone,
              email: user.email,
              password: user.password,
              long: user.long,
              weight: user.weight,
              gender: user.gender,
              startPackage: user.startPackage,
              endPackage: user.endPackage,
              packageId: user.packageId,
              exerciseId: user.exerciseId?.toString(),
              role: user.role,
              imageURL: user.image,
            );

            return FloatingMenu(
              trainee: mappedTrainee,
              exerciseId: widget.traineeModel?.exerciseId,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String? title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 6,
      ),
      child: Text(
        title!,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 21.sp,
              color: AppColors.primaryColor,
              fontFamily: "Cairo",
            ),
      ),
    );
  }

  Widget _buildInfoText(String? label, String? value, context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:  ",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    fontFamily: "Cairo",
                    fontSize: 16.sp,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              "$value",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.black,
                    fontSize: 16.sp,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanSelectionBottomSheet(BuildContext context) {
    final userCubit = context.read<UserCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => UserPlansCubit()..getUserPlans(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "اختر خطة جديدة",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Cairo",
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<UserPlansCubit, UserPlansState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () =>
                          const Center(child: Text("ابدأ بتحميل الخطط")),
                      plansLoading: () =>
                          const Center(child: CircularProgressIndicator()),
                      plansLoaded: (plans) => ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: plans.length,
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          return _buildPlanCard(context, plan, userCubit);
                        },
                      ),
                      plansFailure: (error) => Center(
                        child: Text(
                          "خطأ في تحميل الخطط: ${error.message}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      addingPlan: () =>
                          const Center(child: CircularProgressIndicator()),
                      planAdded: () =>
                          const Center(child: Text("تم إضافة الخطة")),
                      planDeleted: () =>
                          const Center(child: Text("تم حذف الخطة")),
                      planEdited: () =>
                          const Center(child: Text("تم تعديل الخطة")),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, UserPlan plan, UserCubit userCubit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _selectPlan(context, plan, userCubit),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.name ?? "خطة غير محددة",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Cairo",
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${plan.duration ?? 0} يوم",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (plan.oldPrice != null && plan.oldPrice! > 0) ...[
                    Text(
                      "${plan.oldPrice} جنيه",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    "${plan.newPrice ?? 0} جنيه",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectPlan(BuildContext context, UserPlan plan, UserCubit userCubit) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "تأكيد اختيار الخطة",
          style: TextStyle(fontFamily: "Cairo"),
        ),
        content: Text(
          "هل تريد تحديث اشتراك ${trainee.userName} إلى خطة ${plan.name}؟",
          style: const TextStyle(fontFamily: "Cairo"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalKeys.cancel.tr(),
              style: const TextStyle(fontFamily: "Cairo"),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              userCubit.updateUserPackage(trainee.id, plan.id);
            },
            child: Text(
              AppLocalKeys.ok.tr(),
              style:
                  const TextStyle(color: Colors.white, fontFamily: "Cairo"),
            ),
          ),
        ],
      ),
    );
  }

  void showUpdatePlanDialog(BuildContext context, Function onAccept) {
    showDialog(
      context: context,
      barrierDismissible: true, // Optional: prevent closing without action
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.refresh_rounded,
                  size: 48,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 12),
                const Text(
                  "تجديد الاشتراك",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Cairo",
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "هل تريد تجديد الاشتراك؟",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Cairo",
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(120.w, 50.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalKeys.cancel.tr(),
                          style: const TextStyle(
                            fontFamily: "Cairo",
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          onAccept();
                          Navigator.pop(context);
                        },
                        child: Text(
                          AppLocalKeys.ok.tr(),
                          style: const TextStyle(
                            fontFamily: "Cairo",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/network/dio_factory.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/core/widgets/app_confirm_dialog.dart';
import 'package:team_ar/core/widgets/custom_text_form_field.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/trainees_screen/widget/subscribed_user_card.dart';
import 'package:team_ar/features/trainees_screen/widget/users_table_header.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/home/admin/logic/trainees_cubit.dart';
import '../../core/utils/app_local_keys.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/features/home/admin/repos/trainees_repository.dart';

class TraineesScreen extends StatefulWidget {
  const TraineesScreen({super.key, required this.trainees});

  final List<TraineeModel> trainees;

  @override
  State<TraineesScreen> createState() => _TraineesScreenState();
}

class _TraineesScreenState extends State<TraineesScreen> {
  late List<TraineeModel> _allTrainees;
  List<TraineeModel> filteredTrainees = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allTrainees = List<TraineeModel>.from(widget.trainees);
    filteredTrainees = _allTrainees;
  }

  void _filterTrainees(String query) {
    setState(() {
      filteredTrainees = _allTrainees
          .where((trainee) =>
              (trainee.userName ?? "").toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _refreshTrainees() async {
    try {
      final response = await getIt<TraineesRepository>().getAllTrainees();
      response.whenOrNull(
        success: (trainees) {
          final normalUsers = trainees
              .where((user) => user.role?.toLowerCase() != 'admin')
              .toList();
          if (mounted) {
            setState(() {
              _allTrainees = normalUsers;
              _filterTrainees(searchController.text);
            });
          }
        },
      );
    } catch (e) {
      log("Error refreshing trainees: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FD),
      appBar: AppBar(
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        backgroundColor: Colors.white,
        leading: const AppBarBackButton(),
        centerTitle: false,
        title: Text(
          AppLocalKeys.subscribedUsers.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.newSecondaryColor,
              ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTrainees,
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CustomTextFormField(
                    controller: searchController,
                    hintText: AppLocalKeys.searchByName.tr(),
                    suffixIcon: Icons.search_rounded,
                    iconColor: AppColors.newSecondaryColor,
                    onChanged: _filterTrainees,
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: UsersTableHeader(totalCount: filteredTrainees.length),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: filteredTrainees.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        children: [
                          SizedBox(height: 80.h),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.newSecondaryColor
                                        .withOpacity(0.06),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.group_off_rounded,
                                    size: 60.sp,
                                    color: AppColors.grey,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  searchController.text.isNotEmpty
                                      ? "لا توجد نتائج بحث مطابقة"
                                      : AppLocalKeys.noResultsFounds.tr(),
                                  style: TextStyle(
                                    color: AppColors.black.withOpacity(0.7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.only(
                            left: 16.w, right: 16.w, bottom: 20.h, top: 4.h),
                        itemCount: filteredTrainees.length,
                        itemBuilder: (context, index) {
                          final trainee = filteredTrainees[index];
                          return Dismissible(
                            key: ValueKey("trainee_${trainee.id ?? trainee.userName ?? index}"),
                            direction: DismissDirection.horizontal,
                            confirmDismiss: (direction) async {
                              final confirmed = await showAppConfirmDialog(
                                context: context,
                                title: "حذف حساب المتدرب",
                                message:
                                    "هل أنت متأكد من رغبتك في حذف حساب المتدرب \"${trainee.userName ?? 'المتدرب'}\" نهائياً؟\n\nسيتم حذف جميع بياناته واشتراكاته وجداوله من النظام بشكل كامل.",
                                confirmText: "حذف الحساب",
                                cancelText: "إلغاء",
                              );
                              return confirmed == true;
                            },
                            onDismissed: (direction) {
                              final traineeToDelete = trainee;
                              setState(() {
                                _allTrainees.removeWhere((t) => t.id == traineeToDelete.id);
                                filteredTrainees.removeWhere((t) => t.id == traineeToDelete.id);
                              });
                              _deleteTraineeDirectly(traineeToDelete);
                            },
                            background: _buildDismissBackground(AlignmentDirectional.centerStart),
                            secondaryBackground: _buildDismissBackground(AlignmentDirectional.centerEnd),
                            child: SubscribedUserCard(
                              trainer: trainee,
                              onDeletedFromDetails: (id) {
                                if (id != null) {
                                  setState(() {
                                    _allTrainees.removeWhere((t) => t.id == id);
                                    filteredTrainees.removeWhere((t) => t.id == id);
                                  });
                                  try {
                                    context.read<TraineeCubit>().getAllTrainees();
                                  } catch (_) {}
                                }
                              },
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10.h),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(AlignmentDirectional alignment) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(16.r),
      ),
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_forever_rounded, color: Colors.white, size: 26.sp),
          SizedBox(width: 8.w),
          Text(
            "حذف",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTraineeDirectly(TraineeModel trainee) async {
    final String traineeName = trainee.userName ?? "المتدرب";
    final String? traineeId = trainee.id;

    if (traineeId == null || traineeId.isEmpty) return;
    final cleanId = traineeId.trim();

    try {
      final dio = await DioFactory.getDio();
      final response = await dio.delete(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.deleteUser}',
        queryParameters: {
          'id': cleanId,
          'Id': cleanId,
          'userId': cleanId,
          'UserId': cleanId,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 404) {
        if (mounted) {
          try {
            context.read<TraineeCubit>().getAllTrainees();
          } catch (_) {}

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("تم حذف حساب المتدرب \"$traineeName\" بنجاح"),
              backgroundColor: Colors.green[700],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("فشل حذف الحساب (كود: ${response.statusCode})"),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      }
    } catch (e) {
      log("Error deleting trainee: $e");
    }
  }
}

// Trainer Card Widget

// Status Badge

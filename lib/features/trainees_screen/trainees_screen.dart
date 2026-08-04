import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/core/widgets/custom_text_form_field.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/trainees_screen/widget/subscribed_user_card.dart';
import 'package:team_ar/features/trainees_screen/widget/users_table_header.dart';
import '../../core/utils/app_local_keys.dart';

class TraineesScreen extends StatefulWidget {
  const TraineesScreen({super.key, required this.trainees});

  final List<TraineeModel> trainees;

  @override
  State<TraineesScreen> createState() => _TraineesScreenState();
}

class _TraineesScreenState extends State<TraineesScreen> {
  List<TraineeModel> filteredTrainees = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredTrainees = widget.trainees;
  }

  void _filterTrainees(String query) {
    setState(() {
      filteredTrainees = widget.trainees
          .where((trainee) =>
              trainee.userName!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
      body: GestureDetector(
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20.r),
                            decoration: BoxDecoration(
                              color: AppColors.newSecondaryColor.withOpacity(0.06),
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
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 20.h, top: 4.h),
                      itemCount: filteredTrainees.length,
                      itemBuilder: (context, index) => SubscribedUserCard(
                        trainer: filteredTrainees[index],
                      ),
                      separatorBuilder: (context, index) => SizedBox(height: 10.h),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Trainer Card Widget

// Status Badge

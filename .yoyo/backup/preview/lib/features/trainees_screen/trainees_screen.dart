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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        leading: const AppBarBackButton(),
        title: Text(
          AppLocalKeys.subscribedUsers.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 21.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            children: [
              CustomTextFormField(
                controller: searchController,
                hintText: AppLocalKeys.searchByName.tr(),
                suffixIcon: Icons.search,
                iconColor: AppColors.primaryColor,
                onChanged: _filterTrainees,
              ),
              SizedBox(height: 30.h),
              const UsersTableHeader(),
              SizedBox(height: 12.h),
              Expanded(
                child: filteredTrainees.isEmpty
                    ? Center(child: Text(AppLocalKeys.noResultsFounds.tr()))
                    : ListView.separated(
                        itemBuilder: (context, index) => SubscribedUserCard(
                            trainer: filteredTrainees[index]),
                        itemCount: filteredTrainees.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 30.h),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Trainer Card Widget

// Status Badge

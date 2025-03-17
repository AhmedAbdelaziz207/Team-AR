import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/admin_panal/widget/admin_manage_card.dart';
import 'package:team_ar/features/admin_panal/widget/logout_button.dart';
import 'package:team_ar/features/admin_panal/widget/subscribed_users_section.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/prefs/shared_pref_manager.dart';
import '../../core/utils/app_constants.dart';
import '../home/admin/logic/trainees_cubit.dart';
import '../home/admin/repos/trainees_repository.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          AppLocalKeys.adminPanel.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 21.sp,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 24.h,
              ),
              BlocProvider(
                create: (context) => TraineeCubit(getIt<TraineesRepository>()),
                child: const SubscribedUsersSection(),
              ),
              SizedBox(height: 20.h),

              AdminManageCard(
                title: AppLocalKeys.manageFoods.tr(),
                cardColor: AppColors.lightBlue,
              ),
              SizedBox(height: 20.h),
              AdminManageCard(title: AppLocalKeys.plans.tr()),
              SizedBox(height: 20.h),
              const LanguageSelection(),
              SizedBox(height: 20.h),

              // logout button

              SizedBox(
                height: 50.h,
              ),

              const Align(
                alignment: Alignment.center,
                child: LogoutButton(),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageSelection extends StatefulWidget {
  const LanguageSelection({super.key});

  @override
  State<LanguageSelection> createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  String selectedLanguage = AppLocalKeys.english.tr();
  late String selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    selectedLanguageCode = await SharedPreferencesHelper.getString(
          AppConstants.language,
        ) ??
        AppConstants.languageEnglishCode; // Default to English

    setState(() {
      selectedLanguage = selectedLanguageCode == AppConstants.languageArabicCode
          ? AppLocalKeys.arabic.tr()
          : AppLocalKeys.english.tr();
    });
  }

  void _changeLanguage(String language) async {
    setState(() {
      selectedLanguage = language;
    });

    if (language == AppLocalKeys.arabic.tr()) {
      await SharedPreferencesHelper.setData(
        AppConstants.language,
        AppConstants.languageArabicCode,
      );
      context.setLocale(const Locale(AppConstants.languageArabicCode));
    } else {
      await SharedPreferencesHelper.setData(
        AppConstants.language,
        AppConstants.languageEnglishCode,
      );
      context.setLocale(const Locale(AppConstants.languageEnglishCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadLanguage();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Language Icon with Text
          Row(
            children: [
              Icon(Icons.language, size: 22.sp),
              SizedBox(width: 8.w,),
              Text(
                AppLocalKeys.language.tr(),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 6.w),
            ],
          ),

          // Language Selection Buttons
          Row(
            children: [
              _buildLanguageButton(
                AppLocalKeys.arabic.tr(),
                selectedLanguage == AppLocalKeys.arabic.tr(),
              ),
              SizedBox(width: 8.w),
              _buildLanguageButton(
                AppLocalKeys.english.tr(),
                selectedLanguage == AppLocalKeys.english.tr(),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildLanguageButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => _changeLanguage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

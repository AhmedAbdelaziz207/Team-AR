import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/prefs/shared_pref_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/app_local_keys.dart';

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
              SizedBox(
                width: 8.w,
              ),
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
          color: isSelected ? AppColors.newPrimaryColor : Colors.transparent,
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

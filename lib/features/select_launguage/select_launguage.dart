import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/select_launguage/widgets/launguage_item.dart';
import '../../core/theme/app_colors.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key});

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  bool isEnglishLangSelected = false;
  bool isArabicLangSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 21.0.h, horizontal: 8.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 12.h,
                ),
                Text(
                  AppLocalKeys.selectLanguage.tr(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 24.sp,
                      ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    AppLocalKeys.useLanguageEasily.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xff4d5566),
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 21.h,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isArabicLangSelected = false;

                      isEnglishLangSelected = true;
                    });
                  },
                  child: LanguageOption(
                    flagIcon: AppAssets.englishIcon,
                    language: AppLocalKeys.english.tr(),
                    nativeLanguage: AppLocalKeys.english.tr(),
                    isSelected: isEnglishLangSelected,
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isArabicLangSelected = true;
                      isEnglishLangSelected = false;
                    });
                  },
                  child: LanguageOption(
                    flagIcon: AppAssets.arabicIcon,
                    language: AppLocalKeys.arabic.tr(),
                    nativeLanguage: AppLocalKeys.arabic.tr(),
                    isSelected: isArabicLangSelected,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: isEnglishLangSelected || isArabicLangSelected
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if(isArabicLangSelected){
                      context.setLocale(const Locale(AppConstants.languageArabicCode));
                    }
                    if(isEnglishLangSelected){
                      context.setLocale(const Locale(AppConstants.languageEnglishCode));
                    }

                    setLanguageAndNavigate(isEnglishLangSelected, context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150.w, 46.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    backgroundColor: AppColors.mediumLavender,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalKeys.continueText.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 12.h,
                )
              ],
            )
          : null,
    );
  }
}

void setLanguageAndNavigate(bool isEnglish, context) async {
  if (isEnglish) {
    SharedPreferencesHelper.setData(
        AppConstants.english, AppConstants.languageEnglishCode);
  }
  else {
    SharedPreferencesHelper.setData(
      AppConstants.arabic,
      AppConstants.languageArabicCode,
    );
  }


  Navigator.pushNamed(context, Routes.login);
}

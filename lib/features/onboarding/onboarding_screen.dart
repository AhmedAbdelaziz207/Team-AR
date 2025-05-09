import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/onboarding/widgets/onboarding_bottom_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                AppAssets.coachImage1,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(),
              const Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0.w,
                  vertical: 12.h,
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalKeys.pushYourLimits.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.white),
                    ),
                    Text(
                      AppLocalKeys.recordYourBest.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppColors.white),
                    )
                  ],
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: OnboardingBottomButton(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

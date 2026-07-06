import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/home/admin/repos/trainees_repository.dart';
import '../../core/services/subscription_service.dart';
import '../auth/login/model/user_role.dart';
import '../subscription/screens/subscription_expired_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 2),
      () async {
        await _fetchAndSaveReleaseStatus();
        if (mounted) {
          await handleNavigation();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.newPrimaryColor,
        ),
      ),
    );
  }

  Future<void> handleNavigation() async {
    final token = await SharedPreferencesHelper.getString(AppConstants.token);
    final userRole =
        await SharedPreferencesHelper.getString(AppConstants.userRole);
    final userId = await SharedPreferencesHelper.getString(AppConstants.userId);
    final isDataCompleted =
        await SharedPreferencesHelper.getBool(AppConstants.dataCompleted);

    log("HandleNavigation: dataCompleted, $isDataCompleted");

    if (token != null && userRole != null && context.mounted) {
      if (userRole.toLowerCase() == UserRole.Admin.name.toLowerCase()) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.adminLanding,
          (route) => false,
        );
      } else {
        // Non-admin: if trainer and data not completed, force complete data first
        if (userRole.toLowerCase() == 'trainer'.toLowerCase()) {
          if (isDataCompleted == false) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.completeData,
              (route) => false,
            );
            return;
          } else {
            await _checkUserSubscription(userId);
          }
        } else {
          // For non-trainer users, proceed with subscription check
          await _checkUserSubscription(userId);
        }
      }
    } else {
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.onboarding,
          (route) => false,
        );
      }
    }
  }

  Future<void> _checkUserSubscription(String? userId) async {
    // isReleased = true → تجاوز فحص الاشتراك مؤقتاً
    final isReleased =
        await SharedPreferencesHelper.getBool(AppConstants.isReleased) ?? false;
    AppConstants.isReleasedValue = isReleased;
    if (isReleased) {
      log('isReleased=true → تجاوز فحص الاشتراك');
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.rootScreen,
        (route) => false,
      );
      return;
    }

    if (userId == null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.onboarding,
        (route) => false,
      );
      return;
    }

    try {
      final repo = TraineesRepository(getIt<ApiService>());
      final result = await repo.getLoggedUser(userId);

      result.when(
        success: (trainerData) async {
          // تحويل TrainerModel إلى نوع يمكن للـ SubscriptionService التعامل معه
          final status =
              await SubscriptionService.checkTrainerModelSubscription(
                  trainerData);

          if (status == SubscriptionStatus.expired) {
            // الاشتراك منتهي - إظهار شاشة انتهاء الاشتراك
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionExpiredScreen(),
              ),
              (route) => false,
            );
          } else {
            // الاشتراك نشط أو قارب على الانتهاء - الانتقال للشاشة الرئيسية
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.rootScreen,
              (route) => false,
            );
          }
        },
        failure: (error) async {
          // في حالة الخطأ (مثل حذف الحساب) - تنظيف البيانات والانتقال لشاشة الدخول
          await SharedPreferencesHelper.removeAll();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.onboarding,
              (route) => false,
            );
          }
        },
      );
    } catch (e) {
      // في حالة الخطأ
      await SharedPreferencesHelper.removeAll();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.onboarding,
          (route) => false,
        );
      }
    }
  }

  Future<void> _fetchAndSaveReleaseStatus() async {
    try {
      final api = getIt<ApiService>();
      final released = await api.isReleased();
      await SharedPreferencesHelper.setData(AppConstants.isReleased, released);
      AppConstants.isReleasedValue = released;
      log('isReleased from API: $released');
    } catch (e) {
      // في حالة فشل الـ API، نعتمد false (الوضع الطبيعي)
      await SharedPreferencesHelper.setData(AppConstants.isReleased, false);
      AppConstants.isReleasedValue = false;
      log('فشل جلب isReleased، الافتراضي = false: $e');
    }
  }
}

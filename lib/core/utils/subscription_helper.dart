import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/notification/logic/notification_cubit.dart';


class SubscriptionHelper {
  // طريقة للتعامل مع انتهاء الاشتراك باستخدام Cubit
  static Future<void> handleSubscriptionExpiryWithCubit({
    required BuildContext context,
    required dynamic userData, // نوع UserData الخاص بك
    required Function(String?, String?) showExpiredScreen,
  }) async {
    try {
      final endDate = userData.endPackage as DateTime?;
      String? endDateString;

      if (endDate != null) {
        endDateString = endDate.toIso8601String();
      }

      // الحصول على NotificationCubit من context
      final notificationCubit = context.read<NotificationCubit>();

      // إرسال الإشعار باستخدام Cubit
      await notificationCubit.sendSubscriptionExpiryNotification(
        userId: userData.id ?? '',
        userEmail: userData.email ?? '',
        expiryDate: endDate ?? DateTime.now(),
      );

      // عرض الشاشة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showExpiredScreen(userData.email, endDateString);
      });

    } catch (e) {
      print('خطأ في معالجة انتهاء الاشتراك: $e');

      // عرض الشاشة حتى لو فشل الإشعار
      final endDateString = (userData.endPackage as DateTime?)?.toIso8601String();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showExpiredScreen(userData.email, endDateString);
      });
    }
  }

  // طريقة بديلة باستخدام Service Locator مباشرة
  static Future<void> handleSubscriptionExpiryDirect({
    required dynamic userData,
    required Function(String?, String?) showExpiredScreen,
  }) async {
    try {
      final endDate = userData.endPackage as DateTime?;
      String? endDateString;

      if (endDate != null) {
        endDateString = endDate.toIso8601String();
      }

      // استخدام Service Locator مباشرة
      // final notificationService = setupServiceLocator.notificationService;

      // await notificationService.sendSubscriptionExpiryNotification(
      //   userId: userData.id ?? '',
      //   userEmail: userData.email ?? '',
      //   expiryDate: endDate ?? DateTime.now(),
      // );

      // عرض الشاشة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showExpiredScreen(userData.email, endDateString);
      });

    } catch (e) {
      print('خطأ في معالجة انتهاء الاشتراك: $e');

      // عرض الشاشة حتى لو فشل الإشعار
      final endDateString = (userData.endPackage as DateTime?)?.toIso8601String();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showExpiredScreen(userData.email, endDateString);
      });
    }
  }
}

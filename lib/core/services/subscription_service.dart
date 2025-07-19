import 'dart:async';
import 'package:flutter/services.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import '../../features/home/admin/data/trainee_model.dart';
import '../../features/home/model/user_data.dart';
import '../constants/notification_constants.dart';
import 'cache_manager.dart';
import 'logger_service.dart';

class SubscriptionService {
  static const int WARNING_DAYS = 3;
  static const String CACHE_KEY = 'subscription_status';
  static const String LAST_CHECK_KEY = 'last_subscription_check';

  static final CacheManager _cache = CacheManager();
  static final LoggerService _logger = LoggerService();
  static bool _isChecking = false;

  // فحص حالة الاشتراك مع التحسينات
  static Future<SubscriptionStatus> checkSubscriptionStatus(UserData userData) async {
    if (_isChecking) {
      _logger.info('Subscription check already in progress');
      return SubscriptionStatus.active;
    }

    try {
      _isChecking = true;
      _logger.info('Starting subscription status check for user: ${userData.email}');

      // فحص الكاش أولاً
      final cachedStatus = await _getCachedStatus(userData);
      if (cachedStatus != null) {
        _logger.info('Using cached subscription status: $cachedStatus');
        return cachedStatus;
      }

      if (userData.endPackage == null) {
        _logger.warning('User has no subscription package');
        return SubscriptionStatus.expired;
      }

      final endDate = DateTime.parse(userData.endPackage as String);
      final now = DateTime.now();
      final daysRemaining = endDate.difference(now).inDays;

      SubscriptionStatus status;
      if (daysRemaining < 0) {
        status = SubscriptionStatus.expired;
        _logger.warning('Subscription expired ${daysRemaining.abs()} days ago');
      } else if (daysRemaining <= WARNING_DAYS) {
        status = SubscriptionStatus.expiringSoon;
        _logger.info('Subscription expiring in $daysRemaining days');
      } else {
        status = SubscriptionStatus.active;
        _logger.info('Subscription active with $daysRemaining days remaining');
      }

      // حفظ في الكاش
      await _cacheStatus(userData, status);

      return status;
    } catch (e, stackTrace) {
      _logger.error('Error checking subscription status', e, stackTrace);
      return SubscriptionStatus.expired;
    } finally {
      _isChecking = false;
    }
  }






  // فحص حالة الاشتراك للـ TraineeModel (طريقة جديدة)
  static Future<SubscriptionStatus> checkTrainerModelSubscription(TraineeModel traineeData) async {
    if (_isChecking) {
      _logger.info('Subscription check already in progress');
      return SubscriptionStatus.active;
    }

    try {
      _isChecking = true;
      _logger.info('Starting subscription status check for trainee: ${traineeData.email}');

      // فحص الكاش أولاً
      final cachedStatus = await _getCachedTrainerStatus(traineeData);
      if (cachedStatus != null) {
        _logger.info('Using cached subscription status: $cachedStatus');
        return cachedStatus;
      }

      if (traineeData.endPackage == null) {
        _logger.warning('Trainee has no subscription package');
        return SubscriptionStatus.expired;
      }

      final endDate = traineeData.endPackage!;
      final now = DateTime.now();
      final daysRemaining = endDate.difference(now).inDays;

      SubscriptionStatus status;
      if (daysRemaining < 0) {
        status = SubscriptionStatus.expired;
        _logger.warning('Subscription expired ${daysRemaining.abs()} days ago');
      } else if (daysRemaining <= WARNING_DAYS) {
        status = SubscriptionStatus.expiringSoon;
        _logger.info('Subscription expiring in $daysRemaining days');
      } else {
        status = SubscriptionStatus.active;
        _logger.info('Subscription active with $daysRemaining days remaining');
      }

      // حفظ في الكاش
      await _cacheTrainerStatus(traineeData, status);

      return status;
    } catch (e, stackTrace) {
      _logger.error('Error checking trainer subscription status', e, stackTrace);
      return SubscriptionStatus.expired;
    } finally {
      _isChecking = false;
    }
  }



  // الحصول على عدد الأيام المتبقية للـ TraineeModel (طريقة جديدة)
  static int getTrainerModelDaysRemaining(TraineeModel traineeData) {
    try {
      if (traineeData.endPackage == null) return 0;

      final endDate = traineeData.endPackage!;
      final now = DateTime.now();
      final daysRemaining = endDate.difference(now).inDays;

      return daysRemaining < 0 ? 0 : daysRemaining;
    } catch (e) {
      _logger.error('Error calculating trainer days remaining', e);
      return 0;
    }
  }

  static Future<void> _cacheTrainerStatus(TraineeModel traineeData, SubscriptionStatus status) async {
    try {
      final cacheKey = '${CACHE_KEY}_${traineeData.email}_${traineeData.id}';
      final cacheData = {
        'status': status.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _cache.set(cacheKey, cacheData, const Duration(minutes: 10));
      _logger.info('Cached trainer subscription status: $status');
    } catch (e) {
      _logger.error('Error caching trainer status', e);
    }
  }

  // طرق مساعدة للكاش - TraineeModel (طرق جديدة)
  static Future<SubscriptionStatus?> _getCachedTrainerStatus(TraineeModel traineeData) async {
    try {
      final cacheKey = '${CACHE_KEY}_${traineeData.email}_${traineeData.id}';
      final cachedData = await _cache.get<Map<String, dynamic>>(cacheKey);

      if (cachedData != null) {
        final cacheTime = DateTime.parse(cachedData['timestamp']);
        final now = DateTime.now();

        if (now.difference(cacheTime).inMinutes < 10) {
          final statusString = cachedData['status'];
          return SubscriptionStatus.values.firstWhere(
                (status) => status.toString() == statusString,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error getting cached trainer status', e);
      return null;
    }
  }


















  // الحصول على عدد الأيام المتبقية
  static int getDaysRemaining(UserData userData) {
    try {
      if (userData.endPackage == null) return 0;

      final endDate = DateTime.parse(userData.endPackage!);
      final now = DateTime.now();
      final daysRemaining = endDate.difference(now).inDays;

      return daysRemaining < 0 ? 0 : daysRemaining;
    } catch (e) {
      _logger.error('Error calculating days remaining', e);
      return 0;
    }
  }

  // حفظ آخر إشعار تم إرساله
  static Future<void> saveLastNotificationDate() async {
    try {
      await SharedPreferencesHelper.setString(
        NotificationConstants.lastNotificationDate,
        DateTime.now().toIso8601String(),
      );
      _logger.info('Last notification date saved');
    } catch (e) {
      _logger.error('Error saving last notification date', e);
    }
  }

  // فحص ما إذا كان يجب إرسال إشعار
  static Future<bool> shouldSendNotification() async {
    try {
      final lastNotificationDate = await SharedPreferencesHelper.getString(
        NotificationConstants.lastNotificationDate,
      );

      if (lastNotificationDate == null) return true;

      final lastDate = DateTime.parse(lastNotificationDate);
      final now = DateTime.now();

      // إرسال إشعار مرة واحدة يومياً
      final shouldSend = now.difference(lastDate).inDays >= 1;
      _logger.info('Should send notification: $shouldSend');

      return shouldSend;
    } catch (e) {
      _logger.error('Error checking notification schedule', e);
      return false;
    }
  }

  // إغلاق التطبيق
  static void closeApp() {
    _logger.info('Closing app due to subscription expiry');
    SystemNavigator.pop();
  }

  // طرق مساعدة للكاش - Fixed to accept UserData instead of UserModel
  static Future<SubscriptionStatus?> _getCachedStatus(UserData userData) async {
    try {
      // Use email as identifier since UserData doesn't have id field
      final cacheKey = '${CACHE_KEY}_${userData.email}';
      final cachedData = await _cache.get<Map<String, dynamic>>(cacheKey);

      if (cachedData != null) {
        final cacheTime = DateTime.parse(cachedData['timestamp']);
        final now = DateTime.now();

        // الكاش صالح لمدة 10 دقائق
        if (now.difference(cacheTime).inMinutes < 10) {
          final statusString = cachedData['status'];
          return SubscriptionStatus.values.firstWhere(
                (status) => status.toString() == statusString,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error getting cached status', e);
      return null;
    }
  }

  static Future<void> _cacheStatus(UserData userData, SubscriptionStatus status) async {
    try {
      // Use email as identifier since UserData doesn't have id field
      final cacheKey = '${CACHE_KEY}_${userData.email}';
      final cacheData = {
        'status': status.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _cache.set(cacheKey, cacheData, const Duration(minutes: 10));
      _logger.info('Cached subscription status: $status');
    } catch (e) {
      _logger.error('Error caching status', e);
    }
  }

  // تنظيف الكاش
  static Future<void> clearCache() async {
    try {
      await _cache.clear();
      _logger.info('Subscription cache cleared');
    } catch (e) {
      _logger.error('Error clearing cache', e);
    }
  }
}

enum SubscriptionStatus {
  active,
  expiringSoon,
  expired,
}
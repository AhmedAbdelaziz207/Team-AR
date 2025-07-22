import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_type_enum.dart';
import 'local_notification_service.dart';
import 'notification_storage.dart';

class SubscriptionMonitorService {
  static final SubscriptionMonitorService _instance =
  SubscriptionMonitorService._internal();
  factory SubscriptionMonitorService() => _instance;
  SubscriptionMonitorService._internal();

  final LocalNotificationService _localNotificationService =
  LocalNotificationService();
  final NotificationStorage _storage = NotificationStorage();

  Timer? _monitorTimer;
  bool _isMonitoring = false;

  static const String _sentNotificationsKey = 'sent_subscription_notifications';
  static const String _lastCheckKey = 'last_subscription_check';

  /// بدء مراقبة الاشتراكات
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    // فحص كل 6 ساعات
    _monitorTimer = Timer.periodic(
      const Duration(hours: 6),
          (_) => _checkAllSubscriptions(),
    );

    // فحص فوري عند بدء المراقبة
    _checkAllSubscriptions();

    debugPrint('Subscription monitoring started');
  }

  /// إيقاف مراقبة الاشتراكات
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _isMonitoring = false;
    debugPrint('Subscription monitoring stopped');
  }

  /// فحص جميع الاشتراكات
  Future _checkAllSubscriptions() async {
    try {
      debugPrint('Checking subscriptions...');

      // تحديث وقت آخر فحص
      await _updateLastCheckTime();

      // الحصول على معلومات الاشتراك
      final subscriptionData = await _getSubscriptionData();

      if (subscriptionData != null) {
        await _checkSubscriptionExpiry(
          expiryDate: subscriptionData['expiryDate'],
          userId: subscriptionData['userId'],
          userName: subscriptionData['userName'] ?? 'المستخدم',
        );
      }
    } catch (e) {
      debugPrint('Error checking subscriptions: $e');
    }
  }

  /// فحص انتهاء اشتراك محدد
  Future _checkSubscriptionExpiry({
    required DateTime expiryDate,
    required String userId,
    required String userName,
  }) async {
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;
    final hoursUntilExpiry = expiryDate.difference(now).inHours;

    debugPrint('Subscription expires in $daysUntilExpiry days ($hoursUntilExpiry hours)');

    // تحديد ما إذا كان يجب إرسال إشعار
    String? notificationKey;
    bool shouldNotify = false;

    if (daysUntilExpiry <= 0) {
      // انتهى الاشتراك
      shouldNotify = true;
      notificationKey = 'expired_$userId';
    } else if (daysUntilExpiry == 1 && hoursUntilExpiry <= 24) {
      // يوم واحد متبقي
      shouldNotify = true;
      notificationKey = 'expiring_1_$userId';
    } else if (daysUntilExpiry == 3) {
      // 3 أيام متبقية
      shouldNotify = true;
      notificationKey = 'expiring_3_$userId';
    } else if (daysUntilExpiry == 7) {
      // أسبوع متبقي
      shouldNotify = true;
      notificationKey = 'expiring_7_$userId';
    }

    if (shouldNotify && notificationKey != null) {
      // التحقق من عدم إرسال نفس الإشعار مسبقاً
      final alreadySent = await _isNotificationAlreadySent(notificationKey);

      if (!alreadySent) {
        await _sendSubscriptionNotification(
          daysUntilExpiry: daysUntilExpiry,
          userId: userId,
          userName: userName,
          notificationKey: notificationKey,
        );
      } else {
        debugPrint('Notification already sent: $notificationKey');
      }
    }
  }

  /// إرسال إشعار الاشتراك
  Future _sendSubscriptionNotification({
    required int daysUntilExpiry,
    required String userId,
    required String userName,
    required String notificationKey,
  }) async {
    try {
      NotificationModel notification;

      if (daysUntilExpiry <= 0) {
        // اشتراك منتهي
        notification = NotificationModel(
          id: 'sub_expired_${DateTime.now().millisecondsSinceEpoch}',
          title: '⚠️ انتهى اشتراكك',
          body: 'مرحباً $userName، لقد انتهت صلاحية اشتراكك. يرجى تجديد الاشتراك للمتابعة واستكمال رحلة اللياقة.',
          type: NotificationType.subscriptionExpiry,
          createdAt: DateTime.now(),
          isRead: false,
          customData: {
            'action': 'subscription_expired',
            'userId': userId,
            'priority': 'high',
            'notificationKey': notificationKey,
            'daysLeft': daysUntilExpiry,
          },
        );
      } else {
        // اشتراك قارب على الانتهاء
        String dayText = daysUntilExpiry == 1 ? 'يوم واحد' : '$daysUntilExpiry أيام';

        notification = NotificationModel(
          id: 'sub_expiring_${DateTime.now().millisecondsSinceEpoch}',
          title: '⏰ تنتهي صلاحية اشتراكك قريباً',
          body: 'مرحباً $userName، سينتهي اشتراكك خلال $dayText. جدد اشتراكك الآن لضمان استمرار الخدمة دون انقطاع.',
          type: NotificationType.subscriptionExpiry,
          createdAt: DateTime.now(),
          isRead: false,
          customData: {
            'action': 'subscription_expiring',
            'daysLeft': daysUntilExpiry,
            'userId': userId,
            'priority': 'high',
            'notificationKey': notificationKey,
          },
        );
      }

      // حفظ الإشعار وعرضه
      await _storage.saveNotification(notification);
      await _localNotificationService.showNotification(notification);

      // تسجيل أن الإشعار تم إرساله
      await _markNotificationAsSent(notificationKey);

      debugPrint('Subscription notification sent: ${notification.id}');
    } catch (e) {
      debugPrint('Error sending subscription notification: $e');
    }
  }

  /// التحقق من إرسال الإشعار مسبقاً
  Future _isNotificationAlreadySent(String notificationKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sentNotifications = prefs.getStringList(_sentNotificationsKey) ?? [];

      // التحقق من وجود المفتاح مع التاريخ الحالي
      final today = DateTime.now().toIso8601String().split('T')[0];
      final keyWithDate = '${notificationKey}_$today';

      return sentNotifications.contains(keyWithDate);
    } catch (e) {
      debugPrint('Error checking sent notifications: $e');
      return false;
    }
  }

  /// تسجيل إرسال الإشعار
  Future _markNotificationAsSent(String notificationKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sentNotifications = prefs.getStringList(_sentNotificationsKey) ?? [];

      // إضافة المفتاح مع التاريخ الحالي
      final today = DateTime.now().toIso8601String().split('T')[0];
      final keyWithDate = '${notificationKey}_$today';

      if (!sentNotifications.contains(keyWithDate)) {
        sentNotifications.add(keyWithDate);

        // الاحتفاظ بآخر 50 مفتاح فقط لتوفير المساحة
        if (sentNotifications.length > 50) {
          sentNotifications.removeRange(0, sentNotifications.length - 50);
        }

        await prefs.setStringList(_sentNotificationsKey, sentNotifications);
      }
    } catch (e) {
      debugPrint('Error marking notification as sent: $e');
    }
  }

  /// تحديث وقت آخر فحص
  Future _updateLastCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastCheckKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error updating last check time: $e');
    }
  }

  /// الحصول على وقت آخر فحص
  Future getLastCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckString = prefs.getString(_lastCheckKey);
      return lastCheckString != null ? DateTime.tryParse(lastCheckString) : null;
    } catch (e) {
      debugPrint('Error getting last check time: $e');
      return null;
    }
  }

  /// الحصول على بيانات الاشتراك
  Future<Map<String, dynamic>?> _getSubscriptionData() async {
    try {
      // مثال افتراضي للاختبار:

      final prefs = await SharedPreferences.getInstance();

      // يمكن الحصول على البيانات من SharedPreferences
      // مثال افتراضي:
      return {
        'userId': 'user_123',
        'userName': 'أحمد محمد',
        'expiryDate': DateTime.now().add(const Duration(days: 2)), // مثال: ينتهي خلال يومين
      };



    } catch (e) {
      debugPrint('Error getting subscription data: $e');
      return null;
    }
  }

  /// فحص يدوي للاشتراك
  Future checkSubscriptionManually({
    required DateTime expiryDate,
    required String userId,
    String? userName,
  }) async {
    try {
      await _checkSubscriptionExpiry(
        expiryDate: expiryDate,
        userId: userId,
        userName: userName ?? 'المستخدم',
      );
    } catch (e) {
      debugPrint('Error in manual subscription check: $e');
    }
  }

  /// إرسال إشعار اختبار للاشتراك
  Future sendTestSubscriptionNotification() async {
    try {
      await _sendSubscriptionNotification(
        daysUntilExpiry: 3,
        userId: 'test_user',
        userName: 'مستخدم تجريبي',
        notificationKey: 'test_${DateTime.now().millisecondsSinceEpoch}',
      );

      debugPrint('Test subscription notification sent');
    } catch (e) {
      debugPrint('Error sending test subscription notification: $e');
    }
  }

  /// مسح سجل الإشعارات المرسلة
  Future clearSentNotificationsHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sentNotificationsKey);
      debugPrint('Sent notifications history cleared');
    } catch (e) {
      debugPrint('Error clearing sent notifications history: $e');
    }
  }

  /// الحصول على حالة المراقبة
  bool get isMonitoring => _isMonitoring;

  /// تنظيف الموارد
  void dispose() {
    stopMonitoring();
  }
}

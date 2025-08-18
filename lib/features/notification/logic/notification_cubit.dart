import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_type_enum.dart';
import '../services/local_notification_service.dart';
import '../services/notification_repository.dart';
import '../../../core/services/notification_service.dart';
import '../services/notification_storage.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService;
  final NotificationRepository _repository;
  final LocalNotificationService _localNotificationService;

  late StreamSubscription _notificationSubscription;
  Timer? _refreshTimer;

  NotificationCubit({
    required NotificationService notificationService,
    required NotificationRepository repository,
    required LocalNotificationService localNotificationService,
    required NotificationStorage storage,
  })  : _notificationService = notificationService,
        _repository = repository,
        _localNotificationService = localNotificationService,
        super(NotificationInitial()) {
    _initializeNotifications();
    _startPeriodicRefresh();
  }

  /// تهيئة الإشعارات
  void _initializeNotifications() {
    _notificationSubscription = _notificationService.notificationStream.listen(
      (notification) async {
        try {
          await _repository.saveNotification(notification);
          await _localNotificationService.showNotification(notification);
          await _refreshNotifications();

          emit(NotificationReceived(notification: notification));
        } catch (e) {
          emit(NotificationError(
              message: 'فشل في استقبال الإشعار: ${e.toString()}'));
        }
      },
      onError: (error) {
        emit(NotificationError(message: error.toString()));
      },
    );
  }

  /// بدء التحديث الدوري
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (state is NotificationLoaded) {
        await _refreshNotifications();
      }
    });
  }

  /// تحديث الإشعارات من التخزين
  Future _refreshNotifications() async {
    try {
      final notifications = await _repository.getAllNotifications();
      final settings = await _repository.getNotificationSettings();
      final unreadCount = notifications.where((n) => !n.isRead).length;

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        if (_notificationsChanged(currentState.notifications, notifications)) {
          emit(NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
            settings: settings,
          ));
        }
      }
    } catch (_) {
      // تجاهل الأخطاء
    }
  }

  /// التحقق من تغيير الإشعارات
  bool _notificationsChanged(List oldList, List newList) {
    if (oldList.length != newList.length) return true;
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].id != newList[i].id ||
          oldList[i].isRead != newList[i].isRead ||
          oldList[i].title != newList[i].title) {
        return true;
      }
    }
    return false;
  }

  /// تحميل الإشعارات
  Future loadNotifications() async {
    try {
      emit(NotificationLoading());

      final notifications = await _repository.getAllNotifications();
      final settings = await _repository.getNotificationSettings();
      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        settings: settings,
      ));
    } catch (e) {
      emit(NotificationError(
          message: 'فشل في تحميل الإشعارات: ${e.toString()}'));
    }
  }

  /// إضافة إشعار
  Future addNotification(NotificationModel notification) async {
    try {
      if (notification.title.isEmpty || notification.body.isEmpty) {
        throw Exception('بيانات الإشعار غير صحيحة');
      }

      await _repository.saveNotification(notification);
      await _localNotificationService.showNotification(notification);

      _addNotificationToState(notification);

      emit(NotificationReceived(notification: notification));
    } catch (e) {
      emit(NotificationError(message: 'فشل في إضافة الإشعار: ${e.toString()}'));
    }
  }

  /// جدولة إشعار
  Future scheduleNotification({
    required NotificationModel notification,
    required DateTime scheduledTime,
  }) async {
    try {
      if (scheduledTime.isBefore(DateTime.now())) {
        throw Exception('لا يمكن جدولة إشعار في الماضي');
      }

      final scheduledNotification =
          notification.copyWith(scheduledAt: scheduledTime);

      await _repository.saveNotification(scheduledNotification);
      await _localNotificationService.scheduleNotification(
        scheduledNotification,
        scheduledTime,
      );

      emit(NotificationScheduled(
        notificationId: notification.id,
        scheduledTime: scheduledTime,
      ));

      _addNotificationToState(scheduledNotification);
    } catch (e) {
      emit(NotificationError(message: 'فشل في جدولة الإشعار: ${e.toString()}'));
    }
  }

  /// تحديد كمقروء
  Future markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;

        final updatedNotifications = currentState.notifications.map((n) {
          return n.id == notificationId ? n.copyWith(isRead: true) : n;
        }).toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        emit(currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      emit(NotificationError(
          message: 'فشل في تحديث حالة الإشعار: ${e.toString()}'));
    }
  }

  /// تحديد الكل كمقروء
  Future markAllAsRead() async {
    try {
      await _repository.markAllAsRead();

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;

        final updatedNotifications = currentState.notifications.map((n) {
          return n.copyWith(isRead: true);
        }).toList();

        emit(currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        ));
      }
    } catch (e) {
      emit(NotificationError(
          message: 'فشل في تحديث الإشعارات: ${e.toString()}'));
    }
  }

  /// حذف إشعار
  Future deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      await _localNotificationService.cancelNotification(notificationId);

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;

        final updatedNotifications = currentState.notifications
            .where((n) => n.id != notificationId)
            .toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        emit(currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      emit(NotificationError(message: 'فشل في حذف الإشعار: ${e.toString()}'));
    }
  }

  /// مسح الكل
  Future clearAllNotifications() async {
    try {
      await _repository.clearAllNotifications();
      await _localNotificationService.cancelAllNotifications();

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;

        emit(currentState.copyWith(
          notifications: [],
          unreadCount: 0,
        ));
      }
    } catch (e) {
      emit(NotificationError(message: 'فشل في مسح الإشعارات: ${e.toString()}'));
    }
  }

  /// فحص الاشتراك
  Future checkSubscriptionStatus({
    required DateTime expiryDate,
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      final difference = expiryDate.difference(now).inDays;

      if (difference <= 0) {
        await _sendSubscriptionExpiredNotification(userId);
      } else if ([7, 3, 1].contains(difference)) {
        await _sendSubscriptionExpiringNotification(difference, userId);
      }
    } catch (e) {
      emit(NotificationError(
          message: 'فشل في فحص حالة الاشتراك: ${e.toString()}'));
    }
  }

  Future _sendSubscriptionExpiredNotification(String userId) async {
    final notification = NotificationModel(
      id: 'subscription_expired_${DateTime.now().millisecondsSinceEpoch}',
      title: '⚠️ انتهى اشتراكك',
      body: 'لقد انتهت صلاحية اشتراكك. يرجى تجديد الاشتراك للمتابعة.',
      type: NotificationType.subscriptionExpiry,
      createdAt: DateTime.now(),
      isRead: false,
      customData: {
        'action': 'expired',
        'priority': 'high',
        'userId': userId,
      },
    );

    await addNotification(notification);
  }

  Future _sendSubscriptionExpiringNotification(
      int daysLeft, String userId) async {
    final notification = NotificationModel(
      id: 'subscription_expiring_${daysLeft}_${DateTime.now().millisecondsSinceEpoch}',
      title: '⏰ تنتهي صلاحية اشتراكك قريباً',
      body:
          'سينتهي اشتراكك خلال $daysLeft ${daysLeft == 1 ? 'يوم' : 'أيام'}. جدد اشتراكك الآن!',
      type: NotificationType.subscriptionExpiry,
      createdAt: DateTime.now(),
      isRead: false,
      customData: {
        'action': 'expiring',
        'daysLeft': daysLeft,
        'priority': 'high',
        'userId': userId,
      },
    );

    await addNotification(notification);
  }

  /// اختبار
  Future testNotifications() async {
    try {
      final generalNotification = NotificationModel(
        id: 'test_general_${DateTime.now().millisecondsSinceEpoch}',
        title: '🔔 اختبار الإشعار العام',
        body: 'هذا إشعار تجريبي للتأكد من عمل النظام',
        type: NotificationType.system,
        createdAt: DateTime.now(),
        isRead: false,
      );

      await addNotification(generalNotification);

      final subscriptionNotification = NotificationModel(
        id: 'test_subscription_${DateTime.now().millisecondsSinceEpoch}',
        title: '⚠️ اختبار إشعار الاشتراك',
        body: 'هذا اختبار لإشعارات انتهاء الاشتراك',
        type: NotificationType.subscriptionExpiry,
        createdAt: DateTime.now(),
        isRead: false,
      );

      await addNotification(subscriptionNotification);

      emit(const NotificationSent(
          message: 'تم إرسال الإشعارات التجريبية بنجاح'));
    } catch (e) {
      emit(NotificationError(
          message: 'فشل في إرسال الإشعارات التجريبية: ${e.toString()}'));
    }
  }

  /// حسب النوع
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      return currentState.notifications.where((n) => n.type == type).toList();
    }
    return [];
  }

  /// غير مقروءة
  List<NotificationModel> getUnreadNotifications() {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      return currentState.notifications.where((n) => !n.isRead).toList();
    }
    return [];
  }

  /// أضف للحالة
  void _addNotificationToState(NotificationModel notification) {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      final updatedNotifications = [
        notification,
        ...currentState.notifications
      ];
      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      ));
    }
  }

  /// إرسال إشعار انتهاء الاشتراك
  Future<void> sendSubscriptionExpiryNotification({
    required String userId,
    required String userEmail,
    required DateTime expiryDate,
  }) async {
    try {
      await _notificationService.sendSubscriptionExpiryNotification(
        userId: userId,
        userEmail: userEmail,
        expiryDate: expiryDate,
      );

      // تحديث الحالة لإظهار أنه تم إرسال الإشعار
      emit(const NotificationSent(message: 'تم إرسال إشعار انتهاء الاشتراك'));

      // تحميل الإشعارات المحدثة
      await loadNotifications();
    } catch (e) {
      emit(NotificationError(
        message: 'فشل في إرسال إشعار انتهاء الاشتراك: ${e.toString()}',
      ));
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription.cancel();
    _refreshTimer?.cancel();
    return super.close();
  }
}

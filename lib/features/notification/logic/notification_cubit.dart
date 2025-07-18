import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_settings_model.dart';
import '../../../core/common/notification_type_enum.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../core/utils/notification_validator.dart';
import '../services/local_notification_service.dart';
import '../services/notification_repository.dart';
import '../services/notification_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService;
  final NotificationRepository _repository;
  final LocalNotificationService _localNotificationService;

  late StreamSubscription _notificationSubscription;

  NotificationCubit({
    required NotificationService notificationService,
    required NotificationRepository repository,
    required LocalNotificationService localNotificationService,
  })  : _notificationService = notificationService,
        _repository = repository,
        _localNotificationService = localNotificationService,
        super(NotificationInitial()) {
    _initializeNotifications();
  }

  // Initialize notifications
  void _initializeNotifications() {
    _notificationSubscription = _notificationService.notificationStream.listen(
          (notification) {
        emit(NotificationReceived(notification: notification));
        _addNotificationToState(notification);
      },
      onError: (error) {
        emit(NotificationError(message: error.toString()));
      },
    );
  }

  // Load notifications from storage
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
        message: 'فشل في تحميل الإشعارات: ${e.toString()}',
      ));
    }
  }

  // Add new notification
  Future addNotification(NotificationModel notification) async {
    try {
      NotificationValidator.validateNotification(notification);

      await _repository.saveNotification(notification);
      await _localNotificationService.showNotification(notification);

      _addNotificationToState(notification);
    } catch (e) {
      emit(NotificationError(
        message: 'فشل في إضافة الإشعار: ${e.toString()}',
      ));
    }
  }

  // Schedule notification
  Future scheduleNotification({
    required NotificationModel notification,
    required DateTime scheduledTime,
  }) async {
    try {
      NotificationValidator.validateNotification(notification);
      NotificationValidator.validateScheduleTime(scheduledTime);

      final scheduledNotification = notification.copyWith(
        scheduledAt: scheduledTime,
      );

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
      emit(NotificationError(
        message: 'فشل في جدولة الإشعار: ${e.toString()}',
      ));
    }
  }

  // Mark notification as read
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
        message: 'فشل في تحديث حالة الإشعار: ${e.toString()}',
      ));
    }
  }

  // Mark all notifications as read
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
        message: 'فشل في تحديث الإشعارات: ${e.toString()}',
      ));
    }
  }

  // Delete notification
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
      emit(NotificationError(
        message: 'فشل في حذف الإشعار: ${e.toString()}',
      ));
    }
  }

  // Clear all notifications
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
      emit(NotificationError(
        message: 'فشل في مسح الإشعارات: ${e.toString()}',
      ));
    }
  }

  // Update notification settings
  Future updateSettings(NotificationSettingsModel settings) async {
    try {
      await _repository.saveNotificationSettings(settings);

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        emit(currentState.copyWith(settings: settings));
      }

      emit(NotificationSettingsUpdated(settings: settings));
    } catch (e) {
      emit(NotificationError(
        message: 'فشل في تحديث الإعدادات: ${e.toString()}',
      ));
    }
  }

  // Schedule workout reminder
  Future scheduleWorkoutReminder({
    required String title,
    required String body,
    required DateTime reminderTime,
    Map? customData,
  }) async {
    try {
      final notification = NotificationHelper.createWorkoutReminder(
        title: title,
        body: body,
        scheduledAt: reminderTime,
        customData: customData,
      );

      await scheduleNotification(
        notification: notification,
        scheduledTime: reminderTime,
      );
    } catch (e) {
      emit(NotificationError(
        message: 'فشل في جدولة تذكير التمرين: ${e.toString()}',
      ));
    }
  }

  // Send motivational notification
  Future sendMotivationalNotification({
    String? customMessage,
    Map? customData,
  }) async {
    try {
      final notification = NotificationHelper.createMotivationalNotification(
        customMessage: customMessage,
        customData: customData,
      );

      await addNotification(notification);
    } catch (e) {
      emit(NotificationError(
        message: 'فشل في إرسال الرسالة التحفيزية: ${e.toString()}',
      ));
    }
  }

  // Handle notification tap
  Future handleNotificationTap(String notificationId) async {
    try {
      await markAsRead(notificationId);

      emit(NotificationActionPerformed(
        notificationId: notificationId,
        action: 'tap',
      ));
    } catch (e) {
      emit(NotificationError(
        message: 'فشل في معالجة النقر على الإشعار: ${e.toString()}',
      ));
    }
  }

  // Get notifications by type
  List getNotificationsByType(NotificationType type) {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      return currentState.notifications.where((n) => n.type == type).toList();
    }
    return [];
  }

  // Get unread notifications
  List getUnreadNotifications() {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      return currentState.notifications.where((n) => !n.isRead).toList();
    }
    return [];
  }

  // Add notification to current state
  void _addNotificationToState(NotificationModel notification) {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updatedNotifications = [notification, ...currentState.notifications];
      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      ));
    }
  }

  @override
  Future close() {
    _notificationSubscription.cancel();
    return super.close();
  }
}
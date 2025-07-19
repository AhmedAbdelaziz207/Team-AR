import 'package:equatable/equatable.dart';

import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_settings_model.dart';


abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final NotificationSettingsModel settings;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    required this.settings,
  });

  @override
  List get props => [notifications, unreadCount, settings];

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    NotificationSettingsModel? settings,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      settings: settings ?? this.settings,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;
  final String? errorCode;

  const NotificationError({
    required this.message,
    this.errorCode,
  });

  @override
  List get props => [message, errorCode];
}

class NotificationScheduled extends NotificationState {
  final String notificationId;
  final DateTime scheduledTime;

  const NotificationScheduled({
    required this.notificationId,
    required this.scheduledTime,
  });

  @override
  List get props => [notificationId, scheduledTime];
}

class NotificationReceived extends NotificationState {
  final NotificationModel notification;

  const NotificationReceived({required this.notification});

  @override
  List get props => [notification];
}

class NotificationActionPerformed extends NotificationState {
  final String notificationId;
  final String action;

  const NotificationActionPerformed({
    required this.notificationId,
    required this.action,
  });

  @override
  List get props => [notificationId, action];
}

class NotificationSettingsUpdated extends NotificationState {
  final NotificationSettingsModel settings;

  const NotificationSettingsUpdated({required this.settings});

  @override
  List get props => [settings];
}

class NotificationOperationSuccess extends NotificationState {
  final String message;

  const NotificationOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
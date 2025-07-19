// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      payload: json['payload'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isLocal: json['isLocal'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      customData: json['customData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'payload': instance.payload,
      'createdAt': instance.createdAt.toIso8601String(),
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'isRead': instance.isRead,
      'isLocal': instance.isLocal,
      'imageUrl': instance.imageUrl,
      'customData': instance.customData,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.workoutPlan: 'workoutPlan',
  NotificationType.workoutReminder: 'workoutReminder',
  NotificationType.trainerEvaluation: 'trainerEvaluation',
  NotificationType.bookingConfirmation: 'bookingConfirmation',
  NotificationType.bookingCancellation: 'bookingCancellation',
  NotificationType.motivational: 'motivational',
  NotificationType.subscriptionExpiry: 'subscriptionExpiry',
  NotificationType.paymentConfirmation: 'paymentConfirmation',
  NotificationType.newContent: 'newContent',
  NotificationType.promotion: 'promotion',
  NotificationType.newMember: 'newMember',
  NotificationType.bookingRequest: 'bookingRequest',
  NotificationType.newReview: 'newReview',
  NotificationType.technicalIssue: 'technicalIssue',
  NotificationType.system: 'system',
  NotificationType.maintenance: 'maintenance',
};

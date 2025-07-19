// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationResponseModel _$NotificationResponseModelFromJson(
        Map<String, dynamic> json) =>
    NotificationResponseModel(
      notificationId: json['notificationId'] as String,
      actionType: json['actionType'] as String,
      responseTime: DateTime.parse(json['responseTime'] as String),
      payload: json['payload'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationResponseModelToJson(
        NotificationResponseModel instance) =>
    <String, dynamic>{
      'notificationId': instance.notificationId,
      'actionType': instance.actionType,
      'responseTime': instance.responseTime.toIso8601String(),
      'payload': instance.payload,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationSettingsModel _$NotificationSettingsModelFromJson(
        Map<dynamic, dynamic> json) =>
    NotificationSettingsModel(
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      enableSound: json['enableSound'] as bool? ?? true,
      enableVibration: json['enableVibration'] as bool? ?? true,
      enableWorkoutReminders: json['enableWorkoutReminders'] as bool? ?? true,
      enableMotivationalMessages:
          json['enableMotivationalMessages'] as bool? ?? true,
      enablePromotions: json['enablePromotions'] as bool? ?? false,
      enableSystemNotifications:
          json['enableSystemNotifications'] as bool? ?? true,
      preferredTime: json['preferredTime'] as String? ?? '09:00',
      reminderDays:
          json['reminderDays'] as List<dynamic>? ?? const [1, 2, 3, 4, 5],
      reminderFrequency: (json['reminderFrequency'] as num?)?.toInt() ?? 24,
    );

Map<String, dynamic> _$NotificationSettingsModelToJson(
        NotificationSettingsModel instance) =>
    <String, dynamic>{
      'enableNotifications': instance.enableNotifications,
      'enableSound': instance.enableSound,
      'enableVibration': instance.enableVibration,
      'enableWorkoutReminders': instance.enableWorkoutReminders,
      'enableMotivationalMessages': instance.enableMotivationalMessages,
      'enablePromotions': instance.enablePromotions,
      'enableSystemNotifications': instance.enableSystemNotifications,
      'preferredTime': instance.preferredTime,
      'reminderDays': instance.reminderDays,
      'reminderFrequency': instance.reminderFrequency,
    };

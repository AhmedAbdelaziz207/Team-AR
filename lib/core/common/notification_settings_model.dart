import 'package:json_annotation/json_annotation.dart';

part 'notification_settings_model.g.dart';

@JsonSerializable()
class NotificationSettingsModel {
  final bool enableNotifications;
  final bool enableSound;
  final bool enableVibration;
  final bool enableWorkoutReminders;
  final bool enableMotivationalMessages;
  final bool enablePromotions;
  final bool enableSystemNotifications;
  final String preferredTime; // HH:mm format
  final List reminderDays; // 0 = Sunday, 1 = Monday, etc.
  final int reminderFrequency; // في الساعات

  const NotificationSettingsModel({
    this.enableNotifications = true,
    this.enableSound = true,
    this.enableVibration = true,
    this.enableWorkoutReminders = true,
    this.enableMotivationalMessages = true,
    this.enablePromotions = false,
    this.enableSystemNotifications = true,
    this.preferredTime = '09:00',
    this.reminderDays = const [1, 2, 3, 4, 5], // Weekdays
    this.reminderFrequency = 24,
  });

  factory NotificationSettingsModel.fromJson(Map<String,dynamic> json) =>
      _$NotificationSettingsModelFromJson(json);

  Map toJson() => _$NotificationSettingsModelToJson(this);

  NotificationSettingsModel copyWith({
    bool? enableNotifications,
    bool? enableSound,
    bool? enableVibration,
    bool? enableWorkoutReminders,
    bool? enableMotivationalMessages,
    bool? enablePromotions,
    bool? enableSystemNotifications,
    String? preferredTime,
    List? reminderDays,
    int? reminderFrequency,
  }) {
    return NotificationSettingsModel(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      enableWorkoutReminders: enableWorkoutReminders ?? this.enableWorkoutReminders,
      enableMotivationalMessages: enableMotivationalMessages ?? this.enableMotivationalMessages,
      enablePromotions: enablePromotions ?? this.enablePromotions,
      enableSystemNotifications: enableSystemNotifications ?? this.enableSystemNotifications,
      preferredTime: preferredTime ?? this.preferredTime,
      reminderDays: reminderDays ?? this.reminderDays,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
    );
  }
}
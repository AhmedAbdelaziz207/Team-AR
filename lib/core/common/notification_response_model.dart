import 'package:json_annotation/json_annotation.dart';

part 'notification_response_model.g.dart';

@JsonSerializable()
class NotificationResponseModel {
  final String notificationId;
  final String actionType;
  final DateTime responseTime;
  final Map<String, dynamic>? payload;

  const NotificationResponseModel({
    required this.notificationId,
    required this.actionType,
    required this.responseTime,
    this.payload,
  });


  factory NotificationResponseModel.fromJson(Map<String,dynamic> json) =>
      _$NotificationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationResponseModelToJson(this);
}

enum NotificationAction {
  tap('tap'),
  dismiss('dismiss'),
  actionButton1('action_button_1'),
  actionButton2('action_button_2');

  const NotificationAction(this.value);
  final String value;
}
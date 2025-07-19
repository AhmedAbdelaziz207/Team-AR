import 'package:json_annotation/json_annotation.dart';
import 'notification_type_enum.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? payload;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool isRead;
  final bool isLocal;
  final String? imageUrl;
  final Map<String, dynamic>? customData;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.payload,
    required this.createdAt,
    this.scheduledAt,
    this.isRead = false,
    this.isLocal = true,
    this.imageUrl,
    this.customData,
  });


  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);


  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? payload,
    DateTime? createdAt,
    DateTime? scheduledAt,
    bool? isRead,
    bool? isLocal,
    String? imageUrl,
    Map<String, dynamic>? customData, // ✅ تم التعديل هنا
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isRead: isRead ?? this.isRead,
      isLocal: isLocal ?? this.isLocal,
      imageUrl: imageUrl ?? this.imageUrl,
      customData: customData ?? this.customData,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

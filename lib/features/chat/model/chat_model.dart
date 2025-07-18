import 'package:json_annotation/json_annotation.dart';
part 'chat_model.g.dart';
@JsonSerializable()
class ChatMessageModel {
  int? id;
  String? senderId;
  String? senderName;
  String? receiverId;
  String? receiverName;
  bool? isRead;
  int? messageType;
  String? message;
  String? timestamp;

  ChatMessageModel({
    this.id,
    this.senderId,
    this.senderName,
    this.receiverId,
    this.receiverName,
    this.isRead,
    this.messageType,
    this.message,
    this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

}

/*
{
    "id": 0,
    "senderId": "string",
    "senderName": "string",
    "receiverId": "string",
    "receiverName": "string",
    "isRead": true,
    "messageType": 1,
    "message": "string",
    "timestamp": "2025-06-09T02:23:55.450Z"
  }

 */
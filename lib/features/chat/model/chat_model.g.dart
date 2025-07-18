// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: (json['id'] as num?)?.toInt(),
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      receiverId: json['receiverId'] as String?,
      receiverName: json['receiverName'] as String?,
      isRead: json['isRead'] as bool?,
      messageType: (json['messageType'] as num?)?.toInt(),
      message: json['message'] as String?,
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'receiverId': instance.receiverId,
      'receiverName': instance.receiverName,
      'isRead': instance.isRead,
      'messageType': instance.messageType,
      'message': instance.message,
      'timestamp': instance.timestamp,
    };

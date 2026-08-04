import 'dart:developer';

import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/features/notification/services/local_notification_service.dart';
import 'package:team_ar/core/common/notification_model.dart';
import 'package:team_ar/core/common/notification_type_enum.dart';

import '../utils/app_constants.dart';
import 'api_endpoints.dart';

class SignalRService {
  late HubConnection _connection;
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  String? _currentUserId;

  Future<void> connect(
      String userId,
      void Function(String senderId, String message, String data)
          onMessage) async {
    _currentUserId = userId;
    _connection = HubConnectionBuilder()
        .withUrl(
          '${ApiEndPoints.baseUrl}chathub?userId=$userId',
          options: HttpConnectionOptions(
            accessTokenFactory: () async =>
                await SharedPreferencesHelper.getString(AppConstants.token) ??
                "",
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection.on("ReceiveMessage", (args) {
      if (args == null || args.isEmpty) return;
      String senderId = args[0] as String;
      String message = args.length > 1 ? args[1] as String : "";
      String data = args.length > 2 ? args[2] as String : "";
      
      // إرسال إشعار محلي عند استلام رسالة جديدة (فقط إذا كان المستلم هو المستخدم الحالي)
      if (_currentUserId != senderId) {
        _showChatNotification(senderId, message);
      }
      
      onMessage(senderId, message, data);
    });

    try {
      await _connection.start();
      print("✅ SignalR connected.");
      
      // تهيئة خدمة الإشعارات المحلية
      await _localNotificationService.initialize();
    } catch (e) {
      print("❌ Failed to connect to SignalR: $e");
    }
  }

  // دالة لعرض إشعار محلي للدردشة
  Future<void> _showChatNotification(String senderId, String message) async {
    try {
      // الحصول على اسم المرسل (يمكن تنفيذ هذا بطرق مختلفة حسب هيكل التطبيق)
      String senderName = await _getSenderName(senderId) ?? "مستخدم";
      
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "رسالة جديدة من $senderName",
        body: message,
        type: NotificationType.chatMessage,  // استخدام نوع الإشعار الجديد
        createdAt: DateTime.now(),
        payload: '{"senderId": "$senderId", "type": "chat"}',
        isRead: false,
      );
      
      await _localNotificationService.showNotification(notification);
    } catch (e) {
      print("❌ Failed to show chat notification: $e");
    }
  }
  
  // دالة للحصول على اسم المرسل
  Future<String?> _getSenderName(String senderId) async {
    // يمكن تنفيذ هذا بالاعتماد على كيفية تخزين بيانات المستخدمين في التطبيق
    // مثال بسيط: يمكن استخدام SharedPreferences لتخزين أسماء المستخدمين المعروفة
    return await SharedPreferencesHelper.getString('user_name_$senderId');
  }

  Future<void> sendMessage(
      String senderId, String receiverId, String message) async {
    try {
      if (_connection.state != HubConnectionState.Connected) {
        log("🚫 SignalR not connected yet. Attempting start... Current state: ${_connection.state}");
        await _connection.start();
      }

      await _connection.invoke(
        "SendMessageToUser",
        args: [senderId, receiverId, message],
      );

      log("📩 Message sent successfully. $senderId -> $receiverId: $message");
    } catch (e) {
      log("🚫 SignalR sendMessage error: $e");
    }
  }

  Future<void> disconnect() async {
    await _connection.stop();
  }
}

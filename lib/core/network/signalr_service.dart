import 'dart:developer';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:team_ar/core/utils/app_constants.dart';

import '../prefs/shared_pref_manager.dart';
import 'api_endpoints.dart';

class SignalRService {
  late HubConnection _connection;

  Future<void> connect(
      String userId,
      void Function(String senderId, String message, String data)
          onMessage) async {
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
      String senderId = args?[0] as String;
      String message = args?[1] as String;
      String data = args?[2] as String;
      onMessage(senderId, message, data);
    });

    try {
      await _connection.start();
      print("✅ SignalR connected.");
    } catch (e) {
      print("❌ Failed to connect to SignalR: $e");
    }
  }

  Future<void> sendMessage(
      String senderId, String receiverId, String message) async {
    if (_connection.state != HubConnectionState.Connected) {
      print(
          "🚫 SignalR not connected yet. Current state: ${_connection.state}");
      return;
    }
    try {
      await _connection.invoke(
        "SendMessageToUser",
        args: [senderId, receiverId, message],
      );

      log("📩 Message sent successfully. $senderId -> $receiverId: $message");
    } catch (e) {
      print("🚫 SignalR : $e");
    }
  }

  Future<void> disconnect() async {
    await _connection.stop();
  }
}

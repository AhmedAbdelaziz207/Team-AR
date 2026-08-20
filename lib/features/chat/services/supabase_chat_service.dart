import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:team_ar/features/chat/model/chat_model.dart';
import 'package:team_ar/features/chat/model/chat_user_model.dart';

class SupabaseChatService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Continuous HTTP REST polling stream (fetches messages every 2 seconds).
  Stream<List<ChatMessageModel>> getChatStream(
      String currentUserId, String otherUserId) async* {
    log("getChatStream started: currentUserId=$currentUserId, otherUserId=$otherUserId");
    while (true) {
      try {
        final response = await _client
            .from('chats')
            .select()
            .or('and(sender_id.eq.$currentUserId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$currentUserId)')
            .order('created_at', ascending: true);

        final List<dynamic> maps = response as List<dynamic>;
        log("getChatStream: fetched ${maps.length} messages between $currentUserId <-> $otherUserId");

        final messages = maps
            .map((msg) => ChatMessageModel(
                  senderId: msg['sender_id']?.toString(),
                  receiverId: msg['receiver_id']?.toString(),
                  message: msg['message']?.toString(),
                  timestamp: msg['created_at']?.toString(),
                  isRead: msg['is_read'] is bool ? msg['is_read'] as bool : false,
                ))
            .toList();

        yield messages;
      } catch (e) {
        log("Supabase REST Polling Error: $e");
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> sendMessage(
      String senderId, String receiverId, String message) async {
    await _client.from('chats').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Finds the trainer's ID by looking for messages sent TO the trainee.
  /// Since the trainer always initiates or sends to the trainee, their sender_id
  /// will appear as receiver_id=traineeId rows.
  Future<String?> getTrainerIdForTrainee(String traineeId) async {
    try {
      final response = await _client
          .from('chats')
          .select('sender_id')
          .eq('receiver_id', traineeId)
          .order('created_at', ascending: false)
          .limit(1);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isNotEmpty) {
        final trainerId = data.first['sender_id']?.toString();
        log("getTrainerIdForTrainee: found trainer id=$trainerId");
        return trainerId;
      }
    } catch (e) {
      log("getTrainerIdForTrainee error: $e");
    }
    return null;
  }

  /// Fetches recent chat contacts from Supabase (fallback when REST backend is unavailable).
  Future<List<ChatUserModel>> getRecentChatsFromSupabase(
      String currentUserId) async {
    try {
      final response = await _client
          .from('chats')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      final Map<String, ChatUserModel> userMap = {};

      for (var msg in data) {
        final String? senderId = msg['sender_id']?.toString();
        final String? receiverId = msg['receiver_id']?.toString();
        final String? timestamp = msg['created_at']?.toString();

        final String? otherId =
            (senderId == currentUserId) ? receiverId : senderId;

        if (otherId != null &&
            otherId.isNotEmpty &&
            !userMap.containsKey(otherId)) {
          userMap[otherId] = ChatUserModel(
            id: otherId,
            userName: 'مستخدم $otherId',
            email: '',
            lastMessageDateTime: timestamp,
          );
        }
      }

      return userMap.values.toList();
    } catch (e) {
      log("Error fetching users from Supabase: $e");
      return [];
    }
  }
}

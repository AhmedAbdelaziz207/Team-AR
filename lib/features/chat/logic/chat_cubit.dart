import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:team_ar/features/chat/model/chat_user_model.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/api_service.dart';
import '../model/chat_model.dart';
import '../services/chat_storage.dart';
import '../services/supabase_chat_service.dart';
import '../../follow_up/services/follow_up_service.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());
  ApiService apiService = getIt<ApiService>();
  final ChatStorage _chatStorage = ChatStorage();

  void getAllChats() async {
    emit(GetChatsLoading());
    try {
      // محاولة استرجاع البيانات من الخادم
      final chats = await apiService.getAllChas();

      // حفظ البيانات في التخزين المؤقت
      await _chatStorage.saveUsers(chats);
      await _chatStorage.saveLastSyncTime();

      log("chats: ${chats[0].userName}");
      emit(GetChatsSuccess(chats: chats));
    } catch (e) {
      log("getAllChats Backend Error: $e");
      // في حالة فشل الاتصال، استرجاع البيانات من التخزين المؤقت
      final cachedChats = await _chatStorage.getUsers();

      if (cachedChats.isNotEmpty) {
        if (!isClosed) {
          emit(GetChatsSuccess(chats: cachedChats, isFromCache: true));
        }
      } else {
        // في حالة عدم وجود تخزين مؤقت، جلب المحادثات السابقة من Supabase
        try {
          final currentUserId = await SharedPreferencesHelper.getString(AppConstants.userId);
          final supabaseChats = await _supabaseChat.getRecentChatsFromSupabase(currentUserId ?? "");
          if (supabaseChats.isNotEmpty) {
            if (!isClosed) {
              emit(GetChatsSuccess(chats: supabaseChats, isFromCache: true));
            }
            return;
          }
        } catch (_) {}

        final errorMessage = ApiErrorHandler.handle(e).getErrorsMessage();
        if (!isClosed) emit(GetChatsFailure(message: errorMessage.toString()));
      }
    }
  }

  void getChatContent(id) async {
    emit(GetChatContentLoading());

    try {
      // محاولة استرجاع البيانات من الخادم
      List<ChatMessageModel> chats = await apiService.getChat(id);

      // حفظ البيانات في التخزين المؤقت
      await _chatStorage.saveMessages(id, chats);

      if (!isClosed) emit(GetChatContentSuccess(chatContent: chats));
    } catch (e) {
      log("GetChatContent Error: $e");
      // في حالة فشل الاتصال، استرجاع البيانات من التخزين المؤقت
      final cachedMessages = await _chatStorage.getMessages(id);

      if (cachedMessages.isNotEmpty) {
        if (!isClosed) {
          emit(GetChatContentSuccess(
              chatContent: cachedMessages, isFromCache: true));
        }
      } else {
        final errorMessage = ApiErrorHandler.handle(e).getErrorsMessage();
        emit(GetChatContentFailed(message: errorMessage.toString()));
      }
    }
  }

  final SupabaseChatService _supabaseChat = SupabaseChatService();
  final FollowUpService _followUp = FollowUpService();

  void sendMessage(message, receiverId) async {
    emit(SendMessageLoading());

    try {
      final currentUserId = await SharedPreferencesHelper.getString(AppConstants.userId);

      // 1. Send via Supabase (real-time chat stream)
      await _supabaseChat.sendMessage(currentUserId ?? "", receiverId, message);

      // 2. Notify backend to trigger FCM push notification to the recipient
      try {
        await apiService.sendMessage({
          'receiverId': receiverId,
          'message': message,
        });
        log("Backend apiService.sendMessage triggered successfully for receiver: $receiverId");
      } catch (apiError) {
        log("Backend apiService.sendMessage non-fatal error: $apiError");
      }
      
      // Update the follow-up timestamp if admin
      final role = await SharedPreferencesHelper.getString(AppConstants.userRole);
      if (role?.toLowerCase() == 'admin') {
        await _followUp.updateChatTimestamp(receiverId);
      } else {
        await _followUp.updateChatTimestamp(currentUserId ?? "");
      }

      if (!isClosed) emit(SendMessageSuccess());
    } catch (e) {
      log("SendMessage Error: $e");
      final errorMessage = ApiErrorHandler.handle(e).getErrorsMessage();
      if (!isClosed) emit(SendMessageFailed(message: errorMessage.toString()));
    }
  }

  // حفظ رسالة محلياً (تستخدم عند إرسال رسالة جديدة)
  Future<void> saveMessageLocally(ChatMessageModel message) async {
    await _chatStorage.addMessage(message.receiverId!, message);
    if (!isClosed) emit(SendMessageSuccess());
  }
}

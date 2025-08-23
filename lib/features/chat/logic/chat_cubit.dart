import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:team_ar/features/chat/model/chat_user_model.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/api_service.dart';
import '../model/chat_model.dart';
import '../services/chat_storage.dart';

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
      // في حالة فشل الاتصال، استرجاع البيانات من التخزين المؤقت
      final cachedChats = await _chatStorage.getUsers();

      if (cachedChats.isNotEmpty) {
        if (!isClosed)
          emit(GetChatsSuccess(chats: cachedChats, isFromCache: true));
      } else {
        final errorMessage = ApiErrorHandler.handle(e).getErrorsMessage();
        emit(GetChatsFailure(message: errorMessage.toString()));
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
      // في حالة فشل الاتصال، استرجاع البيانات من التخزين المؤقت
      final cachedMessages = await _chatStorage.getMessages(id);

      if (cachedMessages.isNotEmpty) {
        if (!isClosed)
          emit(GetChatContentSuccess(
              chatContent: cachedMessages, isFromCache: true));
      } else {
        final errorMessage = ApiErrorHandler.handle(e).getErrorsMessage();
        emit(GetChatContentFailed(message: errorMessage.toString()));
      }
    }
  }

  void sendMessage(message, receiverId) async {
    emit(SendMessageLoading());

    try {
      await apiService.sendMessage({
        "message": message,
        "receiverId": receiverId,
      });
      if (!isClosed) emit(SendMessageSuccess());
    } catch (e) {
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

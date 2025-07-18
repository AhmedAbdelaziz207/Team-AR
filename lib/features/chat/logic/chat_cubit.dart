import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;

import '../../../core/di/dependency_injection.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/api_service.dart';
import '../../auth/register/model/user_model.dart';
import '../model/chat_model.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());
  ApiService apiService = getIt<ApiService>();

  void getAllChats() async {
    emit(GetChatsLoading());
    try {
      List<UserModel> chats = await apiService.getAllChas();
      chats = [
        UserModel(
          userName: "Ahmed Ali",
          id: 1,
          email: "ahmed@user.com",
          age: 21,
          phone: "01012121212",
        ),
        UserModel(
          userName: "Omar Mostafa",
          id: 1,
          email: "omar@trainer.com",
          age: 21,
          phone: "01012121212",
        ),
      ];
      emit(GetChatsSuccess(chats: chats));
    } catch (e) {
      final errorMessage = ApiErrorHandler.handle(e).getErrorsMessage();
      emit(GetChatsFailure(message: errorMessage.toString()));
    }
  }

  void getChatContent(id) async {
    emit(GetChatContentLoading());

    try {
      List<ChatMessageModel> chats = await apiService.getChat(id);
      emit(GetChatContentSuccess(chatContent: chats));
    } catch (e) {
      final errorMessage = ApiErrorHandler.handle(e).getErrorsMessage();
      emit(GetChatContentFailed(message: errorMessage.toString()));
    }
  }

  void sendMessage(message, receiverId) async {
    emit(SendMessageLoading());

    try {
      await apiService.sendMessage({
        "message": message,
        "receiverId": receiverId,
      });
      emit(SendMessageSuccess());
    } catch (e) {
      final errorMessage = ApiErrorHandler.handle(e).getErrorsMessage();
      emit(SendMessageFailed(message: errorMessage.toString()));
    }
  }
}

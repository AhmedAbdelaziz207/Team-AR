part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class GetChatsSuccess extends ChatState {
  final List<ChatUserModel> chats;
  final bool isFromCache;

  GetChatsSuccess({required this.chats, this.isFromCache = false});
}

final class GetChatsFailure extends ChatState {
  final String message;

  GetChatsFailure({required this.message});
}

final class GetChatsLoading extends ChatState {}

final class GetChatContentLoading extends ChatState {}

final class GetChatContentFailed extends ChatState {
  final String message;

  GetChatContentFailed({required this.message});
}

final class GetChatContentSuccess extends ChatState {
  final List<ChatMessageModel> chatContent;
  final bool isFromCache;

  GetChatContentSuccess({required this.chatContent, this.isFromCache = false});
}

final class SendMessageLoading extends ChatState {}

final class SendMessageFailed extends ChatState {
  final String message;

  SendMessageFailed({required this.message});
}

final class SendMessageSuccess extends ChatState {}

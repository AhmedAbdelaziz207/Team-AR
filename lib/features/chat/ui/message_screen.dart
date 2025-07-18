import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import '../../../core/network/signalr_service.dart';
import '../../auth/register/model/user_model.dart';
import '../logic/chat_cubit.dart';
import '../model/chat_model.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.receiver});

  final UserModel receiver;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessageModel> _historyMessages = [];
  final List<ChatMessageModel> _liveMessages = [];

  String? currentUserId;

  final signalR = SignalRService();

  @override
  void initState() {
    super.initState();

    SharedPreferencesHelper.getString(AppConstants.userId).then(
      (value) {
        setState(() {
          currentUserId = value;
        });
      },
    );

    // 1️⃣ تحميل الرسائل القديمة من Cubit
    // context.read<ChatCubit>().getChatContent(widget.receiver.id!);

    // signalR.connect(currentUserId!, (senderId, messageId, message) {
    //   log("senderId: $senderId, message: $message, messageId: $messageId");
    //   final newMsg = ChatMessageModel(
    //     senderId: senderId,
    //     receiverId: widget.receiver.id.toString(),
    //     message: message,
    //     timestamp: DateTime.now().toIso8601String(),
    //   );
    //
    //   setState(() {
    //     _liveMessages.add(newMsg);
    //   });
    // });
  }

  void _sendMessage(String text) {
    final myId = currentUserId ;
    final receiverId = widget.receiver.id;

    final msg = ChatMessageModel(
      senderId: myId!,
      receiverId: receiverId.toString(),
      message: text,
      timestamp: DateTime.now().toIso8601String(),
    );

    setState(() {
      _liveMessages.add(msg);
    });

    signalR.sendMessage(myId, receiverId.toString(), text);
    context.read<ChatCubit>().sendMessage(text, receiverId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.receiver.userName ?? "",
                style: TextStyle(color: Colors.white, fontSize: 20.sp)),
            Text(
              'Trainer',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
        ],
        backgroundColor: const Color(0xff102E50),
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          BlocListener<ChatCubit, ChatState>(
            listenWhen: (previous, current) => current is GetChatContentSuccess,
            listener: (context, state) {
              if (state is GetChatContentSuccess) {
                setState(() {
                  _historyMessages.clear();
                  _historyMessages.addAll(state.chatContent);
                });
              }
            },
            child: Expanded(
              child: Builder(builder: (context) {
                final allMessages = [..._historyMessages, ..._liveMessages];
                allMessages.sort((a, b) => b.timestamp!
                    .compareTo(a.timestamp!)); // ترتيب تنازلي حسب الوقت

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: allMessages.length,
                  itemBuilder: (context, index) {
                    final msg = allMessages[index];
                    final isMe = msg.senderId == currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xff0084FF)
                              : const Color(0xffE4E6EB),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              msg.message ?? "",
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(msg.timestamp) ?? "",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const Divider(height: 1),
          Container(
            color: const Color(0xff102E50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Write a message...',
                        filled: true,
                        fillColor: const Color(0xffF0F0F0),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final text = _controller.text.trim();
                        if (text.isNotEmpty) {
                          _sendMessage(text);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "";

    try {
      final dateTime = DateTime.parse(timestamp);
      final formattedTime = TimeOfDay.fromDateTime(dateTime).format(
        context,
      );
      return formattedTime;
    } catch (e) {
      return "";
    }
  }
}

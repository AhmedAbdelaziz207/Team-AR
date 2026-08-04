import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/chat/model/chat_user_model.dart';
import 'package:team_ar/features/notification/services/push_notifications_services.dart';
import '../../../core/network/signalr_service.dart';
import '../logic/chat_cubit.dart';
import '../model/chat_model.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.receiver});

  final ChatUserModel receiver;

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

        FirebaseNotificationsServices.subscribeToTopic("chat_$value");

        signalR.connect(currentUserId!, (senderId, message, data) {
          log("Message Content: $senderId, message: $message, data: $data");
          final newMsg = ChatMessageModel(
            senderId: senderId,
            receiverId: widget.receiver.id,
            message: message,
            timestamp: DateTime.now().toIso8601String(),
          );

          setState(() {
            _liveMessages.add(newMsg);
          });
        });
      },
    );

    context.read<ChatCubit>().getChatContent(widget.receiver.id!);
  }

  @override
  void dispose() {
    if (currentUserId != null) {
      FirebaseNotificationsServices.unSubscribeFromTopic("chat_$currentUserId");
    }
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    final myId = currentUserId;
    final receiverId = widget.receiver.id;

    if (myId == null || receiverId == null) return;

    final msg = ChatMessageModel(
      senderId: myId,
      receiverId: receiverId,
      message: text,
      timestamp: DateTime.now().toIso8601String(),
    );

    setState(() {
      _liveMessages.add(msg);
    });

    context.read<ChatCubit>().saveMessageLocally(msg);
    signalR.sendMessage(myId, receiverId, text);
    context.read<ChatCubit>().sendMessage(text, receiverId);
  }

  @override
  Widget build(BuildContext context) {
    final String initialChar = (widget.receiver.userName != null && widget.receiver.userName!.trim().isNotEmpty)
        ? widget.receiver.userName!.trim().substring(0, 1).toUpperCase()
        : "?";

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        leading: const AppBarBackButton(),
        centerTitle: false,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.newSecondaryColor.withOpacity(0.12),
                  child: Text(
                    initialChar,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.newSecondaryColor,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10.r,
                    height: 10.r,
                    decoration: BoxDecoration(
                      color: const Color(0xff4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiver.userName ?? "مستخدم",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "متصل الآن",
                    style: TextStyle(
                      color: const Color(0xff4CAF50),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            BlocListener<ChatCubit, ChatState>(
              listenWhen: (previous, current) => current is GetChatContentSuccess,
              listener: (context, state) {
                if (state is GetChatContentSuccess) {
                  setState(() {
                    _historyMessages.clear();
                    _historyMessages.addAll(state.chatContent);
                  });

                  if (state.isFromCache) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'أنت تعرض بيانات محفوظة محلياً. قم بالاتصال بالإنترنت للحصول على أحدث الرسائل.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: Expanded(
                child: Builder(builder: (context) {
                  final allMessages = [..._historyMessages, ..._liveMessages];
                  allMessages.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

                  if (allMessages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mark_chat_read_rounded,
                            size: 60.sp,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "ابدأ المحادثة الآن...",
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    itemCount: allMessages.length,
                    itemBuilder: (context, index) {
                      final msg = allMessages[index];
                      final isMe = msg.senderId == currentUserId;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 4.h,
                            bottom: 4.h,
                            left: isMe ? 40.w : 0,
                            right: isMe ? 0 : 40.w,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            gradient: isMe
                                ? LinearGradient(
                                    colors: [
                                      AppColors.newSecondaryColor,
                                      AppColors.newPrimaryColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isMe ? null : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.r),
                              topRight: Radius.circular(16.r),
                              bottomLeft: Radius.circular(isMe ? 16.r : 2.r),
                              bottomRight: Radius.circular(isMe ? 2.r : 16.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: isMe ? null : Border.all(color: Colors.grey.withOpacity(0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.message ?? "",
                                style: TextStyle(
                                  color: isMe ? Colors.white : AppColors.black,
                                  fontSize: 14.5.sp,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime(msg.timestamp),
                                    style: TextStyle(
                                      color: isMe ? Colors.white.withOpacity(0.75) : AppColors.grey,
                                      fontSize: 10.5.sp,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.done_all_rounded,
                                      size: 14.sp,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ],
                                ],
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF0F3F8),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(fontSize: 14.5.sp, color: AppColors.black),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك هنا...',
                          hintStyle: TextStyle(fontSize: 13.5.sp, color: AppColors.grey),
                          contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.newSecondaryColor,
                          AppColors.newPrimaryColor,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.newPrimaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send_rounded, color: Colors.white, size: 20.sp),
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
          ],
        ),
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

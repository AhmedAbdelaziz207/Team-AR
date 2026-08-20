import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/chat/model/chat_user_model.dart';
import '../logic/chat_cubit.dart';
import '../model/chat_model.dart';
import '../services/supabase_chat_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.receiver});

  final ChatUserModel receiver;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _controller = TextEditingController();
  final SupabaseChatService _supabaseChat = SupabaseChatService();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.getString(AppConstants.userId).then((value) {
      if (value != null && mounted) {
        setState(() {
          currentUserId = value;
        });
      }
    });
  }

  void _sendMessage(String text) {
    if (currentUserId == null) return;
    context.read<ChatCubit>().sendMessage(text, widget.receiver.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.receiver.userName ?? "", style: TextStyle(color: Colors.white, fontSize: 20.sp)),
            Text('Trainer', style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        backgroundColor: const Color(0xff102E50),
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/chat_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: currentUserId == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<List<ChatMessageModel>>(
                      stream: _supabaseChat.getChatStream(currentUserId!, widget.receiver.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        final allMessages = snapshot.data ?? [];
                        final reversedMessages = allMessages.reversed.toList();

                        return ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(12),
                          itemCount: reversedMessages.length,
                          itemBuilder: (context, index) {
                            final msg = reversedMessages[index];
                            final isMe = msg.senderId == currentUserId;

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe ? const Color(0xff0084FF) : const Color(0xffE4E6EB),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 16 : 0),
                                    bottomRight: Radius.circular(isMe ? 0 : 16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.message ?? "",
                                      style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(msg.timestamp) ?? "",
                                      style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            Container(
              color: const Color(0xff102E50),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
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
          ],
        ),
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "";
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      return TimeOfDay.fromDateTime(dateTime).format(context);
    } catch (e) {
      return "";
    }
  }
}

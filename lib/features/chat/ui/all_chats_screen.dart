import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';

import '../../auth/register/model/user_model.dart';
import '../logic/chat_cubit.dart';
import '../widget/chats_list_item.dart';

class AllChatsScreen extends StatefulWidget {
  const AllChatsScreen({super.key});

  @override
  State<AllChatsScreen> createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen> {
  @override
  void initState() {
    context.read<ChatCubit>().getAllChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 12.h,
              ),
              Text(
                "Chats",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: AppColors.primaryColor),
              ),
              SizedBox(
                height: 20.h,
              ),
              BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state is GetChatsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is GetChatsFailure) {
                    return Center(child: Text(state.message));
                  }
                  if (state is GetChatsSuccess && state.chats.isEmpty) {
                    return const Center(
                        child: Text(
                      "لا يوجد محادثات 🙂",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ));
                  }

                  final List<UserModel> chats =
                      state is GetChatsSuccess ? state.chats : [];
                  return Expanded(
                    child: ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          return ChatsListItem(user: chats[index]);
                        }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

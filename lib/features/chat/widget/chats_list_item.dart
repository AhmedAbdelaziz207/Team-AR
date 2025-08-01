import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/chat/model/chat_user_model.dart';

import '../../auth/register/model/user_model.dart';
import '../logic/chat_cubit.dart';

class ChatsListItem extends StatelessWidget {
  const ChatsListItem({super.key, required this.user});

  final ChatUserModel user;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.chat, arguments: user).then((value) {
          context.read<ChatCubit>().getAllChats();
        });
      },
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        leading: CircleAvatar(
          radius: 20.r,
          backgroundColor: Colors.grey.shade200,
          child: Text(
            user.userName?.substring(0, 1) ?? " ",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: AppColors.primaryColor),
          ),
        ),
        title: Text(
          "${user.userName}",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: Colors.black),
        ),
        subtitle: Text(
          user.email.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 11.sp,
              ),
        ),
        trailing: user.numOfUnReadMessages! > 0
            ? CircleAvatar(
                radius: 8.r,
                child: Text(
                  user.numOfUnReadMessages.toString(),
                  style: TextStyle(fontSize: 10.sp, color: AppColors.white),
                ),
              )
            : null,
      ),
    );
  }
}

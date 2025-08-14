import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/custom_text_form_field.dart';
import 'package:team_ar/features/chat/model/chat_user_model.dart';
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
    super.initState();
    Future.microtask(() {
      context.read<ChatCubit>().getAllChats();
    });
  }

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is GetChatsSuccess && state.isFromCache) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'أنت تعرض بيانات محفوظة محلياً. قم بالاتصال بالإنترنت للحصول على أحدث المحادثات.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GetChatsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GetChatsFailure) {
            return Center(child: Text(state.message));
          }

          final List<ChatUserModel> allChats =
              state is GetChatsSuccess ? state.chats : [];

          final List<ChatUserModel> filteredChats = allChats
              .where((chat) =>
                  chat.userName?.toLowerCase().contains(searchQuery) ?? false)
              .toList();

          // Sort by lastMessageDateTime descending (latest on top)
          filteredChats.sort((a, b) {
            final aTime = _parseDateTime(a.lastMessageDateTime);
            final bTime = _parseDateTime(b.lastMessageDateTime);
            return bTime.compareTo(aTime);
          });

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  CustomTextFormField(
                    hintText: AppLocalKeys.searchByName.tr(),
                    suffixIcon: Icons.search,
                    isAdmin: true,
                    iconColor: AppColors.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    AppLocalKeys.chats.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: AppColors.primaryColor,
                        ),
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<ChatCubit>().getAllChats();
                      },
                      child: ListView.builder(
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          return ChatsListItem(
                            user: filteredChats[index],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  DateTime _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    try {
      return DateTime.parse(dateTimeString);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0); // fallback if invalid
    }
  }
}

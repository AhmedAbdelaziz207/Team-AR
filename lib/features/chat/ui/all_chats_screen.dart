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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.forum_rounded,
                            color: AppColors.newSecondaryColor,
                            size: 26.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            AppLocalKeys.chats.tr(),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22.sp,
                                  color: AppColors.newSecondaryColor,
                                ),
                          ),
                        ],
                      ),
                      if (allChats.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.newSecondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            "${allChats.length} ${allChats.length == 1 ? 'محادثة' : 'محادثات'}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.newSecondaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CustomTextFormField(
                      hintText: AppLocalKeys.searchByName.tr(),
                      suffixIcon: Icons.search_rounded,
                      isAdmin: true,
                      iconColor: AppColors.newSecondaryColor,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<ChatCubit>().getAllChats();
                    },
                    child: filteredChats.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 80.h),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(20.r),
                                      decoration: BoxDecoration(
                                        color: AppColors.newSecondaryColor.withOpacity(0.06),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 60.sp,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      searchQuery.isNotEmpty
                                          ? "لا توجد نتائج بحث مطابقة"
                                          : "لا توجد محادثات حالياً",
                                      style: TextStyle(
                                        color: AppColors.black.withOpacity(0.7),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 20.h, top: 4.h),
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

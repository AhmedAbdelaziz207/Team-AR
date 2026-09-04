import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_assets.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/chat/model/chat_user_model.dart';
import 'package:team_ar/features/follow_up/logic/follow_up_cubit.dart';
import 'package:team_ar/features/follow_up/logic/follow_up_state.dart';
import 'package:team_ar/features/follow_up/model/follow_up_trainee.dart';
import 'package:team_ar/features/follow_up/services/follow_up_service.dart';

class FollowUpTraineesScreen extends StatefulWidget {
  final String? targetTraineeId;

  const FollowUpTraineesScreen({super.key, this.targetTraineeId});

  @override
  State<FollowUpTraineesScreen> createState() => _FollowUpTraineesScreenState();
}

class _FollowUpTraineesScreenState extends State<FollowUpTraineesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<FollowUpCubit>().loadFollowUpTrainees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const AppBarBackButton(),
        title: BlocBuilder<FollowUpCubit, FollowUpState>(
          builder: (context, state) {
            final count = state is FollowUpSuccess ? state.trainees.length : 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "متابعة المتدربين",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                        fontSize: 20.sp,
                      ),
                ),
                if (count > 0) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      "$count",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: BlocBuilder<FollowUpCubit, FollowUpState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () async {
              await context.read<FollowUpCubit>().loadFollowUpTrainees();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informative Header Banner
                        Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade50,
                                Colors.orange.shade50,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notification_important_rounded,
                                  color: Colors.red.shade700,
                                  size: 24.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "تنبيه المتابعة الذكية (+14 يوم)",
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "هؤلاء المتدربون تأخرت متابعتهم لأكثر من 14 يوماً بدون تحديث جدول الغذاء أو تواصل. تواصل معهم لتشجيعهم ومتابعة التزامهم.",
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                        fontSize: 11.5.sp,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim().toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "ابحث بالاسم أو رقم الهاتف...",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13.sp,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: AppColors.primaryColor,
                                size: 22.sp,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content Based on State
                if (state is FollowUpLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "جاري فحص المتدربين المتأخرين...",
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is FollowUpFailure)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.r),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 56.sp,
                              color: Colors.red.shade400,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "حدث خطأ أثناء تحميل البيانات",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              state.errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.grey,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton.icon(
                              onPressed: () => context
                                  .read<FollowUpCubit>()
                                  .loadFollowUpTrainees(),
                              icon: const Icon(Icons.refresh),
                              label: const Text("إعادة المحاولة"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (state is FollowUpSuccess) ...[
                  _buildTraineesList(state.trainees),
                ] else
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTraineesList(List<FollowUpTrainee> trainees) {
    final filtered = trainees.where((item) {
      final name = item.trainee.userName?.toLowerCase() ??
          item.trainee.name?.toLowerCase() ??
          '';
      final phone = item.trainee.phoneNumber ?? item.trainee.phone ?? '';
      if (_searchQuery.isEmpty) return true;
      return name.contains(_searchQuery) || phone.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.emptyPageEmpty,
                height: 160.h,
                width: 160.w,
              ),
              SizedBox(height: 16.h),
              Text(
                _searchQuery.isEmpty
                    ? "لا يوجد متدربون متأخرون عن المتابعة حالياً! 🎉"
                    : "لا توجد نتائج مطابقة لبحثك",
                style: TextStyle(
                  color: AppColors.black.withOpacity(0.7),
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),
              if (_searchQuery.isEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  "جميع المتدربين يتم متابعتهم بانتظام.",
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = filtered[index];
            final isTarget = widget.targetTraineeId != null &&
                item.trainee.id == widget.targetTraineeId;
            return _buildTraineeCard(item, isTarget);
          },
          childCount: filtered.length,
        ),
      ),
    );
  }

  Widget _buildTraineeCard(FollowUpTrainee item, bool isTarget) {
    final trainee = item.trainee;
    final name = trainee.userName ?? trainee.name ?? "متدرب";
    final phone = trainee.phoneNumber ?? trainee.phone ?? "";
    final days = item.daysDelayed;

    final DateFormat formatter = DateFormat('yyyy/MM/dd');
    final lastDietText = item.lastDietUpdate != null
        ? formatter.format(item.lastDietUpdate!)
        : "لم يتم التحديث بعد";
    final lastChatText = item.lastChatUpdate != null
        ? formatter.format(item.lastChatUpdate!)
        : "لا توجد محادثات سابقة";

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isTarget
              ? AppColors.primaryColor
              : Colors.red.withOpacity(days >= 20 ? 0.35 : 0.15),
          width: isTarget ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header of card: Avatar, Name, and Delay Badge
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: SizedBox(
                    width: 52.w,
                    height: 52.h,
                    child: trainee.image != null && trainee.image!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: trainee.image!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              child: const Icon(Icons.person,
                                  color: AppColors.primaryColor),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.person,
                                  color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: AppColors.primaryColor.withOpacity(0.12),
                            child: Icon(
                              Icons.person_rounded,
                              size: 28.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Name & Phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      if (phone.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.phone_outlined,
                                size: 13.sp, color: AppColors.grey),
                            SizedBox(width: 4.w),
                            Text(
                              phone,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Delay Badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: days >= 21
                        ? Colors.red.shade600
                        : Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: (days >= 21 ? Colors.red : Colors.orange)
                            .withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.alarm,
                        color: Colors.white,
                        size: 13.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        item.delayFormattedText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Follow-up Details Info Container
          Container(
            margin: EdgeInsets.symmetric(horizontal: 14.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restaurant_menu_rounded,
                              size: 13.sp, color: Colors.orange.shade700),
                          SizedBox(width: 4.w),
                          Text(
                            "آخر تحديث دايت:",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        lastDietText,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: item.lastDietUpdate != null
                              ? AppColors.black
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 30.h,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              size: 13.sp, color: AppColors.primaryColor),
                          SizedBox(width: 4.w),
                          Text(
                            "آخر محادثة:",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        lastChatText,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: item.lastChatUpdate != null
                              ? AppColors.black
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Action Buttons Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18.r),
                bottomRight: Radius.circular(18.r),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                // 1. Chat Button
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.chat_rounded,
                    label: "محادثة",
                    color: AppColors.primaryColor,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.chat,
                        arguments: ChatUserModel(
                          id: trainee.id,
                          userName: name,
                          phoneNumber: phone,
                        ),
                      ).then((_) {
                        if (mounted) {
                          context.read<FollowUpCubit>().loadFollowUpTrainees();
                        }
                      });
                    },
                  ),
                ),
                SizedBox(width: 6.w),

                // 2. Diet Meals Button
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.restaurant_rounded,
                    label: "الدايت",
                    color: Colors.orange.shade700,
                    onTap: () {
                      if (trainee.id != null) {
                        Navigator.pushNamed(
                          context,
                          Routes.adminUserMeals,
                          arguments: trainee.id!,
                        ).then((_) {
                          if (mounted) {
                            context.read<FollowUpCubit>().loadFollowUpTrainees();
                          }
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 6.w),

                // 3. Trainee Info Profile Button
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.person_outline_rounded,
                    label: "الملف",
                    color: Colors.blueGrey.shade700,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.userInfo,
                        arguments: trainee,
                      ).then((_) {
                        if (mounted) {
                          context.read<FollowUpCubit>().loadFollowUpTrainees();
                        }
                      });
                    },
                  ),
                ),

                // 4. Call Button (if phone is available)
                if (phone.isNotEmpty) ...[
                  SizedBox(width: 6.w),
                  InkWell(
                    onTap: () async {
                      final uri = Uri.parse("tel:$phone");
                      if (await canLaunchUrl(uri)) {
                        if (trainee.id != null) {
                          await FollowUpService().updateChatTimestamp(trainee.id!);
                          if (mounted) {
                            context.read<FollowUpCubit>().loadFollowUpTrainees();
                          }
                        }
                        await launchUrl(uri);
                      }
                    },
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Icon(
                        Icons.call_rounded,
                        color: Colors.green.shade700,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

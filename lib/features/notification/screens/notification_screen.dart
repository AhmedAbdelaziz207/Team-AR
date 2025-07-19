import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/common/notification_model.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/notification_cubit.dart';
import '../logic/notification_state.dart';
import '../widgets/notification_tile.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with AutomaticKeepAliveClientMixin {
  late NotificationCubit _notificationCubit;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _notificationCubit = context.read<NotificationCubit>();
    _loadNotifications();
  }

  void _loadNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notificationCubit.loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        bloc: _notificationCubit,
        builder: (context, state) {
          if (state is NotificationLoading) {
            return _buildLoadingState();
          }

          if (state is NotificationError) {
            return _buildErrorState(state.message);
          }

          if (state is NotificationLoaded) {
            return _buildNotificationsContent(state.notifications);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'الإشعارات',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        BlocBuilder<NotificationCubit, NotificationState>(
          bloc: _notificationCubit,
          builder: (context, state) {
            if (state is NotificationLoaded && state.notifications.isNotEmpty) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  switch (value) {
                    case 'mark_all_read':
                      _notificationCubit.markAllAsRead();
                      break;
                    case 'clear_all':
                      _showClearAllDialog();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('تحديد الكل كمقروء'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, color: Colors.red),
                        SizedBox(width: 8),
                        Text('مسح الكل'),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ في تحميل الإشعارات',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _notificationCubit.loadNotifications(),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsContent(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () async {
        _notificationCubit.loadNotifications();
      },
      child: CustomScrollView(
        slivers: [
          _buildNotificationsList(notifications),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final notification = notifications[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NotificationTile(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
                onDelete: () => _handleNotificationDelete(notification),
              ),
            );
          },
          childCount: notifications.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم عرض إشعاراتك هنا عند وصولها',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _notificationCubit.loadNotifications(),
            icon: const Icon(Icons.refresh),
            label: const Text('تحديث'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // تحديد الإشعار كمقروء
    if (!notification.isRead) {
      _notificationCubit.markAsRead(notification.id);
    }

    // يمكنك إضافة التنقل حسب نوع الإشعار هنا
    // مثال:
    // switch (notification.type) {
    //   case NotificationType.workoutPlan:
    //     Navigator.pushNamed(context, Routes.workoutPlan);
    //     break;
    //   case NotificationType.workoutReminder:
    //     Navigator.pushNamed(context, Routes.workoutSchedule);
    //     break;
    //   case NotificationType.bookingConfirmation:
    //     Navigator.pushNamed(context, Routes.bookings);
    //     break;
    //   case NotificationType.subscriptionExpiry:
    //     Navigator.pushNamed(context, Routes.subscription);
    //     break;
    //   case NotificationType.paymentConfirmation:
    //     Navigator.pushNamed(context, Routes.payments);
    //     break;
    //   case NotificationType.newContent:
    //     Navigator.pushNamed(context, Routes.content);
    //     break;
    //   case NotificationType.promotion:
    //     Navigator.pushNamed(context, Routes.promotions);
    //     break;
    //   default:
    //     break;
    // }
  }

  void _handleNotificationDelete(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الإشعار'),
        content: const Text('هل أنت متأكد من حذف هذا الإشعار؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _notificationCubit.deleteNotification(notification.id);
              Navigator.pop(context);
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح جميع الإشعارات'),
        content: const Text(
          'هل أنت متأكد من مسح جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _notificationCubit.clearAllNotifications();
              Navigator.pop(context);
            },
            child: const Text(
              'مسح الكل',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
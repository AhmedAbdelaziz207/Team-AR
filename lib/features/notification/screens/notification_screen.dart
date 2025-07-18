import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_type_enum.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/notification_cubit.dart';
import '../logic/notification_state.dart';
import '../widgets/notification_tile.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل الإشعارات عند فتح الشاشة
    context.read<NotificationCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.notifications.isNotEmpty) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'mark_all_read':
                        context.read<NotificationCubit>().markAllAsRead();
                        break;
                      case 'clear_all':
                        _showClearAllDialog(context);
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
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            );
          }

          if (state is NotificationError) {
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
                    state.message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                   SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<NotificationCubit>().loadNotifications();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: AppColors.primaryColor,
              onRefresh: () async {
                context.read<NotificationCubit>().loadNotifications();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: NotificationTile(
                      notification: notification,
                      onTap: () => _handleNotificationTap(context, notification),
                      onDelete: () => _handleNotificationDelete(context, notification),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
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
            onPressed: () {
              context.read<NotificationCubit>().loadNotifications();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('تحديث'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // تحديد الإشعار كمقروء
    if (!notification.isRead) {
      context.read<NotificationCubit>().markAsRead(notification.id);
    }

    // التنقل حسب نوع الإشعار
    switch (notification.type) {
      case NotificationType.workoutPlan:
        Navigator.pushNamed(context, '/workout-plan');
        break;
      case NotificationType.workoutReminder:
        Navigator.pushNamed(context, '/workout-schedule');
        break;
      // case NotificationType.trainerFeedback:
      //   Navigator.pushNamed(context, '/trainer-feedback');
      //   break;
      case NotificationType.bookingConfirmation:
        Navigator.pushNamed(context, '/bookings');
        break;
      case NotificationType.subscriptionExpiry:
        Navigator.pushNamed(context, '/subscription');
        break;
      case NotificationType.paymentConfirmation:
        Navigator.pushNamed(context, '/payments');
        break;
      case NotificationType.newContent:
        Navigator.pushNamed(context, '/content');
        break;
      case NotificationType.promotion:
        Navigator.pushNamed(context, '/promotions');
        break;
      default:
        break;
    }
  }

  void _handleNotificationDelete(BuildContext context, NotificationModel notification) {
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
              context.read<NotificationCubit>().deleteNotification(notification.id);
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

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح جميع الإشعارات'),
        content: const Text('هل أنت متأكد من مسح جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationCubit>().clearAllNotifications();
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
}
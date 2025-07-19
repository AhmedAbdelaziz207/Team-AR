import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/common/notification_model.dart';
import '../../../core/common/notification_type_enum.dart';
import '../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 1 : 3,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead
              ? Colors.grey.shade200
              : AppColors.primaryColor.withOpacity(0.3),
          width: notification.isRead ? 0.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isRead
                ? Colors.white
                : AppColors.primaryColor.withOpacity(0.05),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة الإشعار
              _buildNotificationIcon(),
              const SizedBox(width: 12),
              // محتوى الإشعار
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان الإشعار
                    _buildNotificationTitle(),
                    const SizedBox(height: 4),
                    // محتوى الإشعار
                    _buildNotificationBody(),
                    const SizedBox(height: 8),
                    // وقت الإشعار
                    _buildNotificationTime(),
                  ],
                ),
              ),
              // أزرار الإجراءات
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    IconData iconData;
    Color iconColor;

    // تحديد الأيقونة واللون حسب نوع الإشعار
    switch (notification.type) {
      case NotificationType.workoutPlan:
        iconData = Icons.fitness_center;
        iconColor = Colors.orange;
        break;
      case NotificationType.workoutReminder:
        iconData = Icons.alarm;
        iconColor = Colors.blue;
        break;
      case NotificationType.bookingConfirmation:
        iconData = Icons.event_available;
        iconColor = Colors.green;
        break;
      case NotificationType.subscriptionExpiry:
        iconData = Icons.warning;
        iconColor = Colors.red;
        break;
      case NotificationType.paymentConfirmation:
        iconData = Icons.payment;
        iconColor = Colors.green;
        break;
      case NotificationType.newContent:
        iconData = Icons.new_releases;
        iconColor = Colors.purple;
        break;
      case NotificationType.promotion:
        iconData = Icons.local_offer;
        iconColor = Colors.pink;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.primaryColor;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildNotificationTitle() {
    return Text(
      notification.title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
        color: notification.isRead ? Colors.grey.shade700 : Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNotificationBody() {
    return Text(
      notification.body,
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.grey.shade600,
        height: 1.3,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNotificationTime() {
    final timeAgo = _getTimeAgo(notification.createdAt);
    return Text(
      timeAgo,
      style: TextStyle(
        fontSize: 12.sp,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // نقطة تشير إلى عدم القراءة
        if (!notification.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        const SizedBox(height: 8),
        // زر الحذف
        InkWell(
          onTap: onDelete,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.delete_outline,
              size: 18,
              color: Colors.red.shade400,
            ),
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'منذ يوم واحد';
      } else if (difference.inDays < 30) {
        return 'منذ ${difference.inDays} أيام';
      } else {
        return DateFormat('dd/MM/yyyy').format(createdAt);
      }
    } else if (difference.inHours > 0) {
      if (difference.inHours == 1) {
        return 'منذ ساعة واحدة';
      } else {
        return 'منذ ${difference.inHours} ساعات';
      }
    } else if (difference.inMinutes > 0) {
      if (difference.inMinutes == 1) {
        return 'منذ دقيقة واحدة';
      } else {
        return 'منذ ${difference.inMinutes} دقائق';
      }
    } else {
      return 'منذ لحظات';
    }
  }
}
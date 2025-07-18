import '../common/notification_model.dart';
import '../common/notification_type_enum.dart';
import '../common/exceptions/notification_exceptions.dart';

class NotificationValidator {
  // Validate notification model
  static void validateNotification(NotificationModel notification) {
    if (notification.title.isEmpty) {
      throw const NotificationValidationException(
        'عنوان الإشعار لا يمكن أن يكون فارغاً',
      );
    }

    if (notification.body.isEmpty) {
      throw const NotificationValidationException(
        'محتوى الإشعار لا يمكن أن يكون فارغاً',
      );
    }

    if (notification.title.length > 100) {
      throw const NotificationValidationException(
        'عنوان الإشعار يجب أن يكون أقل من 100 حرف',
      );
    }

    if (notification.body.length > 500) {
      throw const NotificationValidationException(
        'محتوى الإشعار يجب أن يكون أقل من 500 حرف',
      );
    }

    if (notification.scheduledAt != null &&
        notification.scheduledAt!.isBefore(DateTime.now())) {
      throw const NotificationValidationException(
        'موعد الإشعار يجب أن يكون في المستقبل',
      );
    }
  }

  // Validate notification schedule time
  static void validateScheduleTime(DateTime scheduledTime) {
    final now = DateTime.now();

    if (scheduledTime.isBefore(now)) {
      throw const NotificationValidationException(
        'لا يمكن جدولة إشعار في الماضي',
      );
    }

    final maxFutureTime = now.add(const Duration(days: 365));
    if (scheduledTime.isAfter(maxFutureTime)) {
      throw const NotificationValidationException(
        'لا يمكن جدولة إشعار لأكثر من عام في المستقبل',
      );
    }
  }

  // Validate notification type for user
  static void validateTypeForUser(NotificationType type, bool isAdmin) {
    if (!isAdmin && type.isAdminNotification) {
      throw const NotificationValidationException(
        'هذا النوع من الإشعارات مخصص للمشرفين فقط',
      );
    }
  }

  // Validate notification ID
  static void validateId(String id) {
    if (id.isEmpty) {
      throw const NotificationValidationException(
        'معرف الإشعار لا يمكن أن يكون فارغاً',
      );
    }

    if (id.length < 5) {
      throw const NotificationValidationException(
        'معرف الإشعار يجب أن يكون على الأقل 5 أحرف',
      );
    }
  }

  // Validate notification settings
  static void validateSettings(Map settings) {
    if (!settings.containsKey('enableNotifications')) {
      throw const NotificationValidationException(
        'إعدادات الإشعارات يجب أن تحتوي على enableNotifications',
      );
    }

    if (settings['preferredTime'] != null) {
      final timeString = settings['preferredTime'] as String;
      if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(timeString)) {
        throw const NotificationValidationException(
          'تنسيق الوقت المفضل غير صحيح (يجب أن يكون HH:mm)',
        );
      }
    }

    if (settings['reminderDays'] != null) {
      final days = settings['reminderDays'] as List;
      if (days.any((day) => day < 0 || day > 6)) {
        throw const NotificationValidationException(
          'أيام التذكير يجب أن تكون بين 0 و 6',
        );
      }
    }
  }

  // Validate notification frequency
  static void validateFrequency(int frequency) {
    if (frequency < 1) {
      throw const NotificationValidationException(
        'تكرار الإشعار يجب أن يكون على الأقل ساعة واحدة',
      );
    }

    if (frequency > 168) { // 7 days in hours
      throw const NotificationValidationException(
        'تكرار الإشعار يجب أن يكون أقل من أسبوع',
      );
    }
  }

  // Validate notification count
  static void validateNotificationCount(int count) {
    if (count < 0) {
      throw const NotificationValidationException(
        'عدد الإشعارات لا يمكن أن يكون سالباً',
      );
    }

    if (count > 1000) {
      throw const NotificationValidationException(
        'عدد الإشعارات يجب أن يكون أقل من 1000',
      );
    }
  }

  // Validate notification image URL
  static void validateImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;

    final uri = Uri.tryParse(imageUrl);
    if (uri == null || !uri.hasAbsolutePath) {
      throw const NotificationValidationException(
        'رابط الصورة غير صحيح',
      );
    }

    if (!['http', 'https'].contains(uri.scheme)) {
      throw const NotificationValidationException(
        'رابط الصورة يجب أن يبدأ بـ http أو https',
      );
    }
  }

  // Validate notification custom data
  static void validateCustomData(Map? customData) {
    if (customData == null) return;

    if (customData.keys.any((key) => key.isEmpty)) {
      throw const NotificationValidationException(
        'مفاتيح البيانات المخصصة لا يمكن أن تكون فارغة',
      );
    }

    const maxDataSize = 1000; // characters
    final dataString = customData.toString();
    if (dataString.length > maxDataSize) {
      throw const NotificationValidationException(
        'البيانات المخصصة كبيرة جداً (أكثر من $maxDataSize حرف)',
      );
    }
  }
}
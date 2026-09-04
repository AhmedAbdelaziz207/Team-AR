enum NotificationType {
  // Client Notifications
  workoutPlan('workout_plan', 'خطة التمرين', '🏋‍♂️'),
  workoutReminder('workout_reminder', 'تذكير التمرين', '⏰'),
  trainerEvaluation('trainer_evaluation', 'تقييم المدرب', '📝'),
  bookingConfirmation('booking_confirmation', 'تأكيد الحجز', '✅'),
  bookingCancellation('booking_cancellation', 'إلغاء الحجز', '❌'),
  motivational('motivational', 'تحفيزي', '🎉'),
  subscriptionExpiry('subscription_expiry', 'انتهاء الاشتراك', '💵'),
  paymentConfirmation('payment_confirmation', 'تأكيد الدفع', '💳'),
  newContent('new_content', 'محتوى جديد', '🆕'),
  promotion('promotion', 'عرض خاص', '🛍'),
  chatMessage('chat_message', 'رسالة جديدة', '💬'),  // إضافة نوع إشعار للدردشة
  dietPlan('diet_plan', 'النظام الغذائي', '🥗'),

  // Admin Notifications
  newMember('new_member', 'عضو جديد', '👤'),
  bookingRequest('booking_request', 'طلب حجز', '📝'),
  newReview('new_review', 'تقييم جديد', '💬'),
  technicalIssue('technical_issue', 'مشكلة تقنية', '⚠️'),

  // System Notifications
  system('system', 'نظام', '🔔'),
  maintenance('maintenance', 'صيانة', '🔧');

  const NotificationType(this.value, this.arabicName, this.emoji);

  final String value;
  final String arabicName;
  final String emoji;

  static NotificationType fromValue(String value) {
    return NotificationType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }

  String get displayName => '$emoji $arabicName';

  bool get isClientNotification => [
    workoutPlan,
    workoutReminder,
    trainerEvaluation,
    bookingConfirmation,
    bookingCancellation,
    motivational,
    subscriptionExpiry,
    paymentConfirmation,
    newContent,
    promotion,
    chatMessage,
    dietPlan,
  ].contains(this);

  bool get isAdminNotification => [
    newMember,
    bookingRequest,
    newReview,
    technicalIssue,
  ].contains(this);

  bool get isSystemNotification => [
    system,
    maintenance,
  ].contains(this);
}
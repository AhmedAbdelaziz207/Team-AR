class SubscriptionConfig {
  static const int WARNING_DAYS = 3;
  static const int CACHE_DURATION_MINUTES = 10;
  static const int MAX_LOG_SIZE_MB = 1;
  static const bool ENABLE_LOGGING = true;
  static const bool ENABLE_NOTIFICATIONS = true;
  static const bool ENABLE_CACHE = true;

  static const List<int> REMINDER_DAYS = [7, 3, 1];
  static const String NOTIFICATION_CHANNEL_ID = 'subscription_channel';
  static const String NOTIFICATION_CHANNEL_NAME = 'Subscription Notifications';
}
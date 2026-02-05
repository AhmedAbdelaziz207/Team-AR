class AppConfig {
  // TODO: After approval, control this remotely (Firebase Remote Config or backend).
  static bool isAppReleased = false;

  static Future<void> initialize(
      {required Future<bool> Function() fetchIsReleased}) async {
    try {
      final remoteValue = await fetchIsReleased();
      isAppReleased = remoteValue;
    } catch (_) {
      // Keep default (false) on any failure to avoid enabling payment during review.
      isAppReleased = false;
    }
  }
}

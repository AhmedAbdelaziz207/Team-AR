import 'dart:developer';
import 'package:screen_protector/screen_protector.dart';

// Central service to protect PDF screens from screenshots and screen recording
class PdfProtectionService {
  // Enable protection - call in initState of every PDF screen
  static Future<void> enable() async {
    try {
      await ScreenProtector.preventScreenshotOn();
      log('PDF screen protection ENABLED');
    } catch (e) {
      log('Failed to enable screen protection: $e');
    }
  }

  // Disable protection - call in dispose of every PDF screen
  static Future<void> disable() async {
    try {
      await ScreenProtector.preventScreenshotOff();
      log('PDF screen protection DISABLED');
    } catch (e) {
      log('Failed to disable screen protection: $e');
    }
  }
}

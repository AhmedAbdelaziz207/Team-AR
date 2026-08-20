import 'dart:developer';
import 'package:screen_protector/screen_protector.dart';

// Central service to protect PDF screens from screenshots and screen recording
class PdfProtectionService {
  static int _activeCount = 0;

  // Enable protection - call in initState of every PDF/Diet screen
  static Future<void> enable() async {
    try {
      _activeCount++;
      if (_activeCount == 1) {
        await ScreenProtector.preventScreenshotOn();
        log('PDF screen protection ENABLED');
      } else {
        log('PDF screen protection ALREADY ENABLED (Count: $_activeCount)');
      }
    } catch (e) {
      log('Failed to enable screen protection: $e');
    }
  }

  // Disable protection - call in dispose of every PDF/Diet screen
  static Future<void> disable() async {
    try {
      if (_activeCount > 0) {
        _activeCount--;
      }
      if (_activeCount == 0) {
        await ScreenProtector.preventScreenshotOff();
        log('PDF screen protection DISABLED');
      } else {
        log('PDF screen protection STILL ACTIVE (Count: $_activeCount)');
      }
    } catch (e) {
      log('Failed to disable screen protection: $e');
    }
  }
}

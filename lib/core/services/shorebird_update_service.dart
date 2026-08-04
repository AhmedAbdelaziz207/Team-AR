import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Service to handle automatic Shorebird OTA code push updates for Team-AR
class ShorebirdUpdateService {
  ShorebirdUpdateService._();
  static final ShorebirdUpdateService _instance = ShorebirdUpdateService._();
  factory ShorebirdUpdateService() => _instance;

  final _updater = ShorebirdUpdater();

  Future<void> initialize() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        final isAvailable = _updater.isAvailable;
        if (isAvailable) {
          debugPrint('🐦 [Shorebird Team-AR] Available on this device.');

          final currentPatch = await _updater.readCurrentPatch();
          debugPrint(
            '🐦 [Shorebird Team-AR] Current Patch: ${currentPatch?.number ?? "Base Release (No Patch)"}',
          );

          // Check for updates in background
          _checkForUpdates();
        } else {
          debugPrint('🐦 [Shorebird Team-AR] Not available in this environment');
        }
      } catch (e, stackTrace) {
        debugPrint('♦️ [Shorebird Error] Initialization failed: $e');
        debugPrint(stackTrace.toString());
      }
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      debugPrint('🐦 [Shorebird Team-AR] Checking for new patches...');
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        debugPrint(
          '🐦 [Shorebird Team-AR] New Patch Available! Downloading in background...',
        );

        await _updater.update();

        debugPrint(
          '🐦 [Shorebird Team-AR] Patch downloaded successfully. Will be applied on next restart.',
        );
      } else {
        debugPrint('🐦 [Shorebird Team-AR] No new patch available.');
      }
    } catch (e, stackTrace) {
      debugPrint('♦️ [Shorebird Error] Update Check/Download failed: $e');
      debugPrint(stackTrace.toString());
    }
  }
}

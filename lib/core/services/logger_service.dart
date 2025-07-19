import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  static const String LOG_FILE_NAME = 'subscription_logs.txt';
  static const int MAX_LOG_SIZE = 1024 * 1024; // 1MB

  late File _logFile;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/$LOG_FILE_NAME');

      if (!await _logFile.exists()) {
        await _logFile.create();
      }

      _initialized = true;
      info('Logger service initialized');
    } catch (e) {
      developer.log('Failed to initialize logger: $e');
    }
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _log('DEBUG', message, error, stackTrace);
    }
  }

  void _log(String level, String message, [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $message';

    // طباعة في وحدة التحكم
    developer.log(logMessage, name: 'SubscriptionSystem');

    if (error != null) {
      developer.log('Error: $error', name: 'SubscriptionSystem');
    }

    if (stackTrace != null) {
      developer.log('StackTrace: $stackTrace', name: 'SubscriptionSystem');
    }

    // كتابة في الملف
    _writeToFile(logMessage, error, stackTrace);
  }

  Future<void> _writeToFile(String message, [Object? error, StackTrace? stackTrace]) async {
    if (!_initialized) {
      await init();
    }

    try {
      final fileSize = await _logFile.length();
      if (fileSize > MAX_LOG_SIZE) {
        await _rotateLogFile();
      }

      var logContent = '$message\n';
      if (error != null) {
        logContent += 'Error: $error\n';
      }
      if (stackTrace != null) {
        logContent += 'StackTrace: $stackTrace\n';
      }

      await _logFile.writeAsString(logContent, mode: FileMode.append);
    } catch (e) {
      developer.log('Failed to write to log file: $e');
    }
  }

  Future<void> _rotateLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupFile = File('${directory.path}/subscription_logs_backup.txt');

      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      await _logFile.rename(backupFile.path);
      _logFile = File('${directory.path}/$LOG_FILE_NAME');
      await _logFile.create();

      developer.log('Log file rotated');
    } catch (e) {
      developer.log('Failed to rotate log file: $e');
    }
  }

  Future<String> getLogs() async {
    try {
      if (!_initialized) {
        await init();
      }

      if (await _logFile.exists()) {
        return await _logFile.readAsString();
      }

      return 'No logs available';
    } catch (e) {
      developer.log('Failed to read logs: $e');
      return 'Error reading logs: $e';
    }
  }

  Future<void> clearLogs() async {
    try {
      if (!_initialized) {
        await init();
      }

      if (await _logFile.exists()) {
        await _logFile.delete();
        await _logFile.create();
      }

      developer.log('Logs cleared');
    } catch (e) {
      developer.log('Failed to clear logs: $e');
    }
  }
}
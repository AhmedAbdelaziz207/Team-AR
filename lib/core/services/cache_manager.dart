import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'logger_service.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  static final LoggerService _logger = LoggerService();
  static const String CACHE_PREFIX = 'cache_';
  static const String EXPIRY_SUFFIX = '_expiry';

  // حفظ البيانات في الكاش
  Future<void> set<T>(String key, T value, Duration duration) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$CACHE_PREFIX$key';
      final expiryKey = '$CACHE_PREFIX$key$EXPIRY_SUFFIX';

      final expiryTime = DateTime.now().add(duration);
      final serializedValue = jsonEncode(value);

      await prefs.setString(cacheKey, serializedValue);
      await prefs.setString(expiryKey, expiryTime.toIso8601String());

      _logger.info('Cached data for key: $key, expires at: $expiryTime');
    } catch (e) {
      _logger.error('Error caching data for key: $key', e);
    }
  }

  // استرجاع البيانات من الكاش
  Future<T?> get<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$CACHE_PREFIX$key';
      final expiryKey = '$CACHE_PREFIX$key$EXPIRY_SUFFIX';

      final expiryString = prefs.getString(expiryKey);
      if (expiryString == null) {
        _logger.info('No expiry found for key: $key');
        return null;
      }

      final expiryTime = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiryTime)) {
        _logger.info('Cache expired for key: $key');
        await remove(key);
        return null;
      }

      final serializedValue = prefs.getString(cacheKey);
      if (serializedValue == null) {
        _logger.info('No cached data for key: $key');
        return null;
      }

      final value = jsonDecode(serializedValue);
      _logger.info('Retrieved cached data for key: $key');

      return value as T;
    } catch (e) {
      _logger.error('Error retrieving cached data for key: $key', e);
      return null;
    }
  }

  // حذف عنصر من الكاش
  Future<void> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$CACHE_PREFIX$key';
      final expiryKey = '$CACHE_PREFIX$key$EXPIRY_SUFFIX';

      await prefs.remove(cacheKey);
      await prefs.remove(expiryKey);

      _logger.info('Removed cached data for key: $key');
    } catch (e) {
      _logger.error('Error removing cached data for key: $key', e);
    }
  }

  // تنظيف الكاش المنتهي الصلاحية
  Future<void> cleanExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final now = DateTime.now();

      for (final key in keys) {
        if (key.startsWith(CACHE_PREFIX) && key.endsWith(EXPIRY_SUFFIX)) {
          final expiryString = prefs.getString(key);
          if (expiryString != null) {
            final expiryTime = DateTime.parse(expiryString);
            if (now.isAfter(expiryTime)) {
              final cacheKey = key.replaceAll(EXPIRY_SUFFIX, '');
              final originalKey = cacheKey.replaceAll(CACHE_PREFIX, '');
              await remove(originalKey);
            }
          }
        }
      }

      _logger.info('Cleaned expired cache entries');
    } catch (e) {
      _logger.error('Error cleaning expired cache', e);
    }
  }

  // تنظيف الكاش بالكامل
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(CACHE_PREFIX)) {
          await prefs.remove(key);
        }
      }

      _logger.info('Cleared all cache entries');
    } catch (e) {
      _logger.error('Error clearing cache', e);
    }
  }

  // فحص وجود البيانات في الكاش
  Future<bool> exists(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$CACHE_PREFIX$key';
      final expiryKey = '$CACHE_PREFIX$key$EXPIRY_SUFFIX';

      if (!prefs.containsKey(cacheKey) || !prefs.containsKey(expiryKey)) {
        return false;
      }

      final expiryString = prefs.getString(expiryKey);
      if (expiryString == null) return false;

      final expiryTime = DateTime.parse(expiryString);
      return DateTime.now().isBefore(expiryTime);
    } catch (e) {
      _logger.error('Error checking cache existence for key: $key', e);
      return false;
    }
  }
}
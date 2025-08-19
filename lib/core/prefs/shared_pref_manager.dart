import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_ar/core/utils/app_constants.dart';

class SharedPreferencesHelper {
  static Future<void> setData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      throw UnsupportedError("Unsupported value type: ${value.runtimeType}");
    }
  }

  static Future<bool> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> setString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setString(key, value);
      if (result) {
      } else {
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(key);
      return value;
    } catch (e) {
      return null;
    }
  }

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> removeAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.token);
    await prefs.remove(AppConstants.userId);
    await prefs.remove(AppConstants.userRole);
    await prefs.remove(AppConstants.userDiet);
    await prefs.remove(AppConstants.dataCompleted);
  }
}

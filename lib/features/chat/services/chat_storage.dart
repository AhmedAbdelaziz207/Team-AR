import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/chat_model.dart';
import '../model/chat_user_model.dart';

class ChatStorage {
  static const String _chatMessagesPrefix = 'chat_messages_';
  static const String _chatUsersKey = 'chat_users';
  static const String _lastSyncKey = 'last_chat_sync';
  static const int _maxStoredMessages = 200; // عدد الرسائل المخزنة لكل محادثة

  // حفظ رسائل المحادثة مع مستخدم معين
  Future<void> saveMessages(String userId, List<ChatMessageModel> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _chatMessagesPrefix + userId;
      
      // ترتيب الرسائل حسب الوقت (الأحدث أولاً)
      messages.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
      
      // تحديد عدد الرسائل المخزنة
      if (messages.length > _maxStoredMessages) {
        messages = messages.sublist(0, _maxStoredMessages);
      }
      
      final messagesJson = messages.map((msg) => msg.toJson()).toList();
      await prefs.setString(key, jsonEncode(messagesJson));
    } catch (e) {
      print('خطأ في حفظ رسائل المحادثة: $e');
    }
  }

  // الحصول على رسائل المحادثة مع مستخدم معين
  Future<List<ChatMessageModel>> getMessages(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _chatMessagesPrefix + userId;
      final messagesJson = prefs.getString(key);
      
      if (messagesJson == null) return [];
      
      final List decodedList = jsonDecode(messagesJson);
      final messages = decodedList
          .map((json) => ChatMessageModel.fromJson(json))
          .toList();
      
      // ترتيب الرسائل حسب الوقت (الأحدث أولاً)
      messages.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
      
      return messages;
    } catch (e) {
      print('خطأ في استرجاع رسائل المحادثة: $e');
      return [];
    }
  }

  // حفظ قائمة المستخدمين
  Future<void> saveUsers(List<ChatUserModel> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = users.map((user) => user.toJson()).toList();
      await prefs.setString(_chatUsersKey, jsonEncode(usersJson));
    } catch (e) {
      print('خطأ في حفظ قائمة المستخدمين: $e');
    }
  }

  // الحصول على قائمة المستخدمين
  Future<List<ChatUserModel>> getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_chatUsersKey);
      
      if (usersJson == null) return [];
      
      final List decodedList = jsonDecode(usersJson);
      final users = decodedList
          .map((json) => ChatUserModel.fromJson(json))
          .toList();
      
      return users;
    } catch (e) {
      print('خطأ في استرجاع قائمة المستخدمين: $e');
      return [];
    }
  }

  // حفظ وقت آخر مزامنة
  Future<void> saveLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().toIso8601String();
      await prefs.setString(_lastSyncKey, now);
    } catch (e) {
      print('خطأ في حفظ وقت آخر مزامنة: $e');
    }
  }

  // الحصول على وقت آخر مزامنة
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_lastSyncKey);
      
      if (timeString == null) return null;
      
      return DateTime.parse(timeString);
    } catch (e) {
      print('خطأ في استرجاع وقت آخر مزامنة: $e');
      return null;
    }
  }

  // إضافة رسالة جديدة إلى المحادثة
  Future<void> addMessage(String userId, ChatMessageModel message) async {
    try {
      final messages = await getMessages(userId);
      messages.insert(0, message); // إضافة الرسالة في بداية القائمة
      await saveMessages(userId, messages);
    } catch (e) {
      print('خطأ في إضافة رسالة جديدة: $e');
    }
  }
}
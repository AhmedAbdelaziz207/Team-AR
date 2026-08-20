import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowUpService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> updateDietTimestamp(String traineeId) async {
    try {
      await _client.from('trainee_followups').upsert({
        'trainee_id': traineeId,
        'last_diet_update': DateTime.now().toIso8601String(),
      });
      log('Updated diet timestamp for $traineeId');
    } catch (e) {
      log('Error updating diet timestamp: $e');
    }
  }

  Future<void> updateChatTimestamp(String traineeId) async {
    try {
      await _client.from('trainee_followups').upsert({
        'trainee_id': traineeId,
        'last_chat_update': DateTime.now().toIso8601String(),
      });
      log('Updated chat timestamp for $traineeId');
    } catch (e) {
      log('Error updating chat timestamp: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTraineesNeedingFollowUp() async {
    try {
      final DateTime fourteenDaysAgo = DateTime.now().subtract(const Duration(days: 14));
      final response = await _client
          .from('trainee_followups')
          .select()
          .lt('last_diet_update', fourteenDaysAgo.toIso8601String());
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error getting follow-ups: $e');
      return [];
    }
  }
}

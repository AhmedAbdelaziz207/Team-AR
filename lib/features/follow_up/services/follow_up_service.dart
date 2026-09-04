import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:team_ar/features/follow_up/model/follow_up_trainee.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/home/admin/repos/trainees_repository.dart';

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

  Future<void> updateWorkoutTimestamp(String traineeId) async {
    try {
      await _client.from('trainee_followups').upsert({
        'trainee_id': traineeId,
        'last_diet_update': DateTime.now().toIso8601String(),
      });
      log('Updated workout follow-up timestamp for $traineeId');
    } catch (e) {
      log('Error updating workout follow-up timestamp: $e');
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
      final DateTime fourteenDaysAgo =
          DateTime.now().subtract(const Duration(days: 14));

      final response = await _client.from('trainee_followups').select();
      final List<Map<String, dynamic>> records =
          List<Map<String, dynamic>>.from(response);

      final List<Map<String, dynamic>> needingFollowUp = [];

      for (final record in records) {
        final dietStr = record['last_diet_update']?.toString();
        final chatStr = record['last_chat_update']?.toString();

        final DateTime? dietDate =
            dietStr != null ? DateTime.tryParse(dietStr) : null;
        final DateTime? chatDate =
            chatStr != null ? DateTime.tryParse(chatStr) : null;

        DateTime? lastInteraction;
        if (dietDate != null && chatDate != null) {
          lastInteraction = dietDate.isAfter(chatDate) ? dietDate : chatDate;
        } else {
          lastInteraction = dietDate ?? chatDate;
        }

        if (lastInteraction == null || lastInteraction.isBefore(fourteenDaysAgo)) {
          needingFollowUp.add(record);
        }
      }

      return needingFollowUp;
    } catch (e) {
      log('Error getting follow-ups: $e');
      return [];
    }
  }

  Future<List<FollowUpTrainee>> getFollowUpTraineesWithDetails(
      TraineesRepository repository) async {
    try {
      final now = DateTime.now();

      // 1. Fetch all trainees from backend repository
      final result = await repository.getAllTrainees();
      final List<TraineeModel> allTrainees = [];

      result.whenOrNull(
        success: (trainees) {
          allTrainees.addAll(
            trainees.where(
              (user) {
                final r = user.role?.toLowerCase().trim();
                return r != 'admin' && r != 'adimn' && r != 'administrator';
              },
            ),
          );
        },
      );

      if (allTrainees.isEmpty) {
        return [];
      }

      // 2. Fetch follow-up records from Supabase
      final response = await _client.from('trainee_followups').select();
      final List<Map<String, dynamic>> records =
          List<Map<String, dynamic>>.from(response);

      final Map<String, Map<String, dynamic>> followUpMap = {
        for (var r in records) r['trainee_id'].toString(): r
      };

      final List<FollowUpTrainee> delayedTrainees = [];

      for (final trainee in allTrainees) {
        final traineeId = trainee.id;
        if (traineeId == null) continue;

        final followUpData = followUpMap[traineeId];

        DateTime? lastDietUpdate;
        DateTime? lastChatUpdate;
        DateTime? lastInteraction;

        if (followUpData != null) {
          final dietStr = followUpData['last_diet_update']?.toString();
          final chatStr = followUpData['last_chat_update']?.toString();

          lastDietUpdate = dietStr != null ? DateTime.tryParse(dietStr) : null;
          lastChatUpdate = chatStr != null ? DateTime.tryParse(chatStr) : null;

          if (lastDietUpdate != null && lastChatUpdate != null) {
            lastInteraction = lastDietUpdate.isAfter(lastChatUpdate)
                ? lastDietUpdate
                : lastChatUpdate;
          } else {
            lastInteraction = lastDietUpdate ?? lastChatUpdate;
          }
        }

        int daysDelayed = 0;
        bool isDelayed = false;

        if (lastInteraction != null) {
          daysDelayed = now.difference(lastInteraction).inDays;
          isDelayed = daysDelayed >= 14;
        } else {
          // If no recorded interaction, check package start date (or infer it)
          DateTime? effectiveStart = trainee.startPackage;
          if (effectiveStart == null &&
              trainee.endPackage != null &&
              trainee.duration != null &&
              trainee.duration! > 0) {
            effectiveStart = trainee.endPackage!
                .subtract(Duration(days: trainee.duration!));
          }

          if (effectiveStart != null) {
            daysDelayed = now.difference(effectiveStart).inDays;
            isDelayed = daysDelayed >= 14;
          } else {
            // New or untracked trainee without package date
            // If they have a record in follow_up with nulls, mark as 14+ days
            if (followUpData != null) {
              daysDelayed = 14;
              isDelayed = true;
            }
          }
        }

        if (isDelayed) {
          delayedTrainees.add(
            FollowUpTrainee(
              trainee: trainee,
              lastDietUpdate: lastDietUpdate,
              lastChatUpdate: lastChatUpdate,
              lastInteraction: lastInteraction,
              daysDelayed: daysDelayed,
            ),
          );
        }
      }

      // Sort by days delayed descending (most delayed first)
      delayedTrainees.sort((a, b) => b.daysDelayed.compareTo(a.daysDelayed));

      return delayedTrainees;
    } catch (e) {
      log('Error getting follow-up trainees with details: $e');
      return [];
    }
  }
}

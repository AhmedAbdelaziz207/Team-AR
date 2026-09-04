import 'package:team_ar/features/home/admin/data/trainee_model.dart';

class FollowUpTrainee {
  final TraineeModel trainee;
  final DateTime? lastDietUpdate;
  final DateTime? lastChatUpdate;
  final DateTime? lastInteraction;
  final int daysDelayed;

  FollowUpTrainee({
    required this.trainee,
    this.lastDietUpdate,
    this.lastChatUpdate,
    this.lastInteraction,
    required this.daysDelayed,
  });

  String get delayFormattedText {
    if (daysDelayed <= 0) {
      return "تمت المتابعة مؤخراً";
    }
    return "متأخر منذ $daysDelayed يوماً";
  }

  bool get hasDietUpdate => lastDietUpdate != null;
  bool get hasChatUpdate => lastChatUpdate != null;
}

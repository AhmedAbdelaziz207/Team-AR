import 'package:team_ar/features/follow_up/model/follow_up_trainee.dart';

abstract class FollowUpState {
  const FollowUpState();
}

class FollowUpInitial extends FollowUpState {
  const FollowUpInitial();
}

class FollowUpLoading extends FollowUpState {
  const FollowUpLoading();
}

class FollowUpSuccess extends FollowUpState {
  final List<FollowUpTrainee> trainees;
  const FollowUpSuccess(this.trainees);
}

class FollowUpFailure extends FollowUpState {
  final String errorMessage;
  const FollowUpFailure(this.errorMessage);
}

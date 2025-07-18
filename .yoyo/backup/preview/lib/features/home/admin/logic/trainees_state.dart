import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';

part 'trainees_state.freezed.dart';

@freezed
class TraineeState  with _$TraineeState{
  const factory TraineeState.initial() = _Initial;
  const factory TraineeState.loading() = TraineeLoading;
  const factory TraineeState.success(List<TraineeModel> trainees) = TraineeSuccess;
  const factory TraineeState.failure(String errorMessage) = TraineeFailure;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_ar/features/user_info/model/trainee_model.dart';
import '../../admin/data/trainee_model.dart';

part 'user_state.freezed.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.initial() = UserInitial;

  const factory UserState.loading() = UserLoading;

  const factory UserState.success(TraineeModel userData) = UserSuccess;

  const factory UserState.getTrainee(TrainerModel userData) = GetTrainee;

  const factory UserState.failure(String errorMessage) = UserFailure;

  const factory UserState.updateImageSuccess() = UpdateUserImageSuccess;

  const factory UserState.updateImageFailure(String message) =
      UpdateUserImageFailure;

  const factory UserState.updateUserSuccess() = UpdateUserSuccess;

  const factory UserState.updateUserFailure(String message) =
      UpdateUserFailure;
}

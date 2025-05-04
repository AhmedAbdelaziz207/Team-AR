import 'package:freezed_annotation/freezed_annotation.dart';
part 'workout_state.freezed.dart';

@freezed
sealed class WorkoutState {
  const factory WorkoutState.workoutInitial() = WorkoutInitial;

  const factory WorkoutState.workoutLoading() = WorkoutLoading;

  const factory WorkoutState.workoutSuccess(String? url) = WorkoutSuccess;

  const factory WorkoutState.workoutFailure(String message) =
      WorkoutFailure;
}

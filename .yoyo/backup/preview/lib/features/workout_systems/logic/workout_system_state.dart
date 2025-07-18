import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/network/api_error_model.dart';
import '../model/workout_system_model.dart';

part 'workout_system_state.freezed.dart';
@freezed
sealed class WorkoutSystemState {
  const factory WorkoutSystemState.initial() = _Initial;
  const factory WorkoutSystemState.loading() = WorkoutSystemLoading;
  const factory WorkoutSystemState.success(List<WorkoutSystemModel> data) = WorkoutSystemLoadSuccess;
  const factory WorkoutSystemState.uploadSuccess() = WorkoutSystemUploadSuccess;
  const factory WorkoutSystemState.assignedSuccess() = WorkoutSystemAssignedSuccess;
  const factory WorkoutSystemState.assignLoading() = WorkoutSystemAssignLoading;

  const factory WorkoutSystemState.failure(ApiErrorModel errorModel) = WorkoutSystemFailure;

}

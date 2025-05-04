import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/work_out/logic/workout_state.dart';
import '../../workout_systems/repo/workout_system_repository.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  WorkoutCubit() : super(const WorkoutState.workoutInitial());

  final repo = WorkoutSystemRepository(getIt<ApiService>());

  void getWorkout(workoutId) async {
    emit(const WorkoutState.workoutLoading());

    final result = await repo.getWorkout(workoutId);

    result.when(
      success: (data) => emit(WorkoutState.workoutSuccess(data)),
      failure: (error) => emit(
        WorkoutState.workoutFailure(
          error.getErrorsMessage() ?? "Something went wrong",
        ),
      ),
    );
  }
}

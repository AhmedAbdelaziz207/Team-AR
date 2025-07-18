import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/workout_systems/logic/workout_system_state.dart';
import 'package:team_ar/features/workout_systems/model/workout_system_model.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/api_service.dart';
import '../repo/workout_system_repository.dart';

class WorkoutSystemCubit extends Cubit<WorkoutSystemState> {
  WorkoutSystemCubit() : super(const WorkoutSystemState.initial());
  final WorkoutSystemRepository repo =
      WorkoutSystemRepository(getIt<ApiService>());
  final nameController = TextEditingController();
  File? workoutPdf;

  void uploadWorkoutSystem() async {
    emit(const WorkoutSystemState.loading());

    final ApiResult result = await repo.uploadWorkoutSystemFile(
      WorkoutSystemModel(
        name: nameController.text,
        id: 0,
        url: "",
      ),
      workoutPdf!,
    );

    result.when(
      success: (data) => emit(const WorkoutSystemState.uploadSuccess()),
      failure: (error) => emit(WorkoutSystemState.failure(error)),
    );
  }

  void getWorkoutSystems() async {
    emit(const WorkoutSystemState.loading());
    final result = await repo.getWorkoutSystems();

    result.when(
      success: (data) => emit(WorkoutSystemState.success(data)),
      failure: (error) => emit(WorkoutSystemState.failure(error)),
    );
  }

  Future<void> deleteWorkoutSystem(int id) async {
    final result = await repo.deleteWorkoutSystem(id);
    result.when(
      success: (data) {},
      failure: (error) {
        emit(WorkoutSystemState.failure(error));
      },
    );
  }

  Future<void> addWorkoutForUser(int workoutId, String userId) async {
    emit(const WorkoutSystemState.assignLoading());
    final result = await repo.addWorkoutForUser(
      workoutId: workoutId,
      userId: userId,
    );
    result.when(
      success: (data) {
        emit(const WorkoutSystemState.assignedSuccess());
      },
      failure: (error) {
        emit(WorkoutSystemState.failure(error));
      },
    );
  }
}

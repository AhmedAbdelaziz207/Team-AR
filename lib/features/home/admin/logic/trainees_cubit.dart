import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/features/home/admin/logic/trainees_state.dart';
import 'package:team_ar/features/home/admin/repos/trainees_repository.dart';

class TraineeCubit extends Cubit<TraineeState> {
  TraineeCubit(this.traineesRepository) : super(const TraineeState.initial());
  final TraineesRepository traineesRepository;

  void getNewTrainees() async {
    emit(const TraineeState.loading());

    final response = await traineesRepository.getNewTrainees();
    log("trainees Response: $response");

    response.whenOrNull(
      success: (trainees) => emit(
        TraineeState.success(trainees),
      ),
      failure: (error) => emit(
        TraineeState.failure(
          error.getErrorsMessage() ?? AppLocalKeys.unexpectedError.tr(),
        ),
      ),
    );
  }
  void getAllTrainees() async {
    emit(const TraineeState.loading());

    final response = await traineesRepository.getAllTrainees();
    log("trainees Response: $response");

    response.whenOrNull(
      success: (trainees) => emit(
        TraineeState.success(trainees),
      ),
      failure: (error) => emit(
        TraineeState.failure(
          error.getErrorsMessage() ?? AppLocalKeys.unexpectedError.tr(),
        ),
      ),
    );
  }
  void getUsersAboutToExpired() async {
    emit(const TraineeState.loading());

    final response = await traineesRepository.getUsersAboutToExpired();
    log("trainees Response: $response");

    response.whenOrNull(
      success: (trainees) => emit(
        TraineeState.success(trainees),
      ),
      failure: (error) => emit(
        TraineeState.failure(
          error.getErrorsMessage() ?? AppLocalKeys.unexpectedError.tr(),
        ),
      ),
    );
  }
}

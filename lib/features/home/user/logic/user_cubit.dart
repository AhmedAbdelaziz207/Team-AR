import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/auth/register/model/user_model.dart';
import 'package:team_ar/features/home/admin/repos/trainees_repository.dart';
import 'package:team_ar/features/home/user/logic/user_state.dart';
import 'package:team_ar/features/user_info/model/trainee_model.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState.initial());
  final TraineesRepository repo = TraineesRepository(getIt<ApiService>());

  void getUser(String id) async {
    emit(const UserState.loading());

    final result = await repo.getLoggedUser(id);

    result.when(
      success: (data) => emit(UserState.success(data)),
      failure: (error) =>
          emit(UserState.failure(error.getErrorsMessage() ?? "")),
    );
  }

  void getTrainee(String id) async {
    log("Get Trainee");
    emit(const UserState.loading());

    log("UserId : $id");
    final result = await repo.getTrainer(id);

    result.when(
      success: (data) {
        log("Trainee : ${data.userName}");
        emit(UserState.getTrainee(data));
      },
      failure: (error) => emit(
        UserState.failure(error.getErrorsMessage() ?? ""),
      ),
    );
  }

  void updateImage(String userId, File userImage) async {
    final result = await repo.updateUserImage(userImage, userId);

    result.when(
      success: (data) => emit(const UserState.updateImageSuccess()),
      failure: (error) => emit(
        UserState.updateImageFailure(error.getErrorsMessage() ?? ""),
      ),
    );
  }

  updateUser(TrainerModel user) async {
    final result = await repo.updateUser(user.toJson());

    result.when(
      success: (data) => emit(const UserState.updateUserSuccess()),
      failure: (error) => emit(
        UserState.updateUserFailure(error.getErrorsMessage() ?? ""),
      ),
    );
  }
}
